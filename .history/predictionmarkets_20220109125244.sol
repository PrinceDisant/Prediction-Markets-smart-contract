// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

/**
 * @title PredictionMarket
 * @dev The contract constructor is payable and sets the number of shares in 
the market (Listing 10-2). It takes a duration as its only argument and uses 
it to set the deadline
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