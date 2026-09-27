// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract PropertyRegistration {

    struct Property {
        uint256 id;        // Mã bất động sản
        address owner;     // Chủ sở hữu
        uint256 price;     // Giá bán
        bool exists;       // BĐS có tồn tại hay không
        bool isSold;       // BĐS đã bán hay chưa
        bool isListed;     // BĐS có đang được niêm yết bán hay không
    }

    mapping(uint256 => Property) public properties;

    // Require 1: Mã bất động sản phải hợp lệ
    modifier validPropertyId(uint256 propertyId) {
        require(
            propertyId > 0,
            "Ma bat dong san khong hop le"
        );
        _;
    }

    // Require 2: Bất động sản không được đăng trùng
    modifier propertyNotExists(uint256 propertyId) {
        require(
            !properties[propertyId].exists,
            "Bat dong san da ton tai"
        );
        _;
    }

    // Đăng bất động sản
    function registerProperty(
        uint256 propertyId,
        uint256 price
    )
        public
        validPropertyId(propertyId)
        propertyNotExists(propertyId)
    {
        // Require 3: Giá bán phải lớn hơn 0
        require(
            price > 0,
            "Gia ban phai lon hon 0"
        );

        properties[propertyId] = Property({
            id: propertyId,
            owner: msg.sender,
            price: price,
            exists: true,
            isSold: false,
            isListed: true
        });
    }
}