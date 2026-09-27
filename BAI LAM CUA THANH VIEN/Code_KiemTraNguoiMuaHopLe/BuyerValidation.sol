// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title BuyerValidation
 * @notice Thư viện hỗ trợ kiểm tra tính hợp lệ của người mua tài sản
 */
library BuyerValidation {
    // Custom errors for validation
    error TaiSanChuaNiemYet();
    error ChuSoHuuKhongTheMua(uint256 id);
    error ThanhToanKhongDu(uint256 required, uint256 sent);

    /**
     * @notice Kiểm tra điều kiện khi mua BĐS
     */
    function validateBuyer(
        bool dangBanHang,
        address chuSoHuu,
        address buyer,
        uint256 propertyId,
        uint256 giaTri,
        uint256 sentValue
    ) internal pure {
        if (!dangBanHang) revert TaiSanChuaNiemYet();
        if (buyer == chuSoHuu) revert ChuSoHuuKhongTheMua(propertyId);
        if (sentValue < giaTri) revert ThanhToanKhongDu(giaTri, sentValue);
    }
}
