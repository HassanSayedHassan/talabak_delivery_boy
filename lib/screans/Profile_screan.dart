import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talabak_delivery_boy/screans/Edit_profile.dart';
import 'package:talabak_delivery_boy/screans/log_in_screan.dart';
import 'package:toast/toast.dart';


class Profile_Screan extends StatefulWidget {
  @override
  _Profile_ScreansState createState() => _Profile_ScreansState();
}

class _Profile_ScreansState extends State<Profile_Screan> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  var name = '';
  var profile_image;
  var current_uid;

  SharedPreferences getUserData;
  Future<SharedPreferences> preferences = SharedPreferences.getInstance();

  void pref() async {
    getUserData = await preferences;
    setState(() {
      current_uid = getUserData.getString('userID');
      print("sharePrefrences: $current_uid");
    });
  }

  @override
  void initState() {
    pref();
    FirebaseFirestore.instance
        .collection('delivery_boys')
        .doc(auth.currentUser.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        setState(() {

          name = documentSnapshot.data()["name"];
          profile_image = documentSnapshot.data()["profile_image"];
        });
      }
    });
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
                        Icon(
                          Icons.signal_wifi_4_bar,
                          size: 30,
                          color: Color(0xFF12c0c7),
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
                              rating: 3.5,
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
                                      return EditProfile();
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
                  DrowListItem('عدد الطلبات', '620', Icons.directions_car),
                  DrowListItem('تقييمات الخدمات', '4', Icons.star),
                  DrowListItem('ملاحظات المستخدمين', '220', Icons.chat),
                  DrowListItem('الاعدادات', '', Icons.settings),
                  DrowListItem('تسجيل الخروج', '', Icons.arrow_back),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget DrowListItem(String title, String number, IconData ico) {
    return InkWell(
      onTap: () {
        if (title == 'تسجيل الخروج') {
          auth.signOut();
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c) {
            return LogIn();
          }), (route) => false);

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
