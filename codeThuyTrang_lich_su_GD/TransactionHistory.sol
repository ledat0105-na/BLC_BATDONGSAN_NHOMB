// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TransactionHistory {

    struct Transaction {
        uint256 transactionId;
        uint256 propertyId;
        address seller;
        address buyer;
        uint256 price;
        uint256 timestamp;
        string status;
    }

    uint256 public transactionCount;

    mapping(uint256 => Transaction) public transactions;

    // Ghi nhận giao dịch
    function recordTransaction(
        uint256 propertyId,
        address seller,
        address buyer,
        uint256 price,
        string memory status
    ) public {

        transactionCount++;

        transactions[transactionCount] = Transaction(
            transactionCount,
            propertyId,
            seller,
            buyer,
            price,
            block.timestamp,
            status
        );
    }

    // Xem thông tin giao dịch
    function getTransaction(
        uint256 transactionId
    )
        public
        view
        returns (Transaction memory)
    {
        return transactions[transactionId];
    }
}
