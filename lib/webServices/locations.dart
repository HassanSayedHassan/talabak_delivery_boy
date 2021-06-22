import 'dart:async';
import 'package:background_location/background_location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talabak_delivery_boy/webServices/postViewModel.dart';

class Locations {
  final databaseRef = FirebaseDatabase.instance.reference();
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

  getLocationContenously(String status,String userID,String playerID,String name,String phone) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    var status=false;
    /// StreamSubscription<Position> positionStream =
    ///  29.3083333
    /// 30.8447222
    Geolocator.getPositionStream().listen((Position position) async {
      if (position != null) {
        var distance = Geolocator.distanceBetween(
            position.latitude, position.longitude, 29.3083333, 30.8447222);
        print("distance123    $userID");

        firestore
            .collection('delivery_boys')
            .doc(userID)
            .snapshots()
            .listen((DocumentSnapshot documentSnapshot) {
          if (documentSnapshot.exists) {
            status = documentSnapshot.get('status');
          }
        });

        if (distance > 25000 && status) {
          /// out of zoom
          PostViewModel postViewModel = new PostViewModel();
          DateTime date = DateTime.now();

           postViewModel.deliveryBoyLogs(phone, name, playerID, 'out of zone',
               'false', userID, distance.toString(), date.toString());

          del_boy_off(userID);
        }

        if (userID != null) {
          print("distance username   $userID");
          databaseRef.child('locations').child(userID).set({'latitude': position.latitude, 'longitude': position.longitude});
          print ("latituderrrrrrrrrr ${position.latitude} ");

          await BackgroundLocation.startLocationService(
              distanceFilter: 20);
          BackgroundLocation.getLocationUpdates((location) {


            print('\nLatitude:  ${location.latitude}Longitude: ${location.longitude}Altitude: ${location.altitude}');
          });
          // }
        }
      }
    });
  }
  //
   getLocationCons(String userID)async{


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
  del_boy_off(uid) {
    FirebaseFirestore.instance.collection('delivery_boys').doc(uid).update({
      "status": false,
    }).whenComplete(() {
    });
  }
}
