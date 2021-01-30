class UserModel {
  final String name;
  final String phone;
  final String email;
  final String imageUrl;
  final String userID;
  final String playerID;
  final String status;

  UserModel(
      {this.status,
      this.name,
      this.phone,
      this.email,
      this.imageUrl,
      this.userID,
      this.playerID});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      status: json['status'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      imageUrl: json['imageUrl'],
      userID: json['userID'],
      playerID: json['playerID'],
    );
  }
}
