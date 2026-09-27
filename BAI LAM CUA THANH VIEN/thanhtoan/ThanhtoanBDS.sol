// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title RealEstatePayment
 * @dev Quản lý thanh toán bất động sản, kiểm tra giá và xử lý tiền thừa/thiếu
 */
contract RealEstatePayment {
    struct Property {
        uint256 id;
        address payable seller;
        uint256 price; // Tính theo Wei
        bool isSold;
    }

    mapping(uint256 => Property) public properties;

    // Sự kiện ghi log trên Blockchain
    event PropertyListed(uint256 indexed id, address seller, uint256 price);
    event PropertyPurchased(uint256 indexed id, address buyer, uint256 pricePaid);
    event ExcessRefunded(address indexed buyer, uint256 refundAmount);

    // Đăng bán Bất động sản
    function listProperty(uint256 _id, uint256 _priceInEther) external {
        require(properties[_id].price == 0, "BDS da ton tai");
        
        uint256 priceInWei = _priceInEther * 1 ether;

        properties[_id] = Property({
            id: _id,
            seller: payable(msg.sender),
            price: priceInWei,
            isSold: false
        });

        emit PropertyListed(_id, msg.sender, priceInWei);
    }

    // Mua Bất động sản & Xử lý thanh toán
    function buyProperty(uint256 _id) external payable {
        Property storage prop = properties[_id];

        require(prop.price > 0, "BDS khong ton tai");
        require(!prop.isSold, "BDS da duoc ban");
        
        // Điều kiện 1: Kiểm tra đủ tiền (Require 4)
        require(msg.value >= prop.price, "Thanh toan thieu: So tien khong du");

        // Cập nhật trạng thái
        prop.isSold = true;

        uint256 price = prop.price;

        // Điều kiện 2: Xử lý trường hợp dư tiền (Hoàn lại cho người mua)
        if (msg.value > price) {
            uint256 excessAmount = msg.value - price;
            (bool refundSuccess, ) = payable(msg.sender).call{value: excessAmount}("");
            require(refundSuccess, "Hoan tien thua that bai");
            emit ExcessRefunded(msg.sender, excessAmount);
        }

        // Chuyển đúng giá trị BĐS cho người bán
        (bool paySuccess, ) = prop.seller.call{value: price}("");
        require(paySuccess, "Chuyen tien cho nguoi ban that bai");

        emit PropertyPurchased(_id, msg.sender, price);
    }
}
