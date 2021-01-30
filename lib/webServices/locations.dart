import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Locations {
  FirebaseAuth auth = FirebaseAuth.instance;
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

    SharedPreferences getUserID;
    Future<SharedPreferences> preferences = SharedPreferences.getInstance();
    getUserID = await preferences;
    String userID = getUserID.getString("userID");

    StreamSubscription<Position> positionStream =
        Geolocator.getPositionStream().listen((Position position) {
      if (position != null) {
        FirebaseFirestore.instance
            .collection('locations')
            .doc(auth.currentUser.uid)
            .get()
            .then((DocumentSnapshot documentSnapshot) {
          if (documentSnapshot.exists) {
            // ignore: deprecated_member_use
            firestore
                .collection('locations')
                .document(auth.currentUser.uid)
                .update({
              'latitude': position.latitude,
              'longitude': position.longitude,
            });
          } else {
            /* firestore
                .collection('locations')
                .document(auth.currentUser.uid)
                .set({
              'latitude': position.latitude,
              'longitude': position.longitude,
              'uid': auth.currentUser.uid,
              
              'status': "$status"
            }); */
            firestore
                .collection('deliveryBoy_locations')
                .document(auth.currentUser.uid)
                .set({
              'latitude': position.latitude,
              'longitude': position.longitude,
              'uid': auth.currentUser.uid,
              'orders_number': 0,
              'status': "$status"
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
