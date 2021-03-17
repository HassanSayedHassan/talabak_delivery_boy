class RateDBModel {
  final String id;
  final String deliveryBoyID;
  final String orderID;
  final String rating;
  final String userName;
  final String date;

  RateDBModel({this.id, this.deliveryBoyID, this.orderID, this.rating, this.date, this.userName});

  factory RateDBModel.fromJson(Map<String, dynamic> json) {
    return RateDBModel(
        id: json['id'],
        deliveryBoyID: json['deliveryBoyID'],
        orderID: json['orderID'],
        rating: json['rating'],
        date: json['date'],
        userName: json['userName']);
  }
}