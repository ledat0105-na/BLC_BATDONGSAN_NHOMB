// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title RealEstate - Hệ thống quản lý Bất Động Sản trên Blockchain
 * @author Nhóm Blockchain - Đề tài số 6: Bất Động Sản
 * @notice Quản lý quyền sở hữu, giao dịch và lịch sử chuyển nhượng BĐS
 * @dev Optimized v2: custom errors · struct packing · calldata · CEI · unchecked
 */
contract RealEstate {

    // =============================================
    //  CUSTOM ERRORS — tiết kiệm ~200 gas/revert so với string
    // =============================================

    // Access control
    error KhongPhaoChuHopDong();
    error KhongPhaoChuSoHuu(uint256 id);
    error ChuSoHuuKhongTheMua(uint256 id);

    // Validation
    error DiaChiTrong();
    error GiaTriKhongHopLe();
    error DiaChiNguoiNhanKhongHopLe();
    error KhongTheChuyenChoChinhMinh();

    // State
    error TaiSanKhongTonTai(uint256 id);
    error DangNiemYetRoi();
    error TaiSanChuaNiemYet();
    error DaXacNhanRoi();
    error DangNiemYetHayHuyTruoc();

    // Payment
    error ThanhToanKhongDu(uint256 required, uint256 sent);
    error ChuyenTienThatBai();
    error KhongCoPhiDeRut();

    // =============================================
    //  CẤU TRÚC DỮ LIỆU — Optimized storage packing
    // =============================================

    /**
     * @dev Thứ tự trường được sắp xếp để tối ưu storage slots:
     *   slot 0: id              (uint256 — 32 bytes)
     *   slot 1: giaTri          (uint256 — 32 bytes)
     *   slot 2: thoiGianDangKy  (uint256 — 32 bytes)
     *   slot 3: chuSoHuu(20B) + exists(1B) + dangBanHang(1B) + daXacNhan(1B) → 1 slot duy nhất
     *   slot 4+: diaChi         (dynamic string)
     *   slot 5+: moTa           (dynamic string)
     *
     * Tiết kiệm 3 storage slots (~60,000 gas) so với bản gốc mỗi lần tạo BĐS.
     * Trường `isSold` đã bị loại bỏ — trạng thái bán được suy ra qua `dangBanHang`
     * và lịch sử giao dịch, cho phép chủ mới bán lại sau khi nhận BĐS.
     */
    struct Property {
        uint256 id;
        uint256 giaTri;           // Giá trị niêm yết (Wei)
        uint256 thoiGianDangKy;   // Thời điểm đăng ký (block.timestamp)
        address chuSoHuu;         // 20 bytes ─┐
        bool    exists;           //  1 byte   │ packed vào 1 slot (24/32 bytes)
        bool    dangBanHang;      //  1 byte   │
        bool    daXacNhan;        //  1 byte  ─┘
        string  diaChi;           // Địa chỉ bất động sản
        string  moTa;             // Mô tả (diện tích, loại hình...)
    }

    struct LichSuGiaoDich {
        uint256 propertyId;
        uint256 giaTri;
        uint256 thoiGian;
        address nguoiBan;
        address nguoiMua;
        string  loaiGiaoDich;     // "DANG_KY" | "MUA_BAN" | "CHUYEN_NHUONG"
    }

    // =============================================
    //  BIẾN TRẠNG THÁI
    // =============================================

    address public chuHopDong;                    // Chủ hợp đồng (= Cơ quan Nhà nước)
    uint256 public tongSoTaiSan;                  // Tổng số tài sản đã đăng ký
    uint256 public phiGiaoDich = 0.001 ether;     // Phí giao dịch (tham khảo)

    mapping(uint256 => Property)    public danhSachTaiSan;
    mapping(address => uint256[])   public taiSanCuaNguoiDung;
    LichSuGiaoDich[]                public lichSuGiaoDich;

    // =============================================
    //  SỰ KIỆN (Events)
    // =============================================

    event TaiSanDaDangKy(uint256 indexed id, string diaChi, address indexed chuSoHuu, uint256 giaTri);
    event TaiSanNiemYet(uint256 indexed id, address indexed chuSoHuu, uint256 gia);
    event TaiSanDaGiaoDich(uint256 indexed id, address indexed nguoiBan, address indexed nguoiMua, uint256 giaTri);
    event TaiSanDaXacNhan(uint256 indexed id, address indexed chuSoHuu);

    // =============================================
    //  MODIFIER
    // =============================================

    modifier chiChuHopDong() {
        if (msg.sender != chuHopDong) revert KhongPhaoChuHopDong();
        _;
    }

    modifier chiChuTaiSan(uint256 _id) {
        if (danhSachTaiSan[_id].chuSoHuu != msg.sender) revert KhongPhaoChuSoHuu(_id);
        _;
    }

    modifier taiSanTonTai(uint256 _id) {
        if (!danhSachTaiSan[_id].exists) revert TaiSanKhongTonTai(_id);
        _;
    }

    // =============================================
    //  CONSTRUCTOR
    // =============================================

    constructor() {
        chuHopDong = msg.sender;
    }

    /// @dev Nhận ETH gửi trực tiếp (ví dụ: phí từ dịch vụ bên ngoài)
    receive() external payable {}

    // =============================================
    //  FUNCTION 1: ĐĂNG KÝ TÀI SẢN
    // =============================================

    /**
     * @notice Đăng ký một bất động sản mới lên blockchain
     * @param _diaChi Địa chỉ bất động sản (không được rỗng)
     * @param _moTa   Mô tả chi tiết (diện tích, loại hình...)
     * @param _giaTri Giá trị khởi đầu tính bằng Wei (> 0)
     * @return newId  ID của tài sản vừa đăng ký
     *
     * @dev Dùng `calldata` thay `memory` để tránh copy không cần thiết.
     *      `unchecked` increment an toàn vì overflow đòi hỏi 2^256 lần đăng ký.
     */
    function dangKyTaiSan(
        string calldata _diaChi,
        string calldata _moTa,
        uint256 _giaTri
    ) external returns (uint256) {
        if (bytes(_diaChi).length == 0) revert DiaChiTrong();
        if (_giaTri == 0)              revert GiaTriKhongHopLe();

        uint256 newId;
        unchecked { newId = ++tongSoTaiSan; }

        danhSachTaiSan[newId] = Property({
            id:             newId,
            giaTri:         _giaTri,
            thoiGianDangKy: block.timestamp,
            chuSoHuu:       msg.sender,
            exists:         true,
            dangBanHang:    false,
            daXacNhan:      false,
            diaChi:         _diaChi,
            moTa:           _moTa
        });

        taiSanCuaNguoiDung[msg.sender].push(newId);

        lichSuGiaoDich.push(LichSuGiaoDich({
            propertyId:   newId,
            giaTri:       _giaTri,
            thoiGian:     block.timestamp,
            nguoiBan:     address(0),
            nguoiMua:     msg.sender,
            loaiGiaoDich: "DANG_KY"
        }));

        emit TaiSanDaDangKy(newId, _diaChi, msg.sender, _giaTri);
        return newId;
    }

    // =============================================
    //  FUNCTION 2: NIÊM YẾT BÁN
    // =============================================

    /**
     * @notice Chủ sở hữu niêm yết BĐS để bán
     * @dev Không còn kiểm tra `isSold` — chủ mới hoàn toàn có thể niêm yết lại.
     */
    function niemYetBan(
        uint256 _id,
        uint256 _gia
    ) external taiSanTonTai(_id) chiChuTaiSan(_id) {
        if (danhSachTaiSan[_id].dangBanHang) revert DangNiemYetRoi();
        if (_gia == 0)                        revert GiaTriKhongHopLe();

        danhSachTaiSan[_id].dangBanHang = true;
        danhSachTaiSan[_id].giaTri      = _gia;

        emit TaiSanNiemYet(_id, msg.sender, _gia);
    }

    // =============================================
    //  FUNCTION 3: MUA TÀI SẢN
    // =============================================

    /**
     * @notice Mua một BĐS đang được niêm yết
     * @dev Tuân theo CEI pattern: Checks → Effects → Interactions.
     *      Dùng `call` thay `transfer` để tránh gas stipend issue với smart contract wallets.
     *      ETH dư (msg.value > giaTri) được hoàn trả tự động cho người mua.
     */
    function muaTaiSan(uint256 _id) external payable taiSanTonTai(_id) {
        Property storage ts = danhSachTaiSan[_id];

        // ── CHECKS ───────────────────────────────────────
        if (!ts.dangBanHang)            revert TaiSanChuaNiemYet();
        address nguoiBanCu = ts.chuSoHuu;
        if (msg.sender == nguoiBanCu)   revert ChuSoHuuKhongTheMua(_id);
        uint256 giaTriGiaoDich = ts.giaTri;
        if (msg.value < giaTriGiaoDich) revert ThanhToanKhongDu(giaTriGiaoDich, msg.value);

        // ── EFFECTS ──────────────────────────────────────
        address buyer  = msg.sender;
        ts.chuSoHuu    = buyer;
        ts.dangBanHang = false;

        _xoaTaiSanKhoiNguoiDung(nguoiBanCu, _id);
        taiSanCuaNguoiDung[buyer].push(_id);

        lichSuGiaoDich.push(LichSuGiaoDich({
            propertyId:   _id,
            giaTri:       giaTriGiaoDich,
            thoiGian:     block.timestamp,
            nguoiBan:     nguoiBanCu,
            nguoiMua:     buyer,
            loaiGiaoDich: "MUA_BAN"
        }));

        emit TaiSanDaGiaoDich(_id, nguoiBanCu, buyer, giaTriGiaoDich);

        // ── INTERACTIONS ─────────────────────────────────
        // Chuyển đúng giá niêm yết cho người bán
        (bool ok,) = payable(nguoiBanCu).call{value: giaTriGiaoDich}("");
        if (!ok) revert ChuyenTienThatBai();

        // Hoàn trả ETH dư cho người mua
        uint256 tienThua = msg.value - giaTriGiaoDich;
        if (tienThua > 0) {
            (bool refundOk,) = payable(buyer).call{value: tienThua}("");
            if (!refundOk) revert ChuyenTienThatBai();
        }
    }

    // =============================================
    //  FUNCTION 4: CHUYỂN NHƯỢNG (Tặng / Thừa kế)
    // =============================================

    /**
     * @notice Chủ sở hữu chuyển nhượng BĐS (tặng / thừa kế) không cần thanh toán
     * @dev BĐS phải được hủy niêm yết trước khi chuyển nhượng.
     */
    function chuyenNhuong(
        uint256 _id,
        address _nguoiNhan
    ) external taiSanTonTai(_id) chiChuTaiSan(_id) {
        if (_nguoiNhan == address(0)) revert DiaChiNguoiNhanKhongHopLe();
        if (_nguoiNhan == msg.sender) revert KhongTheChuyenChoChinhMinh();
        if (danhSachTaiSan[_id].dangBanHang) revert DangNiemYetHayHuyTruoc();

        address nguoiChuCu = msg.sender;
        danhSachTaiSan[_id].chuSoHuu = _nguoiNhan;

        _xoaTaiSanKhoiNguoiDung(nguoiChuCu, _id);
        taiSanCuaNguoiDung[_nguoiNhan].push(_id);

        lichSuGiaoDich.push(LichSuGiaoDich({
            propertyId:   _id,
            giaTri:       0,
            thoiGian:     block.timestamp,
            nguoiBan:     nguoiChuCu,
            nguoiMua:     _nguoiNhan,
            loaiGiaoDich: "CHUYEN_NHUONG"
        }));

        emit TaiSanDaGiaoDich(_id, nguoiChuCu, _nguoiNhan, 0);
    }

    // =============================================
    //  FUNCTION 5: XEM LỊCH SỬ GIAO DỊCH
    // =============================================

    /**
     * @notice Lấy toàn bộ lịch sử giao dịch của một tài sản
     * @dev Cache `lichSuGiaoDich.length` và dùng `unchecked` loop để giảm gas.
     */
    function xemLichSuTaiSan(uint256 _id)
        external
        view
        taiSanTonTai(_id)
        returns (LichSuGiaoDich[] memory)
    {
        uint256 len   = lichSuGiaoDich.length; // cache: tránh SLOAD lặp lại
        uint256 count = 0;

        for (uint256 i = 0; i < len;) {
            if (lichSuGiaoDich[i].propertyId == _id) {
                unchecked { count++; }
            }
            unchecked { i++; }
        }

        LichSuGiaoDich[] memory result = new LichSuGiaoDich[](count);
        uint256 idx = 0;

        for (uint256 i = 0; i < len;) {
            if (lichSuGiaoDich[i].propertyId == _id) {
                result[idx] = lichSuGiaoDich[i];
                unchecked { idx++; }
            }
            unchecked { i++; }
        }
        return result;
    }

    // =============================================
    //  FUNCTION 6: XÁC NHẬN TÀI SẢN (Cơ quan NN)
    // =============================================

    /// @notice Cơ quan Nhà nước xác nhận tính pháp lý của BĐS
    function xacNhanTaiSan(uint256 _id)
        external
        taiSanTonTai(_id)
        chiChuHopDong
    {
        if (danhSachTaiSan[_id].daXacNhan) revert DaXacNhanRoi();
        danhSachTaiSan[_id].daXacNhan = true;
        emit TaiSanDaXacNhan(_id, danhSachTaiSan[_id].chuSoHuu);
    }

    // =============================================
    //  CÁC HÀM ĐỌC DỮ LIỆU (View Functions)
    // =============================================

    /// @notice Lấy danh sách ID tài sản của một người dùng
    function layTaiSanCuaNguoiDung(address _nguoiDung)
        external view returns (uint256[] memory)
    {
        return taiSanCuaNguoiDung[_nguoiDung];
    }

    /// @notice Lấy thông tin chi tiết một tài sản
    function layThongTinTaiSan(uint256 _id)
        external view taiSanTonTai(_id) returns (Property memory)
    {
        return danhSachTaiSan[_id];
    }

    /// @notice Cơ quan NN rút toàn bộ ETH tích lũy trong contract
    function rutPhiGiaoDich() external chiChuHopDong {
        uint256 balance = address(this).balance;
        if (balance == 0) revert KhongCoPhiDeRut();
        (bool ok,) = payable(chuHopDong).call{value: balance}("");
        if (!ok) revert ChuyenTienThatBai();
    }

    // =============================================
    //  HÀM NỘI BỘ (Internal Helper)
    // =============================================

    /// @dev Swap-and-pop: O(1) xóa phần tử trong mảng storage
    function _xoaTaiSanKhoiNguoiDung(address _nguoi, uint256 _id) internal {
        uint256[] storage arr = taiSanCuaNguoiDung[_nguoi];
        uint256 len = arr.length;
        for (uint256 i = 0; i < len;) {
            if (arr[i] == _id) {
                arr[i] = arr[len - 1];
                arr.pop();
                break;
            }
            unchecked { i++; }
        }
    }
}
