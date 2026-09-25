Thành viên 5 – Smart Contract và các từ khóa quan trọng

**Đề tài:** Ứng dụng Blockchain trong quản lý quyền sở hữu và giao dịch bất động sản  

## 2.5.1. Smart Contract là gì?

Smart Contract (hợp đồng thông minh) là chương trình được triển khai trên blockchain. Khi người dùng gửi giao dịch gọi một chức năng, chương trình kiểm tra các điều kiện đã viết sẵn và thực hiện thao tác tương ứng. Kết quả giao dịch được ghi nhận trên blockchain nếu giao dịch thành công.

Trong đề tài bất động sản, Smart Contract có thể hỗ trợ quản lý thông tin về chủ sở hữu, kiểm tra người đang yêu cầu bán có đúng là chủ sở hữu được ghi trong hệ thống hay không, kiểm tra căn nhà/đất có được đánh dấu là đang rao bán hay không, và chỉ cho phép chuyển quyền sở hữu trong dữ liệu của hợp đồng khi các điều kiện đã đặt ra được đáp ứng.

**Ví dụ quy trình minh họa:** A được ghi nhận là chủ sở hữu của bất động sản mã 101; A đăng bán với giá 2 ETH. B gửi giao dịch mua kèm đúng 2 ETH. Chương trình kiểm tra bất động sản còn được rao bán, người bán trong dữ liệu là A và tiền gửi đáp ứng giá. Nếu mọi điều kiện đúng, hợp đồng cập nhật chủ sở hữu trong dữ liệu từ A sang B và xử lý tiền theo logic đã lập trình. Nếu một điều kiện sai, giao dịch bị từ chối và cập nhật trong giao dịch đó bị hoàn tác.

**Giới hạn cần trình bày rõ:** Bản ghi trên blockchain không tự thay thế giấy chứng nhận quyền sử dụng đất hoặc thủ tục đăng ký, xác thực và sang tên theo pháp luật. Các thông tin từ bên ngoài blockchain, như tính hợp pháp của giấy tờ, phải được cơ quan/người có thẩm quyền xác minh và đưa vào hệ thống theo quy trình phù hợp. Smart Contract chỉ tự động kiểm tra những dữ liệu và quy tắc mà chương trình có thể truy cập.

## 2.5.2. Bốn từ khóa quan trọng trong Solidity

|Từ khóa|Ý nghĩa dễ hiểu|Ví dụ ngắn trong giao dịch bất động sản|
|-|-|-|
|`require(điều\_kiện, "thông báo")`|Kiểm tra một điều kiện; nếu sai thì giao dịch gọi hàm thất bại và các thay đổi trạng thái của giao dịch bị hoàn tác.|`require(ownerOf\[id] == msg.sender, "Khong phai chu so huu");` – chỉ người được ghi là chủ sở hữu mới được thực hiện thao tác này.|
|`msg.sender`|Địa chỉ trực tiếp gọi hàm trong lần gọi hiện tại. Nếu một contract khác gọi tiếp hàm, đây là địa chỉ của contract gọi trực tiếp.|`require(msg.sender == seller, "Sai nguoi ban");` – kiểm tra địa chỉ gọi có phải người bán được lưu hay không.|
|`msg.value`|Số **wei** được gửi kèm lần gọi hàm hiện tại; hàm phải cho phép nhận ETH (`payable`) nếu muốn nhận giá trị này. `1 ETH = 10^18 wei`.|`require(msg.value == price, "Sai so tien");` – kiểm tra người mua gửi đúng số tiền được lưu trong biến `price` (tính bằng wei).|
|`address(0)`|Địa chỉ toàn số 0, thường dùng làm giá trị đặc biệt để biểu thị chưa có địa chỉ hợp lệ.|`require(buyer != address(0), "Dia chi khong hop le");` – tránh ghi người mua là địa chỉ 0.|

Các dòng trên **chỉ là ví dụ riêng lẻ để giải thích từ khóa**, không phải hợp đồng hoàn chỉnh; `ownerOf`, `id`, `seller`, `price`, `buyer` là những biến minh họa. Trong ứng dụng thực tế cần thiết kế thêm xác thực, quy trình thanh toán, xử lý sai sót và bảo mật.

### Ví dụ code ngắn dùng cả bốn từ khóa

```solidity
// Đoạn hàm minh họa, đặt bên trong một contract Solidity.
// gia tính bằng wei. Hàm này chỉ kiểm tra điều kiện, chưa chuyển tiền hay quyền sở hữu.
function kiemTraMua(address nguoiBan, uint256 gia) external payable {
    require(nguoiBan != address(0), "Dia chi nguoi ban khong hop le");
    require(msg.sender != nguoiBan, "Khong tu mua cua minh");
    require(msg.value == gia, "So tien gui khong dung gia");
}
```

Ở đây, `address(0)` giúp phát hiện địa chỉ người bán không hợp lệ; `msg.sender` là địa chỉ gọi hàm; `msg.value` là số wei gửi kèm; còn `require` từ chối giao dịch nếu một điều kiện không đạt. **Không dùng hàm này để nhận tiền thật:** đây chỉ là ví dụ học tập, không có bước chuyển tiền hoặc xử lý quyền sở hữu.

## 2.5.3. Tình huống diễn giải ngắn khi thuyết trình

> Khi người mua B bấm mua, `msg.sender` cho biết địa chỉ đang gọi chức năng. `msg.value` cho biết B gửi bao nhiêu tiền. `require` kiểm tra các điều kiện, chẳng hạn số tiền có đúng giá và bất động sản có đang rao bán không. `address(0)` giúp phát hiện một địa chỉ không hợp lệ khi lưu người nhận quyền sở hữu. Nếu kiểm tra không đạt, giao dịch thất bại; nếu đạt, chương trình mới tiếp tục các bước đã lập trình.

## 2.5.4. Phần việc bàn giao

* Nội dung lý thuyết về Smart Contract và vai trò kiểm tra điều kiện giao dịch.
* Giải thích kèm ví dụ cho `require`, `msg.sender`, `msg.value`, `address(0)`.
* Ví dụ trình bày ngắn gọn để đưa vào báo cáo hoặc dùng khi thuyết trình.

Phần việc này **không yêu cầu viết hoặc triển khai hợp đồng Solidity hoàn chỉnh**.

