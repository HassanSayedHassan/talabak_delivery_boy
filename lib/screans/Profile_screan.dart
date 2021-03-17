import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_switch/custom_switch.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talabak_delivery_boy/screans/Edit_profile.dart';
import 'package:talabak_delivery_boy/screans/log_in_screan.dart';
import 'package:talabak_delivery_boy/webServices/deliverytime.dart';
import 'package:talabak_delivery_boy/webServices/fire_base_deliverytime.dart';
import 'package:talabak_delivery_boy/webServices/locations.dart';
import 'package:talabak_delivery_boy/webServices/postViewModel.dart';
import 'package:toast/toast.dart';

class Profile_Screan extends StatefulWidget {
  @override
  _Profile_ScreansState createState() => _Profile_ScreansState();
}

class _Profile_ScreansState extends State<Profile_Screan> {
  // FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  PostViewModel postViewModel = new PostViewModel();
  String name = 'hi';
  String profile_image;
  String current_uid;
  String phone;
  String playerID;
  String destance;
  double long = 0.0;
  double lat = 0.0;
  bool status = false;
  bool inZone = false;
  bool beOffline = false;
  Locations locations = new Locations();
  var appcolor = Color(0xFF12c0c7);
  double  rates = 0.0;
  String userID;

  var flag = "123";
  var my_orders_number = 0;

  SharedPreferences getUserData;
  Future<SharedPreferences> preferences = SharedPreferences.getInstance();

  get_current_user() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //name= prefs.getString( 'name' );
    current_uid = prefs.getString('userID');
    userID = prefs.getString("userID");
    name = prefs.getString("name");
    playerID = prefs.getString("playerID");
    phone = prefs.getString("phone");
    //profile_image= prefs.getString( 'email' );

    FirebaseFirestore.instance
        .collection('orders')
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach((doc) {
                if (doc["sender_uid"] == current_uid &&
                    doc["order_status"] == 4) {
                  my_orders_number++;
                  print(my_orders_number);
                }
              })
            })
        .whenComplete(() {
      FirebaseFirestore.instance
          .collection('delivery_boys')
          .doc(current_uid)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          setState(() {
            name = documentSnapshot.data()["name"];
            profile_image = documentSnapshot.data()["imageUrl"];
          });
        }
      });
    }).whenComplete(() {
      setState(() {
        flag = "";
      });
    });

    postViewModel.getDeliveryBoyRate(current_uid).then((value) {
      setState(() {
        rates = value;
      });
    });

    firestore
        .collection('delivery_boys')
        .doc(current_uid).snapshots()
        .listen((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        setState(() {
          status = documentSnapshot.get('status');
        });
      }
    });
  }


  @override
  void initState() {
    get_current_user();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return flag == "123"
        ? Scaffold(
            body: Center(
            child: CircularProgressIndicator(
              strokeWidth: 5,
              backgroundColor: appcolor,
            ),
          ))
        : SafeArea(
            child: Scaffold(
              body: Column(
                children: [
                  Container(
                    height: size.height * (90 / 756.0),
                    color: Color(0xfff4f1f1),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: size.width * (10 / 360.0),
                              ),
                              CustomSwitch(
                                activeColor: Colors.green,
                                value: status,
                                onChanged: (value) async {
                                  print("VALUE123 : $value");

                                    DeliveryTime deliveryTime = new DeliveryTime();
                                 await Fire_baseDeliveryTime()
                                        .fire_base_getDeliveryTime(current_uid)
                                        .then((inTime) {
                                      print("in_timeeee   $inTime");
                                      print("currennnt  $playerID");
                                      if(value && inTime){
                                        DateTime date = DateTime.now();
                                        postViewModel
                                            .deliveryBoyLogs(
                                            phone,
                                            name,
                                            playerID,
                                            'online',
                                            'true',
                                            current_uid,
                                            '1',
                                            date.toString())
                                            .then((value) {
                                          print('currennnt:: ${value.status}');
                                        });
                                        del_boy_on(current_uid);
                                        setState(() {
                                          status = value;
                                          print('currennnt:set 1');
                                        });
                                      }else if (value==false){
                                        DateTime date = DateTime.now();

                                        postViewModel.deliveryBoyLogs(
                                            phone,
                                            name,
                                            playerID,
                                            'offline',
                                            'true',
                                            userID,
                                            '1',
                                            date.toString())
                                            .then((value) {
                                          print('currennnt:: ${value.status}');
                                        });
                                        del_boy_off(current_uid);
                                        setState(() {
                                          status = value;
                                          print('currennnt:set 2');
                                        });

                                      }

                                    });

                                },
                              ),
                              SizedBox(
                                width: size.width * (10 / 360.0),
                              ),
                              Icon(
                                Icons.notifications,
                                size: size.width * (30 / 360.0),
                                color: Color(0xFF12c0c7),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    name,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: size.width * (20 / 360.0),
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  RatingBarIndicator(
                                    rating:
                                        rates ,
                                    itemBuilder: (context, index) => Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    itemCount: 5,
                                    itemSize: size.width * (20 / 360.0),
                                    direction: Axis.horizontal,
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              Stack(alignment: Alignment.center, children: [
                                CircleAvatar(
                                  radius: size.width * 45 / 360.0,
                                  //backgroundColor: const Color(0xFF03144c),
                                  child: CircleAvatar(
                                    radius: size.width * (45 / 360.0),
                                    backgroundImage: profile_image.isNotEmpty
                                        ? NetworkImage(profile_image)
                                        : AssetImage('assets/images/ep.jpg'),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.grey.shade50,
                                    child: IconButton(
                                        icon: Icon(
                                          Icons.add_a_photo,
                                          color: const Color(0xFF03144c),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(builder: (c) {
                                            return EditProfile(current_uid);
                                          }));
                                        }),
                                  ),
                                ),
                              ]),
                              SizedBox(
                                width: size.width * (20 / 360.0),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        SizedBox(
                          height: size.height * (10 / 756.0),
                        ),
                        DrowListItem('عدد الطلبات', my_orders_number.toString(),
                            Icons.directions_car),
                        DrowListItem('تسجيل الخروج', '', Icons.arrow_back),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  del_boy_off(uid) {
    firestore.collection('delivery_boys').doc(uid).update({
      "status": false,
    }).whenComplete(() {
      setState(() {
        //    _swich = val;
      });
    });
  }

  del_boy_on(uid) {
    firestore.collection('delivery_boys').doc(uid).update({
      "status": true,
    }).whenComplete(() {
      setState(() {
        //    _swich = val;
      });
    });
  }

  Widget DrowListItem(String title, String number, IconData ico) {
    Size size = MediaQuery.of(context).size;
    return InkWell(
      onTap: () async {
        if (title == 'تسجيل الخروج') {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('name', "").whenComplete(() {
            print(prefs.getString('name'));
            Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (c) {
              return LogIn();
            }), (route) => false);
          });

          Toast.show("تم تسجيل الخروج", context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
        }
      },
      child: Card(
        elevation: 2,
        shadowColor: Color(0xFF12c0c7),
        child: ListTile(
          leading: Icon(
            ico,
            color: Color(0xFF12c0c7),
          ),
          trailing: Text(
            number,
            style: TextStyle(
                color: Color(0xFF12c0c7), fontSize: size.width * (20 / 360.0)),
          ),
          title: Text(
            title,
            style: TextStyle(
                color: Colors.black, fontSize: size.width * (20 / 360.0)),
          ),
        ),
      ),
    );
  }
}

/*

  getLocationContenously();
    locations.getCurrentLocatiosn().then((value) {
      locations
          .getDestanceBetween(
              value.latitude, value.longitude, 29.308333, 73.984000)
          .then((value) {
        setState(() {
          if (value > 2.5) {
            setState(() {
              beOffline = true;
              inZone = false;
              destance = '${value.toStringAsFixed(2)}.KM';
            });
            DateTime date = DateTime.now();
            postViewModel
                .deliveryBoyLogs(phone, name, playerID, value.toString(),
                    inZone.toString(), current_uid, destance, date.toString())
                .then((value) => print('destance::: ${value.playerID}'));
          } else if (beOffline == true && value < 2.5) {
            setState(() {
              beOffline = false;
              inZone = true;
              destance = '${value.toStringAsFixed(2)}.KM';
            });
            DateTime date = DateTime.now();
            postViewModel
                .deliveryBoyLogs(phone, name, playerID, value.toString(),
                    inZone.toString(), current_uid, destance, date.toString())
                .then((value) => print('destance::: ${value.playerID}'));
          }
        });
      });
    });


      getLocationContenously() async {
    SharedPreferences getUserID;
    Future<SharedPreferences> preferences = SharedPreferences.getInstance();
    getUserID = await preferences;
    String userID = getUserID.getString("userID");

    getLocationContenously() {
      Geolocator.getPositionStream().listen((Position position) {
        if (position != null) {
          locations
              .getDestanceBetween(
                  position.latitude, position.longitude, 29.308333, 73.984000)
              .then((value) {
            if (value > 2.5) {
              setState(() {
                beOffline = true;
                inZone = false;
                destance = '${value.toStringAsFixed(2)}.KM';
              });
              DateTime date = DateTime.now();
              postViewModel
                  .deliveryBoyLogs(phone, name, playerID, value.toString(),
                      inZone.toString(), current_uid, destance, date.toString())
                  .then((value) => print('destance::: ${value.playerID}'));
            } else if (beOffline == true && value < 2.5) {
              setState(() {
                beOffline = false;
                inZone = true;
                destance = '${value.toStringAsFixed(2)}.KM';
              });
              DateTime date = DateTime.now();
              postViewModel
                  .deliveryBoyLogs(phone, name, playerID, value.toString(),
                      inZone.toString(), current_uid, destance, date.toString())
                  .then((value) => print('destance::: ${value.playerID}'));
            }
          });
        }
      });
    }
  }





                                locations.getCurrentLocatiosn().then((value) {
                              locations
                                  .getDestanceBetween(value.latitude,
                                      value.longitude, 26.3346673, 31.8929298)
                                  .then((value) {
                                print(
                                    'destance: ${value.toStringAsFixed(2)}.KM');

                                setState(() {
                                  destance = '${value.toStringAsFixed(2)}.KM';
                                });
                                setState(() {
                                  if (value > 50.0) {
                                    inZone = false;
                                  } else {
                                    inZone = true;
                                  }
                                });
                              });
                            });
                            DateTime date = DateTime.now();
                            postViewModel
                                .deliveryBoyLogs(
                                    phone,
                                    name,
                                    playerID,
                                    value.toString(),
                                    inZone.toString(),
                                    current_uid,
                                    destance,
                                    date.toString())
                                .then((value) =>
                                    print('destance::: ${value.playerID}'));
 */
