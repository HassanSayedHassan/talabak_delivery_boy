class DeliveryLogs {
  final String name;
  final String phone;
  final String inZone;
  final String destance;
  final String userID;
  final String playerID;
  final String status;
  final String statusDelivery;
  final String date;

  DeliveryLogs(
      {this.status,
      this.name,
      this.phone,
      this.destance,
      this.inZone,
      this.statusDelivery,
      this.userID,
      this.playerID,
      this.date});

  factory DeliveryLogs.fromJson(Map<String, dynamic> json) {
    return DeliveryLogs(
        status: json['status'],
        name: json['name'],
        phone: json['phone'],
        statusDelivery: json['statusDelivery'],
        destance: json['destance'],
        inZone: json['inZone'],
        userID: json['userID'],
        playerID: json['playerID'],
        date: json['date']);
  }
}
