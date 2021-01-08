import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:shared_preferences/shared_preferences.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  FirebaseAuth auth = FirebaseAuth.instance;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  File _pickedProfilePhoto;
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
        .collection('users')
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

  uploadImage(File image) async {
    StorageReference firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child('profile_images').child(auth.currentUser.uid).child('image');
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(image);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    final url = await firebaseStorageRef.getDownloadURL();

    await firestore.collection('delivery_boys').doc(auth.currentUser.uid).update({
      'profile_image': url,
    }).then((value) => print("value: $url"));
  }

  void _pickSmallImage() async {
    // ignore: deprecated_member_use
    final pickedImageFile = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 20);
    setState(() {
      _pickedProfilePhoto = pickedImageFile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                backgroundImage: _pickedProfilePhoto != null
                    ? FileImage(_pickedProfilePhoto)
                    : profile_image != null
                        ? NetworkImage(profile_image)
                        : null,
                backgroundColor: Colors.green,
                child: _pickedProfilePhoto == null && profile_image == null
                    ? Icon(
                        Icons.add_a_photo,
                        color: Colors.amber,
                        size: 70,
                      )
                    : null,
                radius: 70,
              ),
            ),
            RaisedButton(
              child: Text('اختيار صورة'),
              onPressed: () {
                _pickSmallImage();
              },
            ),
            SizedBox(
              height: 30,
            ),
            RaisedButton(
                child: Text('حفظ الصورة'),
                color: Colors.amber,
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 50),
                onPressed: () {
                  if (_pickedProfilePhoto != null) {
                    uploadImage(_pickedProfilePhoto);
                    Navigator.pop(context);
                  }
                })
          ],
        ),
      ),
    );
  }
}
