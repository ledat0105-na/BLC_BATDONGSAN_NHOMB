// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title BatDongSanTongHop
 * @notice Gop dang ky, kiem tra, niem yet, mua ban, chuyen quyen va lich su giao dich.
 * @dev Gia va msg.value deu tinh bang wei. Khong su dung du lieu mau co the ghi de.
 */
contract BatDongSanTongHop {
    struct Property {
        uint256 id;
        uint256 giaTri;
        uint256 thoiGianDangKy;
        address payable chuSoHuu;
        bool exists;
        bool dangBanHang;
        bool daXacNhan;
        bool daBan;
        string diaChi;
        string moTa;
    }

    struct Transaction {
        uint256 transactionId;
        uint256 propertyId;
        address seller;
        address buyer;
        uint256 price;
        uint256 timestamp;
        string status;
    }

    address public immutable chuHopDong;
    uint256 public tongSoTaiSan;
    uint256 public transactionCount;
    mapping(uint256 => Property) public danhSachTaiSan;
    mapping(address => uint256[]) private taiSanCuaNguoiDung;
    mapping(uint256 => Transaction) public transactions;
    uint256 private khoa = 1;

    event TaiSanDaDangKy(uint256 indexed id, string diaChi, address indexed chuSoHuu, uint256 giaTri);
    event TaiSanDaXacNhan(uint256 indexed id, address indexed chuSoHuu);
    event TaiSanNiemYet(uint256 indexed id, address indexed chuSoHuu, uint256 gia);
    event HuyNiemYet(uint256 indexed id);
    event TaiSanDaGiaoDich(uint256 indexed id, address indexed nguoiBan, address indexed nguoiMua, uint256 giaTri);
    event ChuyenQuyenSoHuu(uint256 indexed id, address indexed nguoiCu, address indexed nguoiMoi);
    event ExcessRefunded(address indexed buyer, uint256 refundAmount);
    event TransactionRecorded(uint256 indexed transactionId, uint256 indexed propertyId, string status);

    constructor() { chuHopDong = msg.sender; }

    modifier tonTai(uint256 id) {
        require(danhSachTaiSan[id].exists, "BDS khong ton tai");
        _;
    }
    modifier chuSoHuu(uint256 id) {
        require(danhSachTaiSan[id].chuSoHuu == msg.sender, "Chi chu so huu");
        _;
    }
    modifier khongTaiNhap() {
        require(khoa == 1, "Dang xu ly giao dich");
        khoa = 2;
        _;
        khoa = 1;
    }

    function registerProperty(uint256 id, uint256 giaWei, string calldata diaChi, string calldata moTa) external {
        require(id != 0 && !danhSachTaiSan[id].exists, "Ma BDS trung hoac khong hop le");
        require(giaWei > 0, "Gia phai lon hon 0");
        require(bytes(diaChi).length > 0, "Dia chi trong");
        danhSachTaiSan[id] = Property(id, giaWei, block.timestamp, payable(msg.sender), true, false, false, false, diaChi, moTa);
        taiSanCuaNguoiDung[msg.sender].push(id);
        tongSoTaiSan++;
        emit TaiSanDaDangKy(id, diaChi, msg.sender, giaWei);
    }

    // Chu hop dong xac nhan thong tin truoc khi cho niem yet.
    function confirmProperty(uint256 id) external tonTai(id) {
        require(msg.sender == chuHopDong, "Chi chu hop dong");
        require(!danhSachTaiSan[id].daXacNhan, "Da xac nhan");
        danhSachTaiSan[id].daXacNhan = true;
        emit TaiSanDaXacNhan(id, danhSachTaiSan[id].chuSoHuu);
    }

    function listProperty(uint256 id, uint256 giaWei) external tonTai(id) chuSoHuu(id) {
        Property storage p = danhSachTaiSan[id];
        require(p.daXacNhan, "BDS chua xac nhan");
        require(!p.dangBanHang, "Da niem yet");
        require(giaWei > 0, "Gia phai lon hon 0");
        p.giaTri = giaWei;
        p.dangBanHang = true;
        p.daBan = false;
        emit TaiSanNiemYet(id, msg.sender, giaWei);
    }

    function cancelListing(uint256 id) external tonTai(id) chuSoHuu(id) {
        require(danhSachTaiSan[id].dangBanHang, "Chua niem yet");
        danhSachTaiSan[id].dangBanHang = false;
        emit HuyNiemYet(id);
    }

    function checkProperty(uint256 id) external view tonTai(id) returns (bool) {
        require(!danhSachTaiSan[id].daBan, "BDS da ban");
        return true;
    }

    function validateBuyer(uint256 id, address buyer, uint256 sentValue) external view tonTai(id) returns (bool) {
        Property storage p = danhSachTaiSan[id];
        require(p.dangBanHang, "BDS chua niem yet");
        require(buyer != address(0) && buyer != p.chuSoHuu, "Nguoi mua khong hop le");
        require(sentValue >= p.giaTri, "Thanh toan thieu");
        return true;
    }

    function buyProperty(uint256 id) external payable tonTai(id) khongTaiNhap {
        Property storage p = danhSachTaiSan[id];
        require(p.dangBanHang && p.daXacNhan, "BDS chua niem yet");
        require(msg.sender != p.chuSoHuu, "Chu so huu khong the mua");
        uint256 gia = p.giaTri;
        require(msg.value >= gia, "Thanh toan thieu");
        address payable nguoiBan = p.chuSoHuu;
        p.chuSoHuu = payable(msg.sender);
        p.dangBanHang = false;
        p.daBan = true;
        _removeOwned(nguoiBan, id);
        taiSanCuaNguoiDung[msg.sender].push(id);
        _record(id, nguoiBan, msg.sender, gia, "Da thanh toan");
        uint256 tienThua = msg.value - gia;
        if (tienThua != 0) {
            (bool hoan, ) = payable(msg.sender).call{value: tienThua}("");
            require(hoan, "Hoan tien that bai");
            emit ExcessRefunded(msg.sender, tienThua);
        }
        (bool thanhToan, ) = nguoiBan.call{value: gia}("");
        require(thanhToan, "Chuyen tien that bai");
        emit TaiSanDaGiaoDich(id, nguoiBan, msg.sender, gia);
    }

    function transferOwnership(uint256 id, address newOwner) external tonTai(id) chuSoHuu(id) {
        Property storage p = danhSachTaiSan[id];
        require(!p.dangBanHang, "Huy niem yet truoc khi chuyen");
        require(newOwner != address(0) && newOwner != msg.sender, "Nguoi nhan khong hop le");
        address oldOwner = msg.sender;
        p.chuSoHuu = payable(newOwner);
        p.daBan = false;
        _removeOwned(oldOwner, id);
        taiSanCuaNguoiDung[newOwner].push(id);
        _record(id, oldOwner, newOwner, 0, "Chuyen quyen");
        emit ChuyenQuyenSoHuu(id, oldOwner, newOwner);
    }

    function getTransaction(uint256 transactionId) external view returns (Transaction memory) {
        require(transactionId > 0 && transactionId <= transactionCount, "Giao dich khong ton tai");
        return transactions[transactionId];
    }

    function getOwnedProperties(address owner) external view returns (uint256[] memory) {
        return taiSanCuaNguoiDung[owner];
    }

    function _record(uint256 id, address seller, address buyer, uint256 price, string memory status) private {
        uint256 transactionId = ++transactionCount;
        transactions[transactionId] = Transaction(transactionId, id, seller, buyer, price, block.timestamp, status);
        emit TransactionRecorded(transactionId, id, status);
    }

    function _removeOwned(address owner, uint256 id) private {
        uint256[] storage ids = taiSanCuaNguoiDung[owner];
        for (uint256 i; i < ids.length; i++) {
            if (ids[i] == id) {
                ids[i] = ids[ids.length - 1];
                ids.pop();
                return;
            }
        }
        revert("Du lieu chu so huu khong hop le");
    }
}
