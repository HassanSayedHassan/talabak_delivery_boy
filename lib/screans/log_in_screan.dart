import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:talabak_delivery_boy/screans/home_page.dart';
import 'package:talabak_delivery_boy/webServices/locations.dart';
import 'package:talabak_delivery_boy/webServices/notifications.dart';
import 'package:talabak_delivery_boy/webServices/postViewModel.dart';
import 'package:toast/toast.dart';

class LogIn extends StatefulWidget {
  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  var appcolor = Color(0xFF12c0c7);
  FirebaseAuth auth = FirebaseAuth.instance;

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  PostViewModel postViewModel = new PostViewModel();

  TextEditingController EmailControler = TextEditingController();

  TextEditingController PassControler = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 300,
              decoration: new BoxDecoration(
                gradient: new LinearGradient(
                    colors: [
                      const Color(0xFFa8d942),
                      const Color(0xFF12c0c7),
                    ],
                    begin: const FractionalOffset(0.0, 0.0),
                    end: const FractionalOffset(1.0, 0.0),
                    stops: [0.0, 1.0],
                    tileMode: TileMode.clamp),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Talabak',
                      style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    Icon(
                      Icons.shopping_cart,
                      size: 50,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    "تسجيل الدخول",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 25,
                    ),
                  ),
                ),
              ],
            ),
            DrowTextField("phone", Icon(Icons.phone, color: Colors.green),
                EmailControler),
            DrowTextField("password", Icon(Icons.lock, color: Colors.green),
                PassControler),
            RaisedButton(
              color: Colors.green,
              child: Text(
                "دخول",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                startLoading();
                var connectivityResult =
                    await (Connectivity().checkConnectivity());
                if (connectivityResult == ConnectivityResult.mobile ||
                    connectivityResult == ConnectivityResult.wifi) {
                  try {
                    postViewModel
                        .login(EmailControler.text, PassControler.text)
                        .then((value) {
                      Toast.show(value.status, context);
                      if (value.status == "success") {
                        Notifications notifications = new Notifications();
                        notifications.getPlayerID().then((value) =>
                            postViewModel
                                .updateDeliveryBoyData(EmailControler.text,
                                    PassControler.text, value, '')
                                .then((value) {
                              if (value.status == 'registeration success') {
                                closeLoading();
                                Navigator.pushAndRemoveUntil(context,
                                    MaterialPageRoute(builder: (c) {
                                  return HomeScrean();
                                }), (route) => false);
                              }
                            }));
                      } else {
                        closeLoading();
                      }
                    });
                  } on FirebaseAuthException catch (e) {
                    if (e.code == 'user-not-found') {
                      closeLoading();
                      my_Toast('No user found for that email.');
                    } else if (e.code == 'wrong-password') {
                      closeLoading();
                      my_Toast('Wrong password provided for that user.');
                    }
                  }
                } else {
                  closeLoading();
                  my_Toast('لا يوجد اتصال بالانترنت');
                }
              },
            ),
            SizedBox(
              height: 100,
            ),
          ],
        ),
      ),
    );
  }

  Widget DrowTextField(
      String label, Icon ico, TextEditingController controler) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: TextField(
        controller: controler,
        obscureText: label == 'password' ? true : false,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
            icon: ico,
            enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Colors.lightGreenAccent, width: 2.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.green, width: 2.0),
            ),
            labelText: label,
            labelStyle: TextStyle(color: Colors.green)),
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
        ),
      ),
    );
  }

  void my_Toast(String mess) {
    Toast.show(mess, context,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
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
                new CircularProgressIndicator(
                  strokeWidth: 5,
                  backgroundColor: appcolor,
                ),
                new Text("Loading..."),
              ],
            ),
          ),
        );
      },
    );
  }

  void closeLoading() {
    Navigator.pop(context);
  }
}
