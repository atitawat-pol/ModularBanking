// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

interface InterestRateModule {
    function rate() external view returns(uint256);
    // declare callable function
    function calculateInterest(address user, uint256 balances) external view returns(uint256);
}