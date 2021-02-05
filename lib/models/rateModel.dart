class RateModel {
  final String id;
  final String dboyID;
  final String orderID;
  final String rate;
  final String status;

  RateModel({this.id, this.dboyID, this.orderID, this.rate, this.status});

  factory RateModel.fromJson(Map<String, dynamic> json) {
    return RateModel(
        id: json['id'],
        dboyID: json['dboyID'],
        orderID: json['orderID'],
        rate: json['rate'],
        status: json['status']);
  }
}
