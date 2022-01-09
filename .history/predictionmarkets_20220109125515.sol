// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

/**
 * @title PredictionMarket
 * @dev Trading is divided into shares in a prediction market. 
    If the answer is Yes, each share pays out 100 wei; 
    if the answer is No, each share pays out 0 wei. 
    The price per share indicates the market's likelihood of resolving to Yes in this fashion. 
 *  If the previous market's price is 60, the market believes there is a 60% chance that Ethereum will be above $2,000 at the start of 2019.
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