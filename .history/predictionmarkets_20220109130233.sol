// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

/**
 * @title PredictionMarket
 * @dev Trading is divided into shares in a prediction market. 
 *  If the answer is Yes, each share pays out 100 wei; 
 *  if the answer is No, each share pays out 0 wei. 
 *  The price per share indicates the market's likelihood of resolving to Yes in this fashion. 
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
    uint public constant TX_FEE_NUMERATOR = 1;
    uint public constant TX_FEE_DENOMINATOR = 500;

    address public owner;
    Result public result;
    
    uint public deadline;
    uint public counter;
    uint public collateral;

    mapping(uint => Order) public orders;
    mapping(address => uint) public shares;
    mapping(address => uint) public balances;
    
    event OrderPlaced(uint orderId, 
        address user, 
        OrderType 
        orderType, 
        uint amount, 
        uint price);
    event TradeMatched(uint orderId, 
        address user, 
        uint amount);
    event OrderCanceled(uint orderId);
    event Payout(address user, 
        uint amount);
    
    constructor(uint duration) payable {
        require(msg.value > 0);
        owner = msg.sender;
        deadline = block.timestamp + duration;
        shares[msg.sender] = msg.value / 100;
        collateral = msg.value;
    }

    function orderBuy (uint price) public payable {
 require(now < deadline);
 require(msg.value > 0);
 require(price >= 0);
 require(price <= 100);
 uint amount = msg.value / price;
 
}