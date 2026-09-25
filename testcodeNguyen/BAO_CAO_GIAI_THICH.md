
# 📖 Báo cáo Giải thích Smart Contract — RealEstate.sol

### Hệ thống Quản lý Bất Động Sản trên Blockchain

# 📖 Báo cáo Giải thích Smart Contract — RealEstate.sol
### Hệ thống Quản lý Bất Động Sản trên Blockchain
> Dành cho người mới bắt đầu — giải thích từ nền tảng đến chi tiết code

---

## 🌐 Phần 1 — Nền tảng cần biết

### 1.1 Blockchain là gì?

Hãy tưởng tượng blockchain như một **cuốn sổ ghi chép khổng lồ** được chia sẻ cho hàng nghìn máy tính trên toàn thế giới cùng giữ. Mỗi khi ai đó ghi thêm thông tin vào cuốn sổ đó, **tất cả các máy đều cập nhật** và **không ai có thể xóa hay sửa** những gì đã ghi.

| Đặc điểm             | Giải thích đơn giản                                        |
| ------------------------ | --------------------------------------------------------------- |
| **Phi tập trung** | Không có một máy chủ trung tâm duy nhất nào kiểm soát |
| **Bất biến**     | Dữ liệu đã ghi không thể xóa hay sửa                    |
| **Minh bạch**     | Ai cũng có thể xem mọi giao dịch                           |
| **Tự động**     | Hợp đồng tự thực thi khi thỏa điều kiện                |
| Đặc điểm | Giải thích đơn giản |
|---|---|
| **Phi tập trung** | Không có một máy chủ trung tâm duy nhất nào kiểm soát |
| **Bất biến** | Dữ liệu đã ghi không thể xóa hay sửa |
| **Minh bạch** | Ai cũng có thể xem mọi giao dịch |
| **Tự động** | Hợp đồng tự thực thi khi thỏa điều kiện |

### 1.2 Smart Contract là gì?

**Smart Contract** (Hợp đồng thông minh) là một chương trình máy tính chạy **trực tiếp trên blockchain**. Nó giống như một máy bán hàng tự động:

- Bạn **bỏ tiền vào** (gửi ETH)
- Máy **tự kiểm tra** điều kiện (đủ tiền chưa? hàng còn không?)
- Máy **tự thực hiện** hành động (trả hàng, thối tiền)
- **Không cần người trung gian** (ngân hàng, công chứng, môi giới)

### 1.3 Solidity là gì?

**Solidity** là ngôn ngữ lập trình dùng để viết Smart Contract cho mạng Ethereum. Nó trông giống JavaScript/C++ nhưng có nhiều khái niệm đặc thù của blockchain.

### 1.4 ETH và Wei là gì?

- **ETH (Ether)**: Đồng tiền của mạng Ethereum, dùng để trả phí giao dịch và thanh toán
- **Wei**: Đơn vị nhỏ nhất của ETH (giống xu so với đồng đô-la)
  - `1 ETH = 1,000,000,000,000,000,000 Wei` (10^18)
  - Ví dụ: `10 ETH = 10_000_000_000_000_000_000 Wei`

---

## 🏗️ Phần 2 — Cấu trúc tổng quan của Contract

File [RealEstate.sol](file:///d:/BlockChain/RealEstate.sol) mô phỏng **Sở Đăng ký Đất đai** trên blockchain, cho phép:

```
👤 Người dân     → đăng ký BĐS, niêm yết, mua, chuyển nhượng
🏛️ Cơ quan NN   → xác nhận pháp lý, rút phí
📋 Blockchain   → lưu toàn bộ lịch sử, không ai sửa được
```

### Sơ đồ các thành phần:

```
RealEstate Contract
│
├── 📦 Custom Errors     — Mã lỗi khi thao tác sai
├── 📋 Structs           — Khuôn mẫu dữ liệu (Property, LichSuGiaoDich)
├── 💾 State Variables   — Biến lưu trữ lâu dài trên blockchain
├── 📢 Events            — Thông báo khi có sự kiện quan trọng
├── 🔐 Modifiers         — Bộ lọc kiểm tra quyền trước khi chạy hàm
├── 🏗️ Constructor       — Chạy 1 lần khi deploy contract
└── 🔧 Functions (9 hàm)
    ├── dangKyTaiSan()          — Đăng ký BĐS
    ├── niemYetBan()            — Niêm yết để bán
    ├── muaTaiSan()             — Mua BĐS (có gửi ETH)
    ├── chuyenNhuong()          — Tặng / thừa kế
    ├── xemLichSuTaiSan()       — Xem lịch sử
    ├── xacNhanTaiSan()         — Xác nhận pháp lý (NN)
    ├── layTaiSanCuaNguoiDung() — Xem danh sách BĐS
    ├── layThongTinTaiSan()     — Xem chi tiết 1 BĐS
    └── rutPhiGiaoDich()        — Rút tiền phí (NN)
```

---

## 📦 Phần 3 — Custom Errors (Mã lỗi tùy chỉnh)

```solidity
error KhongPhaoChuHopDong();
error KhongPhaoChuSoHuu(uint256 id);
error TaiSanKhongTonTai(uint256 id);
// ... và 11 lỗi khác
```

### Giải thích:

**Custom Error** là cách thông báo lỗi khi người dùng làm điều gì đó không được phép.

> **Ví dụ thực tế:** Giống như khi bạn đến ATM và máy hiện thông báo "Số dư không đủ" hay "Thẻ không hợp lệ" — contract cũng báo lỗi tương tự khi điều kiện không thỏa mãn.

**Tại sao dùng `error` thay vì `string`?**

```solidity
// Cách cũ — tốn gas (lưu cả chuỗi ký tự vào blockchain)
require(msg.sender == chuHopDong, "Chi chu hop dong moi duoc phep!");

// Cách mới — tiết kiệm ~200 gas (chỉ lưu mã lỗi 4 bytes)
if (msg.sender != chuHopDong) revert KhongPhaoChuHopDong();
```

**Gas** là phí bạn trả cho blockchain để thực hiện mỗi thao tác. Tiết kiệm gas = tiết kiệm tiền thật.

| Tên lỗi                            | Khi nào xảy ra                                 |
| ------------------------------------ | ------------------------------------------------ |
| `KhongPhaoChuHopDong()`            | Người thường cố làm việc của Cơ quan NN |
| `KhongPhaoChuSoHuu(id)`            | Cố thao tác BĐS không phải của mình       |
| `ChuSoHuuKhongTheMua(id)`          | Chủ BĐS cố tự mua BĐS của mình            |
| `TaiSanKhongTonTai(id)`            | Truy cập ID BĐS không tồn tại               |
| `DangNiemYetRoi()`                 | Niêm yết lần 2 khi đang niêm yết           |
| `TaiSanChuaNiemYet()`              | Cố mua BĐS chưa được niêm yết            |
| `DaXacNhanRoi()`                   | Xác nhận lần 2 khi đã xác nhận            |
| `DangNiemYetHayHuyTruoc()`         | Chuyển nhượng khi đang niêm yết            |
| `ThanhToanKhongDu(required, sent)` | Gửi ETH ít hơn giá niêm yết                |
| `ChuyenTienThatBai()`              | Lỗi kỹ thuật khi chuyển ETH                  |
| `KhongCoPhiDeRut()`                | Rút phí khi contract không có ETH            |
| Tên lỗi | Khi nào xảy ra |
|---|---|
| `KhongPhaoChuHopDong()` | Người thường cố làm việc của Cơ quan NN |
| `KhongPhaoChuSoHuu(id)` | Cố thao tác BĐS không phải của mình |
| `ChuSoHuuKhongTheMua(id)` | Chủ BĐS cố tự mua BĐS của mình |
| `TaiSanKhongTonTai(id)` | Truy cập ID BĐS không tồn tại |
| `DangNiemYetRoi()` | Niêm yết lần 2 khi đang niêm yết |
| `TaiSanChuaNiemYet()` | Cố mua BĐS chưa được niêm yết |
| `DaXacNhanRoi()` | Xác nhận lần 2 khi đã xác nhận |
| `DangNiemYetHayHuyTruoc()` | Chuyển nhượng khi đang niêm yết |
| `ThanhToanKhongDu(required, sent)` | Gửi ETH ít hơn giá niêm yết |
| `ChuyenTienThatBai()` | Lỗi kỹ thuật khi chuyển ETH |
| `KhongCoPhiDeRut()` | Rút phí khi contract không có ETH |

---

## 📋 Phần 4 — Structs (Khuôn mẫu dữ liệu)

### 4.1 Struct `Property` — Thông tin một BĐS

```solidity
struct Property {
    uint256 id;              // Số thứ tự định danh (1, 2, 3...)
    uint256 giaTri;          // Giá niêm yết (tính bằng Wei)
    uint256 thoiGianDangKy;  // Thời điểm đăng ký (Unix timestamp)
    address chuSoHuu;        // Địa chỉ ví của chủ sở hữu
    bool    exists;          // BĐS có tồn tại? (true/false)
    bool    dangBanHang;     // Đang niêm yết bán? (true/false)
    bool    daXacNhan;       // Đã được NN xác nhận? (true/false)
    string  diaChi;          // "123 Nguyen Hue, Q1, HCM"
    string  moTa;            // "Can ho 80m2, 2 phong ngu"
}
```

**Struct** giống như một **phiếu thông tin** — tập hợp nhiều trường dữ liệu liên quan vào một chỗ. Ví dụ:

```
┌─────────────────────────────────────────────┐
│  BẤT ĐỘNG SẢN #001                          │
│  Địa chỉ  : 123 Nguyễn Huệ, Quận 1, HCM    │
│  Mô tả    : Căn hộ cao cấp, 80m², 2PN       │
│  Chủ sở hữu: 0xAbC...123 (địa chỉ ví)       │
│  Giá trị  : 10 ETH                          │
│  Tồn tại  : ✅  Niêm yết: ❌  XN pháp lý: ❌ │
│  Đăng ký  : 23/09/2026 18:30:00             │
└─────────────────────────────────────────────┘
```

**Về các kiểu dữ liệu:**

- `uint256`: Số nguyên dương (0 đến 2^256). "uint" = unsigned integer
- `address`: Địa chỉ ví Ethereum, 20 bytes, dạng `0xAbCd...1234`
- `bool`: Giá trị đúng/sai (`true` hoặc `false`)
- `string`: Chuỗi ký tự văn bản

### 4.2 Struct `LichSuGiaoDich` — Một bản ghi lịch sử

```solidity
struct LichSuGiaoDich {
    uint256 propertyId;    // ID của BĐS liên quan
    uint256 giaTri;        // Số tiền giao dịch (0 nếu tặng)
    uint256 thoiGian;      // Thời điểm xảy ra
    address nguoiBan;      // Ai chuyển đi? (address(0) nếu đăng ký mới)
    address nguoiMua;      // Ai nhận?
    string  loaiGiaoDich;  // "DANG_KY" | "MUA_BAN" | "CHUYEN_NHUONG"
}
```

Mỗi hành động quan trọng đều tạo ra 1 bản ghi lịch sử — **vĩnh viễn không xóa được** trên blockchain.

---

## 💾 Phần 5 — State Variables (Biến trạng thái)

```solidity
address public chuHopDong;                // Cơ quan Nhà nước (người deploy)
uint256 public tongSoTaiSan;              // Đếm tổng BĐS đã đăng ký
uint256 public phiGiaoDich = 0.001 ether; // Phí tham chiếu

mapping(uint256 => Property)  public danhSachTaiSan;
mapping(address => uint256[]) public taiSanCuaNguoiDung;
LichSuGiaoDich[]              public lichSuGiaoDich;
```

**Biến trạng thái** = dữ liệu được lưu **vĩnh viễn** trên blockchain (không biến mất khi hàm kết thúc).

### Từ khóa `public`:

Thêm `public` vào biến → Solidity **tự động tạo hàm đọc** cho biến đó. Ai cũng có thể đọc giá trị nhưng không ai được sửa trực tiếp từ bên ngoài.

### `mapping` là gì?

**Mapping** giống như một **từ điển** hay **bảng tra cứu**:

```
mapping(uint256 => Property) danhSachTaiSan

  Khóa (Key)    →   Giá trị (Value)
  ──────────────────────────────────
  1             →   Property{id:1, diaChi:"123 Nguyen Hue"...}
  2             →   Property{id:2, diaChi:"456 Le Loi"...}
  3             →   Property{id:3, diaChi:"789 CMT8"...}
```

```
mapping(address => uint256[]) taiSanCuaNguoiDung

  Khóa (Key)      →   Giá trị (Value)
  ────────────────────────────────────
  0xAlice...      →   [1, 3, 5]   ← Alice sở hữu BĐS 1,3,5
  0xBob...        →   [2, 4]      ← Bob sở hữu BĐS 2,4
  0xCharlie...    →   []          ← Charlie chưa có BĐS nào
```

### Mảng `LichSuGiaoDich[]`:

Mảng động lưu **tất cả** lịch sử giao dịch theo thứ tự thời gian:

```
Index  │  Nội dung
───────┼──────────────────────────────────────────
  [0]  │  {BĐS#1, DANG_KY, Alice đăng ký}
  [1]  │  {BĐS#2, DANG_KY, Bob đăng ký}
  [2]  │  {BĐS#1, MUA_BAN, Alice → Bob, 15 ETH}
  [3]  │  {BĐS#1, CHUYEN_NHUONG, Bob → Charlie}
  ...
```

---

## 📢 Phần 6 — Events (Sự kiện)

```solidity
event TaiSanDaDangKy(uint256 indexed id, string diaChi, address indexed chuSoHuu, uint256 giaTri);
event TaiSanNiemYet(uint256 indexed id, address indexed chuSoHuu, uint256 gia);
event TaiSanDaGiaoDich(uint256 indexed id, address indexed nguoiBan, address indexed nguoiMua, uint256 giaTri);
event TaiSanDaXacNhan(uint256 indexed id, address indexed chuSoHuu);
```

**Event** là **thông báo** được gửi ra khi có sự kiện quan trọng xảy ra.

> **Ví dụ:** Giống như hệ thống SMS banking — khi bạn chuyển tiền, ngân hàng gửi SMS thông báo. Event cũng vậy, nhưng thay vì SMS thì là thông báo trên blockchain.

**Từ khóa `indexed`:** Cho phép tìm kiếm nhanh theo trường đó. Ví dụ: "tìm tất cả BĐS của địa chỉ Alice" — `indexed` trên `chuSoHuu` giúp tìm kiếm nhanh hơn nhiều.

**Sử dụng trong code:**

```solidity
emit TaiSanDaDangKy(newId, _diaChi, msg.sender, _giaTri);
//    ↑ từ khóa     ↑ tên event   ↑ các tham số
```

---

## 🔐 Phần 7 — Modifiers (Bộ lọc quyền hạn)

```solidity
modifier chiChuHopDong() {
    if (msg.sender != chuHopDong) revert KhongPhaoChuHopDong();
    _;    // ← Ký hiệu "chạy tiếp code của hàm ở đây"
}

modifier chiChuTaiSan(uint256 _id) {
    if (danhSachTaiSan[_id].chuSoHuu != msg.sender) revert KhongPhaoChuSoHuu(_id);
    _;
}

modifier taiSanTonTai(uint256 _id) {
    if (!danhSachTaiSan[_id].exists) revert TaiSanKhongTonTai(_id);
    _;
}
```

**Modifier** là **bảo vệ cửa vào** — chạy trước khi hàm thực sự được thực thi.

> **Ví dụ:** Như bảo vệ ở cửa tòa nhà — kiểm tra thẻ trước khi cho vào. Ký hiệu `_;` nghĩa là "sau khi kiểm tra xong, cho vào bên trong".

**Ví dụ luồng thực thi:**

```
Ai đó gọi niemYetBan(1, 15 ETH)
         ↓
[taiSanTonTai] → BĐS #1 có tồn tại không?
   → Không → REVERT TaiSanKhongTonTai(1)
   → Có    → tiếp tục ↓
[chiChuTaiSan] → msg.sender có phải chủ #1?
   → Không → REVERT KhongPhaoChuSoHuu(1)
   → Có    → tiếp tục ↓
[Code hàm] → Thực thi niêm yết ✅
```

**`msg.sender`** là địa chỉ ví của **người đang gọi hàm** — luôn tự động có và không thể giả mạo.

---

## 🏗️ Phần 8 — Constructor

```solidity
constructor() {
    chuHopDong = msg.sender;
}
```

**Constructor** chạy **đúng một lần duy nhất** khi contract được triển khai (deploy) lên blockchain.

Ở đây: Người deploy contract trở thành `chuHopDong` — tức là **Cơ quan Nhà nước** có quyền xác nhận BĐS và rút phí.

```
Người deploy contract  →  msg.sender  →  chuHopDong
(Cơ quan Nhà nước)
```

---

## 🔧 Phần 9 — Các hàm chức năng chi tiết

### 9.1 `dangKyTaiSan()` — Đăng ký BĐS mới

```solidity
function dangKyTaiSan(
    string calldata _diaChi,   // Địa chỉ BĐS
    string calldata _moTa,     // Mô tả
    uint256 _giaTri            // Giá trị ban đầu
) external returns (uint256) { ... }
```

**Luồng hoạt động:**

```
1. Kiểm tra địa chỉ không rỗng        → DiaChiTrong nếu rỗng
2. Kiểm tra giá trị > 0               → GiaTriKhongHopLe nếu = 0
3. Tăng tongSoTaiSan (unchecked)      → ID mới = tongSoTaiSan
4. Tạo Property mới và lưu vào mapping
5. Thêm ID vào danh sách của người đăng ký
6. Ghi 1 bản ghi lịch sử "DANG_KY"
7. Phát ra event TaiSanDaDangKy
8. Trả về ID vừa tạo
```

**Từ khóa quan trọng:**

| Từ khóa           | Ý nghĩa                                                                |
| ------------------- | ------------------------------------------------------------------------ |
| `external`        | Chỉ gọi từ bên ngoài contract (tiết kiệm gas hơn`public`)      |
| `calldata`        | Dữ liệu đầu vào đọc trực tiếp, không copy vào bộ nhớ        |
| `unchecked`       | Bỏ qua kiểm tra tràn số (safe vì không thể đăng ký 2^256 BĐS) |
| `block.timestamp` | Thời gian của block hiện tại (số giây Unix)                        |

**Ví dụ thực tế:**

| Từ khóa | Ý nghĩa |
|---|---|
| `external` | Chỉ gọi từ bên ngoài contract (tiết kiệm gas hơn `public`) |
| `calldata` | Dữ liệu đầu vào đọc trực tiếp, không copy vào bộ nhớ |
| `unchecked` | Bỏ qua kiểm tra tràn số (safe vì không thể đăng ký 2^256 BĐS) |
| `block.timestamp` | Thời gian của block hiện tại (số giây Unix) |

**Ví dụ thực tế:**
```
Alice gọi: dangKyTaiSan("123 Nguyen Hue, Q1", "80m2, 2PN", 10_ETH)

Kết quả:
  ✅ BĐS #1 được tạo
  ✅ taiSanCuaNguoiDung[Alice] = [1]
  ✅ lichSuGiaoDich[0] = {id:1, DANG_KY, Alice, 10ETH}
  ✅ Event TaiSanDaDangKy(1, "123 Nguyen Hue...", Alice, 10ETH)
  ✅ Trả về: 1
```

---

### 9.2 `niemYetBan()` — Niêm yết BĐS để bán

```solidity
function niemYetBan(
    uint256 _id,   // ID của BĐS muốn niêm yết
    uint256 _gia   // Giá muốn bán (Wei)
) external taiSanTonTai(_id) chiChuTaiSan(_id) { ... }
```

**Luồng:**

```
[Modifier] BĐS phải tồn tại
[Modifier] Người gọi phải là chủ sở hữu
1. Kiểm tra BĐS chưa niêm yết  → DangNiemYetRoi nếu đang niêm yết
2. Kiểm tra giá > 0             → GiaTriKhongHopLe nếu = 0
3. dangBanHang = true
4. giaTri = _gia (cập nhật giá mới)
5. Phát event TaiSanNiemYet
```

**Ví dụ:**

```
Alice (chủ BĐS #1) gọi: niemYetBan(1, 15_ETH)

✅ BĐS #1: dangBanHang = true, giaTri = 15 ETH
✅ Event TaiSanNiemYet(1, Alice, 15ETH)

❌ Bob (không phải chủ) gọi → KhongPhaoChuSoHuu(1)
❌ Giá = 0                   → GiaTriKhongHopLe
```

---

### 9.3 `muaTaiSan()` — Mua BĐS (hàm quan trọng nhất)

```solidity
function muaTaiSan(uint256 _id) external payable taiSanTonTai(_id) { ... }
```

**Từ khóa `payable`:** Cho phép hàm này **nhận ETH** khi được gọi.

**Luồng theo mô hình CEI (Checks → Effects → Interactions):**

```
[Modifier] BĐS phải tồn tại

── CHECKS (Kiểm tra) ──────────────────────────────
1. dangBanHang == true?         → TaiSanChuaNiemYet nếu không
2. msg.sender != chủ BĐS?      → ChuSoHuuKhongTheMua nếu là chủ
3. msg.value >= giaTri?         → ThanhToanKhongDu nếu thiếu tiền

── EFFECTS (Cập nhật dữ liệu) ─────────────────────
4. chuSoHuu = người mua (buyer)
5. dangBanHang = false
6. Xóa BĐS khỏi danh sách người bán cũ
7. Thêm BĐS vào danh sách người mua
8. Ghi lịch sử "MUA_BAN"
9. Phát event TaiSanDaGiaoDich

── INTERACTIONS (Chuyển tiền — luôn làm cuối cùng) ─
10. Chuyển đúng giaTri ETH cho người bán
11. Hoàn trả ETH dư (msg.value - giaTri) cho người mua
```

> **Tại sao phải theo thứ tự CEI?**
> Nếu chuyển tiền trước rồi mới cập nhật trạng thái, kẻ tấn công có thể gọi lại hàm trong khi tiền đang chuyển — gọi là **Reentrancy Attack**. CEI ngăn chặn điều này bằng cách luôn cập nhật trạng thái TRƯỚC khi chuyển tiền.

**Ví dụ:**

```
Bob gọi: muaTaiSan(1) với {value: 20 ETH}  ← BĐS giá 15 ETH

✅ Chủ sở hữu BĐS #1: Alice → Bob
✅ Alice nhận 15 ETH
✅ Bob nhận lại 5 ETH thừa (20 - 15 = 5)
✅ lichSuGiaoDich += {BĐS#1, MUA_BAN, Alice→Bob, 15ETH}

❌ Bob gửi chỉ 5 ETH → ThanhToanKhongDu(15ETH, 5ETH)
❌ Alice tự mua      → ChuSoHuuKhongTheMua(1)
❌ BĐS chưa niêm yết → TaiSanChuaNiemYet
```

---

### 9.4 `chuyenNhuong()` — Tặng / Thừa kế

```solidity
function chuyenNhuong(
    uint256 _id,
    address _nguoiNhan  // Địa chỉ ví người nhận
) external taiSanTonTai(_id) chiChuTaiSan(_id) { ... }
```

Khác với `muaTaiSan` (có tiền), `chuyenNhuong` là **chuyển miễn phí** — không cần gửi ETH.

**Luồng:**

```
[Modifier] BĐS tồn tại, người gọi là chủ
1. Người nhận != address(0)          → DiaChiNguoiNhanKhongHopLe
2. Người nhận != người gửi           → KhongTheChuyenChoChinhMinh
3. BĐS không đang niêm yết           → DangNiemYetHayHuyTruoc
4. chuSoHuu = người nhận
5. Cập nhật danh sách 2 bên
6. Ghi lịch sử "CHUYEN_NHUONG" (giaTri = 0)
```

> **`address(0)`** là địa chỉ zero: `0x0000...0000` — địa chỉ "không tồn tại", dùng để kiểm tra địa chỉ hợp lệ.

---

### 9.5 `xemLichSuTaiSan()` — Xem lịch sử

```solidity
function xemLichSuTaiSan(uint256 _id)
    external view taiSanTonTai(_id)
    returns (LichSuGiaoDich[] memory)
```

**Từ khóa `view`:** Hàm chỉ **đọc** dữ liệu, không thay đổi gì → **miễn phí gas**.

**Thuật toán 2 vòng lặp:**

```
Vòng 1: Đếm bao nhiêu bản ghi thuộc về BĐS _id
         → Biết kích thước → cấp phát mảng đúng size
Vòng 2: Điền dữ liệu vào mảng → Trả về
```

Solidity **không thể thay đổi kích thước mảng memory** sau khi khởi tạo — phải biết trước kích thước, nên cần 2 vòng.

**Tối ưu gas trong vòng lặp:**

```solidity
uint256 len = lichSuGiaoDich.length; // Cache 1 lần (1 SLOAD)
for (uint256 i = 0; i < len;) {     // Không đọc .length lặp lại
    ...
    unchecked { i++; }               // i không bao giờ tràn số
}
```

---

### 9.6 `xacNhanTaiSan()` — Xác nhận pháp lý

```solidity
function xacNhanTaiSan(uint256 _id)
    external taiSanTonTai(_id) chiChuHopDong
```

Chỉ `chuHopDong` (Cơ quan Nhà nước) mới gọi được, nhờ modifier `chiChuHopDong`.

```
chuHopDong gọi xacNhanTaiSan(1)
  ↓
daXacNhan = true  ← trường này đánh dấu BĐS đã hợp pháp
  ↓
Event TaiSanDaXacNhan(1, Alice)
```

---

### 9.7 `rutPhiGiaoDich()` — Rút ETH từ contract

```solidity
function rutPhiGiaoDich() external chiChuHopDong {
    uint256 balance = address(this).balance;
    if (balance == 0) revert KhongCoPhiDeRut();
    (bool ok,) = payable(chuHopDong).call{value: balance}("");
    if (!ok) revert ChuyenTienThatBai();
}
```

- `address(this).balance`: Số ETH đang có trong contract
- `payable(...).call{value: X}("")`: Cách chuyển ETH hiện đại, an toàn nhất

**Tại sao dùng `.call` thay `.transfer`?**

| `.transfer()`                       | `.call()`                      |
| ------------------------------------- | -------------------------------- |
| Giới hạn 2300 gas                   | Không giới hạn gas            |
| Có thể thất bại với smart wallet | Hoạt động với mọi loại ví |
| Cũ, không khuyến dùng             | Chuẩn hiện đại               |
| `.transfer()` | `.call()` |
|---|---|
| Giới hạn 2300 gas | Không giới hạn gas |
| Có thể thất bại với smart wallet | Hoạt động với mọi loại ví |
| Cũ, không khuyến dùng | Chuẩn hiện đại |

---

## 🗄️ Phần 10 — Hàm nội bộ `_xoaTaiSanKhoiNguoiDung()`

```solidity
function _xoaTaiSanKhoiNguoiDung(address _nguoi, uint256 _id) internal {
    uint256[] storage arr = taiSanCuaNguoiDung[_nguoi];
    uint256 len = arr.length;
    for (uint256 i = 0; i < len;) {
        if (arr[i] == _id) {
            arr[i] = arr[len - 1]; // Đưa phần tử cuối lên vị trí cần xóa
            arr.pop();             // Xóa phần tử cuối
            break;
        }
        unchecked { i++; }
    }
}
```

**Từ khóa `internal`:** Chỉ được gọi từ **bên trong** contract — không ai bên ngoài gọi được.

**Thuật toán Swap-and-Pop — O(1):**

```
Mảng ban đầu: [1, 3, 5, 7, 9]
Muốn xóa phần tử 3 (ở vị trí index 1)

Bước 1: Đưa phần tử cuối (9) lên vị trí index 1
        [1, 9, 5, 7, 9]

Bước 2: Pop() xóa phần tử cuối
        [1, 9, 5, 7]

✅ Xong! Không cần dịch chuyển cả mảng
   → Nhanh O(1) thay vì O(n) nếu dịch từng phần tử
```

---

## 🌊 Phần 11 — Luồng đầy đủ một giao dịch BĐS

```
BƯỚC 1: ĐĂNG KÝ
Alice gọi dangKyTaiSan("123 Nguyen Hue", "80m2", 10ETH)
→ BĐS #1 ra đời, Alice là chủ
→ Lịch sử: [DANG_KY]

BƯỚC 2: XÁC NHẬN (Cơ quan NN)
chuHopDong gọi xacNhanTaiSan(1)
→ daXacNhan = true
→ BĐS được công nhận pháp lý

BƯỚC 3: NIÊM YẾT BÁN
Alice gọi niemYetBan(1, 15ETH)
→ dangBanHang = true, giaTri = 15ETH

BƯỚC 4: MUA
Bob gọi muaTaiSan(1) {value: 20ETH}
→ Alice nhận 15ETH
→ Bob nhận lại 5ETH thừa
→ Bob trở thành chủ mới
→ Lịch sử: [DANG_KY, MUA_BAN]

BƯỚC 5: BÁN LẠI (tính năng v2)
Bob gọi niemYetBan(1, 20ETH)
Charlie gọi muaTaiSan(1) {value: 20ETH}
→ Charlie trở thành chủ mới
→ Lịch sử: [DANG_KY, MUA_BAN, MUA_BAN]

BƯỚC 5 (thay thế): CHUYỂN NHƯỢNG
Bob gọi chuyenNhuong(1, Charlie.address)
→ Charlie trở thành chủ (miễn phí, không cần ETH)
→ Lịch sử: [DANG_KY, MUA_BAN, CHUYEN_NHUONG]
```

---

## 📊 Phần 12 — Bảng tóm tắt toàn bộ Contract

| Thành phần         | Số lượng | Vai trò                         |
| -------------------- | ----------- | -------------------------------- |
| Custom Errors        | 14          | Thông báo lỗi tiết kiệm gas |
| Structs              | 2           | Khuôn mẫu dữ liệu            |
| State Variables      | 6           | Lưu trữ trên blockchain       |
| Events               | 4           | Thông báo sự kiện            |
| Modifiers            | 3           | Kiểm soát quyền truy cập     |
| Functions (external) | 9           | Các chức năng chính          |
| Functions (internal) | 1           | Hàm hỗ trợ nội bộ           |
| Thành phần | Số lượng | Vai trò |
|---|---|---|
| Custom Errors | 14 | Thông báo lỗi tiết kiệm gas |
| Structs | 2 | Khuôn mẫu dữ liệu |
| State Variables | 6 | Lưu trữ trên blockchain |
| Events | 4 | Thông báo sự kiện |
| Modifiers | 3 | Kiểm soát quyền truy cập |
| Functions (external) | 9 | Các chức năng chính |
| Functions (internal) | 1 | Hàm hỗ trợ nội bộ |

---

## 💡 Phần 13 — Bảng từ khóa Solidity hay gặp

| Từ khóa           | Ý nghĩa                                                                  |
| ------------------- | -------------------------------------------------------------------------- |
| `public`          | Ai cũng truy cập được từ trong lẫn ngoài                           |
| `external`        | Chỉ gọi từ bên ngoài contract (gas rẻ hơn`public`)                |
| `internal`        | Chỉ gọi từ bên trong hoặc contract con kế thừa                      |
| `view`            | Chỉ đọc, không sửa —**miễn phí gas** khi gọi                |
| `payable`         | Hàm/địa chỉ có thể nhận ETH                                         |
| `storage`         | Biến tham chiếu trực tiếp tới blockchain (tốn gas)                   |
| `memory`          | Biến tạm thời trong hàm, xóa khi hàm kết thúc (rẻ hơn)           |
| `calldata`        | Dữ liệu đầu vào, chỉ đọc, không copy (rẻ nhất)                  |
| `msg.sender`      | Địa chỉ ví của**người đang gọi hàm**                       |
| `msg.value`       | Số ETH (Wei) gửi kèm theo lệnh gọi hàm                               |
| `block.timestamp` | Thời gian block hiện tại (giây Unix từ 01/01/1970)                    |
| `emit`            | Phát ra một Event lên blockchain                                        |
| `revert`          | Hủy toàn bộ giao dịch, khôi phục trạng thái ban đầu              |
| `unchecked`       | Bỏ qua kiểm tra tràn số (tiết kiệm gas, chỉ dùng khi an toàn)     |
| `address(0)`      | Địa chỉ zero — nghĩa là "không có ai" / địa chỉ không hợp lệ |
| `address(this)`   | Địa chỉ của chính contract đang chạy                                |
| Từ khóa | Ý nghĩa |
|---|---|
| `public` | Ai cũng truy cập được từ trong lẫn ngoài |
| `external` | Chỉ gọi từ bên ngoài contract (gas rẻ hơn `public`) |
| `internal` | Chỉ gọi từ bên trong hoặc contract con kế thừa |
| `view` | Chỉ đọc, không sửa — **miễn phí gas** khi gọi |
| `payable` | Hàm/địa chỉ có thể nhận ETH |
| `storage` | Biến tham chiếu trực tiếp tới blockchain (tốn gas) |
| `memory` | Biến tạm thời trong hàm, xóa khi hàm kết thúc (rẻ hơn) |
| `calldata` | Dữ liệu đầu vào, chỉ đọc, không copy (rẻ nhất) |
| `msg.sender` | Địa chỉ ví của **người đang gọi hàm** |
| `msg.value` | Số ETH (Wei) gửi kèm theo lệnh gọi hàm |
| `block.timestamp` | Thời gian block hiện tại (giây Unix từ 01/01/1970) |
| `emit` | Phát ra một Event lên blockchain |
| `revert` | Hủy toàn bộ giao dịch, khôi phục trạng thái ban đầu |
| `unchecked` | Bỏ qua kiểm tra tràn số (tiết kiệm gas, chỉ dùng khi an toàn) |
| `address(0)` | Địa chỉ zero — nghĩa là "không có ai" / địa chỉ không hợp lệ |
| `address(this)` | Địa chỉ của chính contract đang chạy |

---

> **Các file trong dự án:**
>
> - [RealEstate.sol](file:///d:/BlockChain/RealEstate.sol) — Smart contract chính (đã tối ưu v2)
> - [RealEstate.test.js](file:///d:/BlockChain/test-project/test/RealEstate.test.js) — 60 bài kiểm thử tự động
> - [hardhat.config.js](file:///d:/BlockChain/test-project/hardhat.config.js) — Cấu hình môi trường test
