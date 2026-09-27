// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract DuLieuBDS {
    // Custom errors
    error KhongPhaoChuHopDong();
    error KhongPhaoChuSoHuu(uint256 id);
    error ChuSoHuuKhongTheMua(uint256 id);
    error TaiSanKhongTonTai(uint256 id);
    error DangNiemYetRoi();
    error TaiSanChuaNiemYet();
    error DaXacNhanRoi();
    error DangNiemYetHayHuyTruoc();
    error ThanhToanKhongDu(uint256 required, uint256 sent);
    error ChuyenTienThatBai();
    error KhongCoPhiDeRut();
    error DiaChiTrong();
    error GiaTriKhongHopLe();
    error DiaChiNguoiNhanKhongHopLe();
    error KhongTheChuyenChoChinhMinh();

    // Structs
    struct Property {
        uint256 id;
        uint256 giaTri;
        uint256 thoiGianDangKy;
        address chuSoHuu;
        bool exists;
        bool dangBanHang;
        bool daXacNhan;
        string diaChi;
        string moTa;
    }

    struct LichSuGiaoDich {
        uint256 propertyId;
        uint256 giaTri;
        uint256 thoiGian;
        address nguoiBan;
        address nguoiMua;
        string loaiGiaoDich;
    }

    // State variables
    address public chuHopDong;
    uint256 public tongSoTaiSan;
    uint256 public phiGiaoDich = 0.001 ether;

    mapping(uint256 => Property) public danhSachTaiSan;
    mapping(address => uint256[]) public taiSanCuaNguoiDung;
    LichSuGiaoDich[] public lichSuGiaoDich;

    // Events
    event TaiSanDaDangKy(uint256 indexed id, string diaChi, address indexed chuSoHuu, uint256 giaTri);
    event TaiSanNiemYet(uint256 indexed id, address indexed chuSoHuu, uint256 gia);
    event TaiSanDaGiaoDich(uint256 indexed id, address indexed nguoiBan, address indexed nguoiMua, uint256 giaTri);
    event TaiSanDaXacNhan(uint256 indexed id, address indexed chuSoHuu);

    constructor() {
        chuHopDong = msg.sender;
        tongSoTaiSan = 0;
    }
}