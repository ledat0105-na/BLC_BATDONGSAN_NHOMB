// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract PropertyValidation {

    struct Property {
        uint256 id;
        bool exists;
        bool isSold;
    }

    mapping(uint256 => Property) public properties;

    // Require 1: Bất động sản phải tồn tại
    modifier propertyExists(uint256 propertyId) {
        require(
            properties[propertyId].exists,
            "Property does not exist"
        );
        _;
    }

    // Require 2: Bất động sản chưa được bán
    modifier propertyNotSold(uint256 propertyId) {
        require(
            !properties[propertyId].isSold,
            "Property already sold"
        );
        _;
    }

    // Hàm kiểm tra tổng hợp 2 điều kiện
    function checkProperty(uint256 propertyId)
        public
        view
        propertyExists(propertyId)
        propertyNotSold(propertyId)
        returns (bool)
    {
        return true;
    }

    // Hàm test dữ liệu mẫu
    function setProperty(
        uint256 propertyId,
        bool exists,
        bool isSold
    ) public {
        properties[propertyId] = Property(
            propertyId,
            exists,
            isSold
        );
    }
}