import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:talabak_delivery_boy/models/userModel.dart';

import 'package:talabak_delivery_boy/models/deliveryLogs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostViewModel {
  String baseUrl = "http://talabkfayoum.com";
  Future<UserModel> login(String phone, String password) async {
    var response = await http.post('$baseUrl/loginDelivery.php', body: {
      'phone': phone,
      'password': password,
    });
    if (response.statusCode == 200) {
      if (UserModel.fromJson(convert.json.decode(response.body)).status ==
          'success') {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('name',
            UserModel.fromJson(convert.json.decode(response.body)).name);
        prefs.setString('email',
            UserModel.fromJson(convert.json.decode(response.body)).email);
        prefs.setString('userID',
            UserModel.fromJson(convert.json.decode(response.body)).userID);

        prefs.setString('playerID',
            UserModel.fromJson(convert.json.decode(response.body)).playerID);
        prefs.setString('phone',
            UserModel.fromJson(convert.json.decode(response.body)).phone);
        prefs.setString('imageURL',
            UserModel.fromJson(convert.json.decode(response.body)).imageUrl);

        return UserModel.fromJson(convert.json.decode(response.body));
      } else {
        return UserModel.fromJson(convert.json.decode(response.body));
      }
    } else {
      return UserModel.fromJson(convert.json.decode(response.body));
    }
  }

  Future<UserModel> updateDeliveryBoyData(String phoneNum, String password,
      String playerID, String imageURL) async {
    var response = await http.post('$baseUrl/updateDeliveryBoyData.php', body: {
      'phone': phoneNum,
      'password': password,
      'imageUrl': imageURL,
      'playerID': playerID,
    });
    String status = "";
    if (response.statusCode == 200) {
      if (UserModel.fromJson(convert.json.decode(response.body)).status ==
          'registeration success') {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('name',
            UserModel.fromJson(convert.json.decode(response.body)).name);
        prefs.setString('email',
            UserModel.fromJson(convert.json.decode(response.body)).email);
        prefs.setString('userID',
            UserModel.fromJson(convert.json.decode(response.body)).userID);

        prefs.setString('playerID',
            UserModel.fromJson(convert.json.decode(response.body)).playerID);
        prefs.setString('phone',
            UserModel.fromJson(convert.json.decode(response.body)).phone);
        prefs.setString('imageURL',
            UserModel.fromJson(convert.json.decode(response.body)).imageUrl);
      }
      status = UserModel.fromJson(convert.json.decode(response.body)).status;
      print('register:$status');
      return UserModel.fromJson(convert.json.decode(response.body));
    } else {
      status = "please check your connection";
      print('register:$status');
      return UserModel.fromJson(convert.json.decode(response.body));
    }
  }

  Future<DeliveryLogs> deliveryBoyLogs(
      String phoneNum,
      String name,
      String playerID,
      String statusDelivery,
      String inZone,
      String userID,
      String destance,
      String date) async {
    var response = await http.post('$baseUrl/deliveryLogs.php', body: {
      'phone': phoneNum,
      'name': name,
      'status': statusDelivery,
      'playerID': playerID,
      'inZone': inZone,
      'userID': userID,
      'destance': destance,
      'date': date
    });
    String status = "";
    if (response.statusCode == 200) {
      status = DeliveryLogs.fromJson(convert.json.decode(response.body)).status;
      print('register:$status');
      return DeliveryLogs.fromJson(convert.json.decode(response.body));
    } else {
      status = "please check your connection";
      print('register:$status');
      return DeliveryLogs.fromJson(convert.json.decode(response.body));
    }
  }
}
