import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talabak_delivery_boy/webServices/postViewModel.dart';

class Locations {
  // FirebaseAuth auth = FirebaseAuth.instance;
  Future<Position> getCurrentLocatiosn() async {
    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print("position $position $isLocationServiceEnabled");
    return position;
  }

  getLastKnownPosition() async {
    Position position = await Geolocator.getLastKnownPosition();
    print("lastposition $position");
  }

  Future<double> getDestanceBetween(double startLatitude, double startLongitude,
      double endLatitude, double endLongitude) async {
    double distanceInMeters = Geolocator.distanceBetween(
            startLatitude, startLongitude, endLatitude, endLongitude) /
        1000;

    return distanceInMeters;
  }

  getLocationContenously(String status) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userID = prefs.getString("userID");
    String name = prefs.getString("name");
    String playerID = prefs.getString("playerID");
    String phone = prefs.getString("phone");

    /// StreamSubscription<Position> positionStream =
    ///  29.3083333
    /// 30.8447222
    Geolocator.getPositionStream().listen((Position position) {
      if (position != null) {
        var distance = Geolocator.distanceBetween(
            position.latitude, position.longitude, 29.3083333, 30.8447222);
        print("distance    $distance");
        if (distance > 25000) {
          /// out of zoon
          ///
          PostViewModel postViewModel = new PostViewModel();
          DateTime date = DateTime.now();

          postViewModel.deliveryBoyLogs(phone, name, playerID, 'out of zone',
              'false', userID, distance.toString(), date.toString());
        }
        FirebaseFirestore.instance
            .collection('locations')
            .doc(userID)
            .get()
            .then((DocumentSnapshot documentSnapshot) {
          if (documentSnapshot.exists) {
            // ignore: deprecated_member_use
            firestore.collection('locations').doc(userID).update({
              'latitude': position.latitude,
              'longitude': position.longitude,
            });
          } else {
            firestore.collection('locations').doc(userID).set({
              'latitude': position.latitude,
              'longitude': position.longitude,
            });
          }
        });
      }
    });
  }

  Future<String> checkRequestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    switch (permission) {
      case LocationPermission.denied:
        return "denied";
        break;
      case LocationPermission.deniedForever:
        openlocationSetting();
        return 'deniedForEver';
        break;

      case LocationPermission.whileInUse:
        print("location permission while in use");
        getCurrentLocatiosn();
        getLastKnownPosition();
        return "location permission while in use";
        break;
      case LocationPermission.always:
        print("location permission always");
        getCurrentLocatiosn();
        getLastKnownPosition();

        return "location permission always";

        break;
    }
    return "0";
  }

  requestLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();

    print("permission $permission");
  }

  openlocationSetting() async {
    await Geolocator.openLocationSettings();
  }
}
