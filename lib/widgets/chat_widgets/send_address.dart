import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:talabak_delivery_boy/utili_class.dart';
import 'package:toast/toast.dart';


class Send_Address  {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  var channelId,current_email,context;
  Send_Address(this.channelId,this.current_email,this.context);
  var appcolor = Color(0xFF12c0c7);

  Position position;

  Future<Position> _determinePosition() async {
    startLoading();
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      closeLoading();
      HelpFun().my_Toast("من فضلك قم بتفعيل خدمة تحديد المكان", context);
      return Future.error('Location services are disabled.');

    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      closeLoading();
      return Future.error(
          'Location permissions are permantly denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        closeLoading();
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }

    position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

  }

  fun_send_address () {
    _determinePosition().then((value) {
      if (position.longitude.toString().isNotEmpty && position.latitude.toString().isNotEmpty) {
        closeLoading();
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return Center(
                child: Container(
                  color: appcolor,
                  width: 300,
                  height: 300,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/gmap.png'),
                      RaisedButton.icon(
                        icon: Text('Shere Your Location'),
                        label: Icon(Icons.send,color: appcolor,size: 40,),
                        color: Colors.white,
                        elevation: 10,
                        onPressed: () async {
                          var stats = false;
                          var connectivityResult = await (Connectivity()
                              .checkConnectivity());
                          if (connectivityResult ==
                              ConnectivityResult.mobile) {
                            stats = true;
                          } else if (connectivityResult ==
                              ConnectivityResult.wifi) {
                            stats = true;
                          }
                          if (stats) {
                            firestore.collection('orders')
                                .doc(channelId)
                                .collection('messages')
                                .add({
                              'message':
                              "${position.longitude.toString()}" +
                                  " " +
                                  "${position.latitude.toString()}",
                              'type': 'address',
                              'data': DateTime.now()
                                  .toIso8601String()
                                  .toString(),
                              'sederEmail': current_email,
                            }).then((value) =>
                                Navigator.of(context).pop());
                          }
                          else {
                            closeLoading();
                            my_Toast('تأكد من الاتصال بالنترنت');
                          }
                        },
                      ),
                    ],

                  ),
                ),
              );
            });
      }
    });

  }

  void startLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              children: [
                new CircularProgressIndicator(strokeWidth: 5,backgroundColor: appcolor,),
                new Text("Loading..."),
              ],
            ),
          ),
        );
      },
    );
  }
  void closeLoading(){
    Navigator.pop(context);
  }
  void my_Toast(String mess) {
    Toast.show(mess, context,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  }
}
