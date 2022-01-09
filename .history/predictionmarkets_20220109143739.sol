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
    
    /*
    * @dev Constructor
    * @param _owner The owner of the prediction market
    * @param _deadline The deadline of the prediction market
    * @param _collateral The collateral required to participate in the prediction market
    */

    constructor(uint duration) payable {
        require(msg.value > 0);

        owner = msg.sender;
        deadline = block.timestamp + duration;
        shares[msg.sender] = msg.value / 100;
        collateral = msg.value;
    }

    
    function orderBuy (uint price) public payable {
        require(block.timestamp < deadline);
        require(msg.value > 0);
        require(price >= 0);
        require(price <= 100);
        uint amount = msg.value / price;
        counter++;
        orders[counter] = Order(msg.sender, OrderType.Buy, 
        amount, price);
        emit OrderPlaced(counter, msg.sender, OrderType.Buy, amount, price);
    }

    function orderSell (uint price, uint amount) public payable {
        require(block.timestamp < deadline);
        require(shares[msg.sender] >= amount);
        require(msg.value > 0);
        require(price >= 0);
        require(price <= 100);

        shares[msg.sender] -= amount;
        
        counter++;
        orders[counter] = Order(msg.sender, OrderType.Sell, amount, price);
        
        emit OrderPlaced(counter, msg.sender, OrderType.Sell, amount, price);
    }
    
    function tradeBuy (uint orderId) public payable {
        Order storage order = orders[orderId];
        
        require(block.timestamp < deadline);
        require(order.user != msg.sender);
        require(order.orderType == OrderType.Sell);
        require(order.amount > 0);
        require(msg.value > 0);
        require(msg.value <= order.amount * order.price);
        
        uint amount = msg.value / order.price;
        uint fee = (amount * order.price) * TX_FEE_NUMERATOR / TX_FEE_DENOMINATOR;
        uint feeShares = amount * TX_FEE_NUMERATOR / TX_FEE_DENOMINATOR;
        
        shares[msg.sender] += (amount - feeShares);
        shares[owner] += feeShares;
        
        balances[order.user] += (amount * order.price) - fee;
        balances[owner] += fee;
        
        order.amount -= amount;
        if (order.amount == 0)
            delete orders[orderId];
        
        emit TradeMatched(orderId, msg.sender, amount);
    }

    /*
     * @dev Trade a sell order for shares
     * @param orderId The id of the sell order
     * @param amount The amount of shares to trade
     * @return The amount of shares traded
     */
    function tradeSell (uint orderId, uint amount) public payable {
        Order storage order = orders[orderId];
        
        require(block.timestamp < deadline);
        require(order.user != msg.sender);
        require(order.orderType == OrderType.Buy);
        require(order.amount > 0);
        require(amount <= order.amount);
        require(shares[msg.sender] >= amount);
        require(msg.value > 0);
        require(msg.value <= amount * order.price);

        uint fee = (amount * order.price) * TX_FEE_NUMERATOR / TX_FEE_DENOMINATOR;
        uint feeShares = amount * TX_FEE_NUMERATOR / TX_FEE_DENOMINATOR;
        
        shares[msg.sender] -= amount;
        shares[order.user] += (amount - feeShares);
        shares[owner] += feeShares;
        
        balances[msg.sender] += (amount * order.price) - fee;
        balances[owner] += fee;
        
        order.amount -= amount;
        if (order.amount == 0)
            delete orders[orderId];
        
        emit TradeMatched(orderId, msg.sender, amount);
    }

    /*
    * @dev Cancels an order
    * @param orderId The order to cancel
    */
    function cancelOrder (uint orderId) public {
        Order storage order = orders[orderId];
        
        require(block.timestamp < deadline);
        require(order.user == msg.sender);
        require(order.orderType == OrderType.Buy);
        require(order.amount > 0);
        
        if (order.orderType == OrderType.Buy) {
            balances[msg.sender] += order.amount * order.price;
        }
        else{
            shares[msg.sender] += order.amount;
        }

        delete orders[orderId];        
        emit OrderCanceled(orderId);
    }

    
    /*
    * @dev resolves the prediction market
    */
    function resolve (bool _result) public {
        require(block.timestamp > deadline);
        require(msg.sender == owner);
        require(result == Result.Open);

        result = _result ? Result.Yes : Result.No;
        
        if(result == Result.No)
            balances[owner] += collateral;

        uint amount = shares[msg.sender];
        emit Payout(msg.sender, amount);
    }

    /*
    * @dev withdraws the payout
    */
    function withdraw() public {
        require(block.timestamp > deadline);
        require(msg.sender == owner);
        require(result == Result.Open);

        uint payout = balances[msg.sender];
        balances[msg.sender] = 0;
        
        if (result == Result.Yes) {
            payout += shares[msg.sender] * 100;
            shares[msg.sender] = 0;
        }

        payable (msg.sender).transfer(payout);
        emit Payout(msg.sender, payout);
    }
    /*
    * @dev Returns the result of the prediction market
    * @return Result The result of the prediction market
    */
    function getResult() public view returns (Result) {
        return result;
    }
    
    /*
    * @dev Returns the deadline of the prediction market
    * @return uint The deadline of the prediction market
    */
    function getDeadline() public view returns (uint) {
        return deadline;
    }

    /*
    * @dev Returns the collateral required to participate in the prediction market
    * @return uint The collateral required to participate in the prediction market
    */
    function getCollateral() public view returns (uint) {
        return collateral;
    }

    /*
    * @dev Returns the amount of shares owned by the sender
    * @return uint The amount of shares owned by the sender
    */
    function getShares() public view returns (uint) {
        return shares[msg.sender];
    }

    /*
    * @dev Returns the balance of the sender
    
    function getBalances() public view returns (uint) {
        return balances[msg.sender];
    }

    function getOrder(uint orderId) public view returns (Order memory) {
        Order storage order = orders[orderId];
        require(order.user == msg.sender);
        return order;
    }

}