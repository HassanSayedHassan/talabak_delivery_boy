import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:talabak_delivery_boy/webServices/notifications.dart';
import 'package:talabak_delivery_boy/webServices/postViewModel.dart';
import 'package:toast/toast.dart';

class SendImage extends StatefulWidget {
  var channelId, current_email, current_uid, other_uid;
  SendImage(
      this.current_uid, this.other_uid, this.channelId, this.current_email);
  @override
  _SendImageState createState() => _SendImageState(channelId, current_email);
}

class _SendImageState extends State<SendImage> {
  var channelId, current_email;

  _SendImageState(this.channelId, this.current_email);

  var appcolor = Color(0xFF12c0c7);
  File Send_Image;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  PostViewModel postViewModel = new PostViewModel();

  Notifications notification = new Notifications();
  String deliveryPlayerId = "";
  @override
  void initState() {
  ///  postViewModel.getPlayerId(widget.other_uid).then((value) {
  ///    setState(() {
 ///       deliveryPlayerId = value;
  ///    });
///    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
        icon: Icon(Icons.add_a_photo),
        color: appcolor,
        iconSize: 40,
        onPressed: () {
          _SendImage();
        });
  }

  void _SendImage() async {
    // ignore: deprecated_member_use
    final pickedImageFile = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 20);
    if (pickedImageFile != null) {
      setState(() {
        Send_Image = pickedImageFile;
        showGeneralDialog(
            context: context,
            barrierDismissible: true,
            barrierLabel:
                MaterialLocalizations.of(context).modalBarrierDismissLabel,
            barrierColor: Colors.black45,
            transitionDuration: const Duration(milliseconds: 200),
            pageBuilder: (BuildContext buildContext, Animation animation,
                Animation secondaryAnimation) {
              return Center(
                child: Container(
                  width: MediaQuery.of(context).size.width - 10,
                  height: MediaQuery.of(context).size.height - 250,
                  padding: EdgeInsets.all(20),
                  color: Colors.white,
                  child: Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width - 10,
                        height: MediaQuery.of(context).size.height - 350,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(Send_Image),
                            fit: BoxFit.fill,
                          ),
                          //shape: BoxShape.circle,
                        ),
                      ),
                      RaisedButton(
                        onPressed: () {
                          uploadIage(Send_Image);
                        },
                        child: Text(
                          "Send",
                          style: TextStyle(color: Colors.white),
                        ),
                        color: const Color(0xFF1BC0C5),
                      )
                    ],
                  ),
                ),
              );
            });
      });
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
          .child(channelId)
          .child(DateTime.now().toString());
      StorageUploadTask uploadTask = firebaseStorageRef.putFile(image);

      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
      final url = await firebaseStorageRef.getDownloadURL();
      firestore.collection('orders').doc(channelId).collection('messages').add({
        'message': url,
        'type': 'image',
        'data': DateTime.now().toIso8601String().toString(),
        'sederEmail': current_email,
      }).then((value) {
        Send_Image = null;
        closeLoading();
      }).whenComplete(() {
        ///  Notification_1   تم ارسال صوره من {current_uid}    to   {other_uid}
        notification.postNotification(deliveryPlayerId,
            'image send from $current_email', 'image is sended please go to chat to review it');
      });
    } else {
      Send_Image = null;
      closeLoading();
      my_Toast('تأكد من الاتصال بالنترنت');
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
