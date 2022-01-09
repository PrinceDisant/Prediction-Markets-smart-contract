// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

/**
 * @title PredictionMarket
 * @dev Store & retrieve value in a variable
 */
contract PredictionMarket {
    enum OrderType { Buy, Sell }
    enum Result { Open, Yes, No }
    struct Order {
        address user;
        OrderType orderType;
        uint amount;
        uint price;
    }
}