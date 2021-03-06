import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:rating_dialog/rating_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talabak_delivery_boy/screans/show_photo_in_one_screan.dart';
import 'package:talabak_delivery_boy/utili_class.dart';
import 'package:talabak_delivery_boy/webServices/locations.dart';
import 'package:talabak_delivery_boy/webServices/notifications.dart';
import 'package:talabak_delivery_boy/webServices/postViewModel.dart';
import 'package:talabak_delivery_boy/widgets/chat_widgets/Drow_Record.dart';
import 'package:talabak_delivery_boy/widgets/chat_widgets/send_address.dart';
import 'package:talabak_delivery_boy/widgets/chat_widgets/send_image.dart';
import 'package:talabak_delivery_boy/widgets/chat_widgets/send_record.dart';
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
  var discount_pers = 0;
  var total_price = 0.0;
  var actual_price = 0.0;

  _Message_Dilevery_ClintState(this.clint_uid, this.orderId);

  var appcolor = Color(0xFF12c0c7);
  var appcolor_2 = Color(0xFF32065b);
  File Send_Image;
  File reseat_Image;
 // FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  var other_profile_image;
  var other_name;
  var other_uid;
  var clint_phone;
  var flag = '123';
  String playerID = '';
  String phone = '';
  var current_email;
  var current_name;
  var current_uid;
  TextEditingController coplainControler = TextEditingController();
  TextEditingController priseControler = TextEditingController();
  TextEditingController MessageControler = TextEditingController();
  ScrollController scrollController = ScrollController();

  bool dis_enable = false;
  bool un_send = false;
  var accept_order;
  var received_time;
  var finish_time;
  var order_status;
var take_reseat=false;
  int cur_orders = 0;


  my_init_stat() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      current_uid = prefs.getString('userID');
      current_name = prefs.getString("name");
      playerID = prefs.getString("playerID");
      phone = prefs.getString("phone");

      current_email = prefs.getString('email');
    });

    firestore
        .collection('users')
        .doc(clint_uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        setState(() {
          other_name = documentSnapshot.get('name');
          // other_profile_image = documentSnapshot.get('profile_image');
          other_uid = documentSnapshot.get('uid');

          var phone = documentSnapshot.get('email').toString().split("@");
          clint_phone = phone[0];
          // print(clint_phone);
        });
      }
    }).then((value) {
      firestore
          .collection('orders')
          .doc(orderId)
          .snapshots()
          .listen((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          setState(() {
            dis_enable = documentSnapshot.get('dis_enable');
            un_send = documentSnapshot.get('un_send');
            accept_order = documentSnapshot.get('accept_order');

            received_time = documentSnapshot.get('received_time');
            finish_time = documentSnapshot.get('finish_time');
            order_status = documentSnapshot.get('order_status');
            //   send_time= documentSnapshot.get('send_time');
           // print("discount_persdiscount_pers ${documentSnapshot.get('discount_pers')}");

            take_reseat=documentSnapshot.get('take_reseat');

            discount_pers = documentSnapshot.get('discount_pers')!=null?documentSnapshot.get('discount_pers'):0;

          });
        }
      });
    }).whenComplete(() {
      setState(() {
        flag = " ";
      });
      postViewModel.getPlayerIdUser(other_uid).then((value) {
        setState(() {
          print('in_timeeee::$value:::::$other_uid');
          clientPlayerID = value;
        });
      });
      postViewModel.getPlayerIdAdmin().then((value) {
        setState(() {
          adminPlayerID = value;
        });

      });
    });
  }
  Notifications notifications = new Notifications();
  PostViewModel postViewModel = new PostViewModel();
  String clientPlayerID = "";
  String adminPlayerID = "";
  @override
  void initState() {

my_init_stat();


//Locations locations = new Locations();
//locations.getLocationContenously('status',current_uid,playerID,current_name,phone);
  }

  refresh() {
    setState(() {});
    Navigator.pop(context);
  }
  show_ind(){
    Toast.show("بدأ تسجيل رساله صوتية", context, duration: Toast.LENGTH_LONG, gravity:  Toast.CENTER,backgroundColor:Colors.green );

  }
  hid_ind(){
    Toast.show("انتهاء تسجيل رساله صوتية", context, duration: Toast.LENGTH_LONG, gravity:  Toast.CENTER,backgroundColor:Colors.blue );
  }
  @override
  Widget build(BuildContext context) {
   // Size size = MediaQuery.of(context).size;
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
              title: Text(other_name),
              leading: Container(
                  child: GestureDetector(
                onTap: () {
                  if (clint_phone.toString().isNotEmpty) {
                    UrlLauncher.launch("tel:+${clint_phone}");
                    print(clint_phone);
                  }
                },
                child: Icon(
                  Icons.call,
                  color: Colors.white,
                  size: 30,
                ),
              )),
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
                            document.data()['resturant_name'],
                            document.data()['resturant_longitude'],
                            document.data()['resturant_latitude'],
                          )
                              : document.data()['type'] == 'end_order'
                              ? Drow_end_order(
                            document.data()['message'],
                            document.data()['sederEmail'],
                            document.data()['data'],
                          )
                              : document.data()['type'] ==
                              'accept_order'
                              ? Drow_accept_order(
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
                              : document.data()['type'] ==
                              'reseat-image'
                              ? Drow_reseat_image(
                            document
                                .data()['message'],
                            document
                                .data()['sederEmail'],
                            document.data()['data'],
                            document.data()[
                            'total_price'],
                            document.data()[
                            'actual_price'],
                            document.data()[
                            'dicount_pers'],
                          )
                              : document.data()['type'] ==
                              'Received_order'
                              ? Drow_Received_order(
                            document.data()[
                            'message'],
                            document.data()[
                            'sederEmail'],
                            document
                                .data()['data'],
                          )
                              : document.data()[
                          'type'] ==
                              'record'
                              ? Drow_record(
                              document.data()[
                              'message'],
                              document.data()[
                              'sederEmail'],
                              document.data()[
                              'data'],
                              current_email)
                              : DrowAdress(
                            document.data()[
                            'message'],
                            document.data()[
                            'sederEmail'],
                            document.data()[
                            'data'],
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
                              ? SendImage(current_uid,other_uid,orderId, current_email)
                              : SizedBox(),
                          dis_enable == false
                              ? SendRecord(current_uid,other_uid,orderId, current_email, other_name,
                              other_uid, other_profile_image,
                              notifyParent: refresh,show_ind:show_ind,
                              hid_ind:hid_ind)
                              : SizedBox(),
                          dis_enable == false
                              ? Expanded(
                                  child: Container(
                                    child: TextField(
                                      controller: MessageControler,
                                      decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: appcolor, width: 2),
                                          borderRadius:
                                              BorderRadius.circular(25),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: appcolor, width: 2),
                                          borderRadius:
                                              BorderRadius.circular(25),
                                        ),
                                        hintText: 'Type a message here..',
                                      ),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                )
                              : un_send == true
                                  ? un_send_widget()
                                  : compleate_order_widget(),
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
                                    }).whenComplete(() {
                                      ///  Notification_1   هناك رساله جديده من {current_uid}    to   {other_uid}
                                      ///
                                      notifications.postNotification(clientPlayerID, 'new message from $current_name', MessageControler.text);
                                      print('in_timeeee::$other_uid');

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
                color: Colors.green,
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
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (c) {
          return show_photo_in_one_screan(message);
        }));
      },
      child: Container(
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
      ),
    );
  }

  Widget Drow_reseat_image(message, senderEmail, data, total_price, actual_price, dicount_pers) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (c) {
          return show_photo_in_one_screan(message);
        }));
      },
      child: Container(
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
                      "المبلغ الكلي = ${total_price}",
                      style: TextStyle(
                          color: senderEmail == current_email
                              ? Colors.white
                              : appcolor,
                          fontSize: 20),
                    ),
                    Text(
                      "سعر التوصيل  = 12.0",
                      style: TextStyle(
                          color: senderEmail == current_email
                              ? Colors.white
                              : appcolor,
                          fontSize: 20),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "نسبه الخصم = ${dicount_pers}",
                      style: TextStyle(
                          color: senderEmail == current_email
                              ? Colors.white
                              : appcolor,
                          fontSize: 20),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      " المبلغ بعد الخصم = ${actual_price}",
                      style: TextStyle(
                          color: senderEmail == current_email
                              ? Colors.white
                              : appcolor,
                          fontSize: 20),
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
      ),
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

  Widget Drow_order(message, sender_email, data, resturant_name, resturant_longitude, resturant_latitude) {
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
                color: Colors.pinkAccent,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'طلــــــــب جديــــد',
                          style: TextStyle(
                              fontSize: 22,
                              color: Colors.pinkAccent,
                              fontWeight: FontWeight.bold),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Flexible(
                                child: Text(
                                  resturant_name!=null?resturant_name:"اسم المطعم",
                                  style:
                                  TextStyle(fontSize: 18, color: Colors.black),
                                )),
                            InkWell(
                                onTap: () {
                                  print("resturant_longitude $resturant_longitude  ");
                                  if (resturant_longitude != null && resturant_latitude != null) {
                                    _launchURL(
                                        'http://maps.google.com/maps?q=${resturant_longitude},${resturant_latitude}+(My+Point)&z=16&ll=${resturant_longitude},${resturant_latitude}');
                                  }
                                },
                                child: Icon(
                                  Icons.location_on,
                                  color: Colors.pinkAccent,
                                  size: 38,
                                ))
                          ],
                        )
                      ],
                    ),
                  ),
                  Text(
                    message,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    getdata(data),
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget compleate_order_widget() {
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
                  color: Colors.green,
                ),
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.green,
                      ),
                      child: Text(
                        'طلب مكتمل  ',
                        style: TextStyle(
                            color: Colors.white,
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

  Widget Drow_Received_order(message, senderEmail, data) {
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
              //height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.blue,
              ),
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    message,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    getdata(data),
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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

  Widget Drow_accept_order(message, senderEmail, data) {
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
              //height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: appcolor_2,
              ),
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

  String getdata(data) {
    DateTime todayDate = DateTime.parse(data);
    return DateFormat("yyyy/MM/dd                hh:mm").format(todayDate);
  }

  send_complain() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                width: double.infinity,
                  height: 200,
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
                onPressed: () {
                  HelpFun().startLoading(context);
                  PostViewModel postViewModel = new PostViewModel();
                  postViewModel
                      .addComplaint(
                          coplainControler.text.toString(),
                          current_uid,
                          other_uid,
                          "delivery",
                          orderId,
                          DateTime.now().toIso8601String().toString())
                      .then((value) {
                    HelpFun().closeLoading(context);
                    HelpFun().my_Toast("تم إرسال الشكوي", context);
                    Navigator.pop(context);
                    ///  Notification_2   تم ارسال شكوي من {current_uid}    to   {master}
                    notifications.postNotification(adminPlayerID, 'new delivery complaint from $current_name', coplainControler.text);
                  });
                },
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
      _finish_order_fun();
    } else if (choice == Constants.accept_order) {
      _accept_order_fun();
    } else if (choice == Constants.share_loc) {
      Send_Address(current_uid,other_uid,orderId, current_email, context).fun_send_address();
    }
  }

  Future<void> take_resrat() async {
    final pickedImageFile = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 40);
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
                padding: EdgeInsets.all(20),
                color: Colors.white,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        // maxLines: 6,
                        keyboardType: TextInputType.number,
                        controller: priseControler,
                        onChanged: (val) {
                          setState(() {
                          //  print(int.parse(priseControler.text.toString()));
                             total_price = double.parse(priseControler.text.toString());

                            var total_discount=12-(discount_pers/100.0)*12;
                            actual_price = total_price + total_discount;


                          //  total_price = double.parse(priseControler.text.toString());

                            //  print(total_price);
                          });
                        },
                        decoration: InputDecoration(
                          prefix: Text("جنيه مصري"),
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
                      SizedBox(
                        height: 10,
                      ),
                      Text(" نسبه الخصم =  ${discount_pers}"),
                      // SizedBox(height: 10,),
                      //   Text(" السعر الكلي  =  ${total_price}"),

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
          .child('${current_uid}/chats')
          .child(orderId)
          .child(DateTime.now().toString());
      StorageUploadTask uploadTask = firebaseStorageRef.putFile(image);

      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
      final url = await firebaseStorageRef.getDownloadURL();
      firestore.collection('orders').doc(orderId).collection('messages').add({
        'message': url,
        'type': 'reseat-image',
        'total_price': total_price,
        'dicount_pers': discount_pers,
        'actual_price': actual_price,

        'data': DateTime.now().toIso8601String().toString(),
        'sederEmail': current_email,
      }).then((value) {
        reseat_Image = null;
        closeLoading();
      }).whenComplete(() {
        firestore.collection('orders').doc(orderId).update({
          "take_reseat":true,
        });
      }).whenComplete(() {
        ///  Notification_2   تم ارسال الفاتوره من {current_uid}    to   {other_uid}
        notifications.postNotification(clientPlayerID, 'the check has been sended $current_name', 'go to chat to review it');
        print('in_timeeee::$clientPlayerID');
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

  void _accept_order_fun() {
    if (un_send == false && accept_order == "") {
      firestore.collection('orders').doc(orderId).collection('messages').add({
        'message': "تم قبول الطلب",
        'type': 'accept_order',
        'data': DateTime.now().toIso8601String().toString(),
        'sederEmail': current_email,
      }).whenComplete(() {
        firestore.collection('orders').doc(orderId).update({
          "order_status": 2,
          "accept_order": DateTime.now().toIso8601String().toString()
        }).whenComplete(() {
          firestore
              .collection('delivery_boys')
              .doc(current_uid).update({
            "current_orders":FieldValue.increment(1)
          });
        });
      }).whenComplete(() {
        ///  Notification_4  تم قبول الطلب من {current_uid}    to   {other_uid}
        notifications.postNotification(clientPlayerID, 'your order is accepted $current_name', 'go to chat if you nedd to add some notes to delivery boy');
        print('in_timeeee::$other_uid');
      });
    }
  }

  void _finish_order_fun() {
    if (dis_enable == false && accept_order != "" && take_reseat && finish_time == "") {
      firestore.collection('orders').doc(orderId).collection('messages').add({
        'message': 'تم انهاء الطلب',
        'type': 'end_order',
        'data': DateTime.now().toIso8601String().toString(),
        'sederEmail': current_email,
      }).whenComplete(() {
        firestore.collection('orders').doc(orderId).update({
          "order_status": 4,
          "dis_enable": true,
          "finish_time": DateTime.now().toIso8601String().toString()
        }).whenComplete(() {
          firestore
              .collection('delivery_boys')
              .doc(current_uid).update({
            "current_orders":FieldValue.increment(-1)
          }).whenComplete(() {
            ///  Notification_5  تم اكتمال الطلب من {current_uid}    to   {other_uid}
            notifications.postNotification(clientPlayerID, 'the order is done $current_name', 'go to chat now');
            print('in_timeeee::$other_uid');
          });
        });

      });
    }
  }

  void _Show_rates_dialog() {
    showDialog(
        context: context,
        barrierDismissible: true, // set to false if you want to force a rating
        builder: (context) {
          return RatingDialog(
            icon: const FlutterLogo(
              size: 100,
            ), // set your own image/icon widget
            title: "برجاء تقييم العميل ",
            description: "",
            submitButton: "تقييم",
            alternativeButton: "اغلاق", // optional
            positiveComment: "", // optional
            negativeComment: "", // optional
            accentColor: appcolor, // optional
            onSubmitPressed: (int rating) {
              print("onSubmitPressed: rating = $rating");
              // TODO: open the app's page on Google Play / Apple App Store
            },
            onAlternativePressed: () {
              Navigator.pop(context);
              print("onAlternativePressed: do something");
              // TODO: maybe you want the user to contact you instead of rating a bad review
            },
          );
        });
  }
}

class Constants {
  static const String send_comp = 'ارسال شكوي';
  static const String send_reseat = 'ارسال الفاتوره';
  static const String share_loc = 'مشاركة الموقع';
  static const String end_order = 'تم توصيل الطلب';

  static const String accept_order = 'قبول الطلب';

  static const List<String> choices = <String>[
    send_comp,
    send_reseat,
    end_order,
    accept_order,
    share_loc
  ];
}
