import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:talabak_delivery_boy/widgets/chat_widgets/send_address.dart';
import 'package:talabak_delivery_boy/widgets/chat_widgets/send_image.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

class Message_Dilevery_Clint extends StatefulWidget {
  var clint_uid;

  var orderId;

  Message_Dilevery_Clint(this.clint_uid, this.orderId);

  @override
  _Message_Dilevery_ClintState createState() =>
      _Message_Dilevery_ClintState(clint_uid, orderId);
}

class _Message_Dilevery_ClintState extends State<Message_Dilevery_Clint> {
  var clint_uid;
  var orderId;

  _Message_Dilevery_ClintState(this.clint_uid, this.orderId);

  var appcolor = Color(0xFF12c0c7);
  File Send_Image;
  File reseat_Image;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  var other_profile_image;
  var other_name;
  var other_uid;
  var clint_phone;
  var flag = '123';

  var current_email;
  var current_name;
  var current_uid;
  TextEditingController coplainControler = TextEditingController();
  TextEditingController priseControler = TextEditingController();
  TextEditingController MessageControler = TextEditingController();
  ScrollController scrollController = ScrollController();

  bool dis_enable = false;
  bool un_send = false;

  @override
  void initState() {
    firestore
        .collection('delivery_boys')
        .doc(auth.currentUser.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        setState(() {
          current_name = documentSnapshot.get('name');
          current_email = documentSnapshot.get('email');
          current_uid = documentSnapshot.get('uid');
        });
      }
    });
    firestore
        .collection('users')
        .doc(clint_uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        setState(() {
          other_name = documentSnapshot.get('name');
          other_profile_image = documentSnapshot.get('profile_image');
          other_uid = documentSnapshot.get('uid');

          var phone= documentSnapshot.get('email').toString().split("@");
          clint_phone=phone[0];
         // print(clint_phone);
        });
      }
    }).then((value) {
      firestore
          .collection('orders')
          .doc(orderId)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          setState(() {
            dis_enable = documentSnapshot.get('dis_enable');
            un_send = documentSnapshot.get('un_send');
          });
        }
      }).whenComplete(() {
        setState(() {
          flag = " ";
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return flag == '123'
        ? Scaffold(
            body: Center(
            child: CircularProgressIndicator(
              strokeWidth: 5,
              backgroundColor: appcolor,
            ),
          ))
        : Scaffold(
            //backgroundColor: Colors.amberAccent,
            appBar: AppBar(
              backgroundColor: appcolor,
              title:  Text(other_name),
              leading: Container(child: GestureDetector(onTap: (){
                if(clint_phone.toString().isNotEmpty){
                  UrlLauncher.launch("tel:+${clint_phone}");
                  print(clint_phone);
                }
              },child:   Icon(
                Icons.call,
                color: Colors.white,
                size: 30,
              ),)),

              actions: <Widget>[
                PopupMenuButton<String>(
                  onSelected: choiceAction,
                  itemBuilder: (BuildContext context) {
                    return Constants.choices.map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      );
                    }).toList();
                  },
                )
              ],
            ),
            body: StreamBuilder<QuerySnapshot>(
              stream: firestore
                  .collection('orders')
                  .doc(orderId)
                  .collection('messages')
                  .orderBy('data', descending: true)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text("Loading");
                }

                return Column(
                  children: [
                    Expanded(
                      child: new ListView(
                        reverse: true,
                        children:
                            snapshot.data.docs.map((DocumentSnapshot document) {
                          //

                          return document.data()['type'] == 'text'
                              ? DrowMessage(
                                  document.data()['message'],
                                  document.data()['sederEmail'],
                                  document.data()['data'],
                                )
                              : document.data()['type'] == 'order'
                                  ? Drow_order(
                                      document.data()['message'],
                                      document.data()['sederEmail'],
                                      document.data()['data'],
                                    )
                                  : document.data()['type'] == 'end_order'
                                      ? Drow_end_order(
                                          document.data()['message'],
                                          document.data()['sederEmail'],
                                          document.data()['data'],
                                        )
                                      : document.data()['type'] == 'image'
                                          ? DrowImage(
                                              document.data()['message'],
                                              document.data()['sederEmail'],
                                              document.data()['data'],
                                            )
                                          : DrowAdress(
                                              document.data()['message'],
                                              document.data()['sederEmail'],
                                              document.data()['data'],
                                            );
                        }).toList(),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          dis_enable == false
                              ? SendImage(orderId, current_email)
                              : SizedBox(),
                          dis_enable == false
                              ? Send_Address(orderId, current_email)
                              : SizedBox(),
                          dis_enable == false
                              ? Expanded(
                                  child: Container(
                                    child: TextField(
                                      controller: MessageControler,
                                      decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: appcolor, width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: appcolor, width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                        ),
                                        hintText: 'Type a message here..',
                                      ),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                )
                              : un_send == true ? un_send_widget() : SizedBox(),
                          dis_enable == false
                              ? IconButton(
                                  icon: Icon(Icons.send),
                                  color: appcolor,
                                  iconSize: 40,
                                  onPressed: () {
                                    firestore
                                        .collection('orders')
                                        .doc(orderId)
                                        .collection('messages')
                                        .add({
                                      'message': MessageControler.text,
                                      'type': 'text',
                                      'data': DateTime.now()
                                          .toIso8601String()
                                          .toString(),
                                      'sederEmail': current_email,
                                    }).then((value) =>
                                            MessageControler.clear());
                                  })
                              : SizedBox(),
                        ],
                      ),
                    )
                  ],
                );
              },
            ),
          );
  }

  Widget DrowMessage(message, senderEmail, data) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 7, horizontal: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: senderEmail == current_email
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Material(
            borderRadius: BorderRadius.circular(10),
            elevation: 5,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: senderEmail == current_email ? appcolor : Colors.white,
              ),
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
              child: Column(
                children: [
                  Text(
                    message,
                    style: TextStyle(
                      color: senderEmail == current_email
                          ? Colors.white
                          : appcolor,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    getdata(data),
                    style: TextStyle(
                        color: senderEmail == current_email
                            ? Colors.white
                            : appcolor,
                        fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget Drow_end_order(message, senderEmail, data) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 7, horizontal: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: senderEmail == current_email
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Material(
            borderRadius: BorderRadius.circular(10),
            elevation: 5,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: senderEmail == current_email ? appcolor : Colors.white,
              ),
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
              child: Column(
                children: [
                  Text(
                    message,
                    style: TextStyle(
                      color: senderEmail == current_email
                          ? Colors.white
                          : appcolor,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    getdata(data),
                    style: TextStyle(
                        color: senderEmail == current_email
                            ? Colors.white
                            : appcolor,
                        fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget DrowImage(message, senderEmail, data) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 7, horizontal: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: senderEmail == current_email
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Material(
            borderRadius: BorderRadius.circular(10),
            elevation: 5,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: senderEmail == current_email ? appcolor : Colors.white,
              ),
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              child: Column(
                children: [
                  Container(
                    height: 300,
                    width: 200,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(message),
                        fit: BoxFit.fill,
                      ),
                      //shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    getdata(data),
                    style: TextStyle(
                        color: senderEmail == current_email
                            ? Colors.white
                            : appcolor,
                        fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String getdata(data) {
    DateTime todayDate = DateTime.parse(data);
    return DateFormat("yyyy/MM/dd                hh:mm").format(todayDate);
  }

  Widget DrowAdress(message, senderEmail, data) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 7, horizontal: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: senderEmail == current_email
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Material(
            borderRadius: BorderRadius.circular(10),
            elevation: 5,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: senderEmail == current_email ? appcolor : Colors.white,
              ),
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              child: Column(
                children: [
                  Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/gmap.png"),
                        fit: BoxFit.fill,
                      ),
                      //shape: BoxShape.circle,
                    ),
                  ),
                  RaisedButton.icon(
                    onPressed: () {
                      var longitude = message.toString().split(' ')[1];
                      var latitude = message.toString().split(' ')[0];
                      if (longitude != null && latitude != null) {
                        _launchURL(
                            'http://maps.google.com/maps?q=${longitude},${latitude}+(My+Point)&z=16&ll=${longitude},${latitude}');
                      }
                    },
                    icon: Icon(
                      Icons.location_on,
                      color: appcolor,
                      size: 40,
                    ),
                    label: Text('Show location'),
                    color: Color.fromRGBO(0, 0, 0, 0),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    getdata(data),
                    style: TextStyle(
                        color: senderEmail == current_email
                            ? Colors.white
                            : appcolor,
                        fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
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

  Widget un_send_widget() {
    return Expanded(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 7, horizontal: 5),
        child: Column(
          children: [
            Material(
              borderRadius: BorderRadius.circular(10),
              elevation: 5,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      child: Text(
                        'طلب ملغي ',
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 26,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget Drow_order(message, sender_email, data) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 7, horizontal: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: sender_email == current_email
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Material(
            borderRadius: BorderRadius.circular(10),
            elevation: 5,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: sender_email == current_email ? appcolor : Colors.white,
              ),
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: sender_email == current_email
                          ? Colors.white
                          : appcolor,
                    ),
                    child: Text(
                      'طلــــــــب جديــــد',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  Text(
                    message,
                    style: TextStyle(
                      color: sender_email == current_email
                          ? Colors.white
                          : appcolor,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    getdata(data),
                    style: TextStyle(
                        color: sender_email == current_email
                            ? Colors.white
                            : appcolor,
                        fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  send_complain() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                width: double.infinity,
                //  height: 200,
                child: TextField(
                  maxLines: 6,
                  keyboardType: TextInputType.multiline,
                  controller: coplainControler,
                  decoration: InputDecoration(
                    hintText: 'أدخل الشكوي ',
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: appcolor, width: 2.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green, width: 2.0),
                    ),
                  ),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
              FlatButton(
                child: Text(
                  'ارسال الشكوي',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                  ),
                ),
                color: appcolor,
                onPressed: () {},
              ),
            ],
          ),
          behavior: HitTestBehavior.opaque,
        );
      },
    );
  }

  void choiceAction(String choice) {
    if (choice == Constants.send_comp) {
      send_complain();
    } else if (choice == Constants.send_reseat) {
      if (dis_enable == false) {
        take_resrat();
      }
    } else if (choice == Constants.end_order) {
      if (dis_enable == false) {
        firestore.collection('orders').doc(orderId).collection('messages').add({
          'message': 'تم انهاء الطلب',
          'type': 'end_order',
          'data': DateTime.now().toIso8601String().toString(),
          'sederEmail': current_email,
        }).whenComplete(() {});
      }
    }
  }

  Future<void> take_resrat() async {
    final pickedImageFile = await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 40);
    if (pickedImageFile != null) {
      setState(() {
        reseat_Image = pickedImageFile;
      });
      showModalBottomSheet(
        context: context,
        builder: (_) {
          return GestureDetector(
            onTap: () {},
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width - 10,
                height: MediaQuery.of(context).size.height - 250,
                padding: EdgeInsets.all(20),
                color: Colors.white,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        // maxLines: 6,
                        // keyboardType: TextInputType.multiline,
                        controller: priseControler,
                        decoration: InputDecoration(
                          hintText: 'أدخل السعر ',
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: appcolor, width: 2.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.green, width: 2.0),
                          ),
                        ),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.end,
                      ),
                      RaisedButton(
                        onPressed: () {
                          uploadIage(reseat_Image);
                        },
                        child: Text(
                          "ارسال الفاتوره",
                          style: TextStyle(color: Colors.white),
                        ),
                        color: const Color(0xFF1BC0C5),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width - 40,
                        height: MediaQuery.of(context).size.height - 400,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(reseat_Image),
                            fit: BoxFit.fill,
                          ),
                          //shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            behavior: HitTestBehavior.opaque,
          );
        },
      );
    }
  }

  uploadIage(File image) async {
    var stats = false;
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      stats = true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      stats = true;
    }
    if (stats) {
      Navigator.of(context).pop();
      startLoading();
      StorageReference firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child('${auth.currentUser.uid}/chats')
          .child(orderId)
          .child(DateTime.now().toString());
      StorageUploadTask uploadTask = firebaseStorageRef.putFile(image);

      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
      final url = await firebaseStorageRef.getDownloadURL();
      firestore.collection('orders').doc(orderId).collection('messages').add({
        'message': url,
        'type': 'reseat-image',
        'data': DateTime.now().toIso8601String().toString(),
        'sederEmail': current_email,
      }).then((value) {
        reseat_Image = null;
        closeLoading();
      });
    } else {
      reseat_Image = null;
      closeLoading();
      my_Toast('تأكد من الاتصال بالنترنت');
    }
  }

  void closeLoading() {
    Navigator.pop(context);
  }

  void my_Toast(String mess) {
    Toast.show(mess, context,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  }

  Future<bool> checkInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    } else {
      return false;
    }
  }
}

class Constants {
  static const String send_comp = 'ارسال شكوي';
  static const String send_reseat = 'ارسال الفاتوره';
  static const String end_order = 'انهاء الطلب';

  static const List<String> choices = <String>[
    send_comp,
    send_reseat,
    end_order
  ];
}
