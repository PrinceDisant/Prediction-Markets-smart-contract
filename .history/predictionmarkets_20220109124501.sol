contract PredictionMarket {
 enum OrderType { Buy, Sell }
 enum Result { Open, Yes, No }
 struct Order {
 address user;
 OrderType orderType;
 uint amount;
 uint price;
 }