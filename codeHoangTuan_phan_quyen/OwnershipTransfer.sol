// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract OwnershipTransfer {

    struct Property {
        uint256 id;
        address owner;
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

    // Require 2: Chỉ chủ sở hữu mới được chuyển
    modifier onlyOwner(uint256 propertyId) {
        require(
            msg.sender == properties[propertyId].owner,
            "Only owner can transfer"
        );
        _;
    }

    // Require 3: Bất động sản chưa được bán
    modifier propertyNotSold(uint256 propertyId) {
        require(
            !properties[propertyId].isSold,
            "Property already sold"
        );
        _;
    }

    // Tạo dữ liệu bất động sản mẫu
    function setProperty(
        uint256 propertyId,
        address owner,
        bool isSold
    ) public {
        properties[propertyId] = Property(
            propertyId,
            owner,
            true,
            isSold
        );
    }

    // Chuyển quyền sở hữu
    function transferOwnership(
        uint256 propertyId,
        address newOwner
    )
        public
        propertyExists(propertyId)
        onlyOwner(propertyId)
        propertyNotSold(propertyId)
    {
        require(
            newOwner != address(0),
            "Invalid new owner"
        );

        require(
            newOwner != msg.sender,
            "Cannot transfer to yourself"
        );

        properties[propertyId].owner = newOwner;
    }
}
