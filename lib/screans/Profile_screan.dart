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
  var name = 'hi';
  var profile_image;
  var current_uid;
  var phone;
  var playerID;
  var destance;
  double long = 0.0;
  double lat = 0.0;
  bool status = false;
  bool inZone = false;
  bool beOffline = false;
  Locations locations = new Locations();

  var rates;
  
  var my_orders_number=0;


  SharedPreferences getUserData;
  Future<SharedPreferences> preferences = SharedPreferences.getInstance();





  get_current_user() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //name= prefs.getString( 'name' );
    current_uid = prefs.getString( 'userID' );
    //profile_image= prefs.getString( 'email' );

    FirebaseFirestore.instance
        .collection('orders')
        .get()
        .then((QuerySnapshot querySnapshot) =>
    {
      querySnapshot.docs.forEach((doc) {
        if (doc["sender_uid"] == current_uid && doc["order_status"] == 4) {
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

    });
    postViewModel.getDeliveryBoyRate(current_uid).then((value) {
     setState(() {
       if(value==null){
         rates="0";
       }
       else{
         rates=value;
       }
     });

    });

  }

//myinit_stat(){}
  @override
  void initState() {
    get_current_user();


  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Container(
              height: 90,
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
                          width: 10,
                        ),
                        CustomSwitch(
                          activeColor: Colors.green,
                          value: status,
                          onChanged: (value) {
                            print("VALUE : $value");
                            setState(() {
                              status = value;
                            });

                          },
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Icon(
                          Icons.notifications,
                          size: 30,
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
                                fontSize: 20,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            RatingBarIndicator(
                              rating: rates==null?0:double.parse(rates),
                              itemBuilder: (context, index) => Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              itemCount: 5,
                              itemSize: 20.0,
                              direction: Axis.horizontal,
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Stack(alignment: Alignment.center, children: [
                          CircleAvatar(
                            radius: 45,
                            //backgroundColor: const Color(0xFF03144c),
                            child: CircleAvatar(
                              radius: 45,
                              backgroundImage: profile_image != null
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
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(builder: (c) {
                                      return EditProfile(current_uid);
                                    }));
                                  }),
                            ),
                          ),
                        ]),
                        SizedBox(
                          width: 20,
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
                    height: 10,
                  ),
                  DrowListItem('عدد الطلبات',my_orders_number.toString(), Icons.directions_car),
                  DrowListItem('تقييمات الخدمات', '4', Icons.star),
                  DrowListItem('تسجيل الخروج', '', Icons.arrow_back),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  del_boy_off(uid){
    firestore.collection('delivery_boys').doc(uid).update(
        {
          "status":false,
        }).whenComplete(() {
      setState(() {
    //    _swich = val;
      });
    });
  }
  del_boy_on(uid){
    firestore.collection('delivery_boys').doc(uid).update(
        {
          "status":true,
        }).whenComplete(() {
      setState(() {
        //    _swich = val;
      });
    });
  }

  Widget DrowListItem(String title, String number, IconData ico) {
    return InkWell(
      onTap: () async {
        if (title == 'تسجيل الخروج') {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('name',"").whenComplete(() {
            print(prefs.getString('name'));
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c) {
              return LogIn();}), (route) => false);
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
            style: TextStyle(color: Color(0xFF12c0c7), fontSize: 20),
          ),
          title: Text(
            title,
            style: TextStyle(color: Colors.black, fontSize: 18),
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