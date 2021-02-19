import 'dart:io' as io;
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:audio_recorder/audio_recorder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:talabak_delivery_boy/aduio_del_user/play_record.dart';
import 'package:toast/toast.dart';

class SendRecord extends StatefulWidget {
  var channelId,current_email;
  var name;
  var uid;
  var profile_image;
  final LocalFileSystem localFileSystem;
  final Function() notifyParent;
  SendRecord(this.channelId,this.current_email,this.name,this.uid,this.profile_image,{localFileSystem,Key key, @required this.notifyParent}):
        this.localFileSystem = localFileSystem ?? LocalFileSystem(),super(key: key);



  @override
  _SendRecordState createState() => _SendRecordState(channelId,current_email,name,uid,profile_image);
}

class _SendRecordState extends State<SendRecord> {
  var name;
  var uid;
  var profile_image;
  var channelId,current_email;
  _SendRecordState(this.channelId,this.current_email,this.name,this.uid,this.profile_image);
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  var appcolor = Color(0xFF12c0c7);
  Recording _recording = new Recording();
  bool _isRecording = false;

  TextEditingController _controller = new TextEditingController();
  bool _play = false;
  bool isPlaying=false;

  double _sliderValue;
  bool _userIsMovingSlider;
  Duration currentTime;
  Duration totalTime;

  @override
  void initState() {
    super.initState();
    _sliderValue = _getSliderValue();
    _userIsMovingSlider = false;
  }

  @override
  Widget build(BuildContext context) {
    if (!_userIsMovingSlider) {
      _sliderValue = _getSliderValue();
    }
      return GestureDetector(
      onLongPress: (){
        _start();
      },
      onLongPressUp: (){
        _stop();
      },
      child: IconButton(
          icon: Icon(Icons.mic),
          color: appcolor,
          iconSize: 40,
          onPressed: () {



          }),
    );
  }



  _start() async {
    try {
      //await AudioRecorder.hasPermissions
     // var status = await Permission.microphone.request().isGranted;
      if ( await Permission.microphone.request().isGranted) {
        // We didn't ask for permission yet.
     ///}
      ///if (true) {
          String path = DateTime.now().toString();
          if (!path.contains('/')) {
            io.Directory appDocDirectory =
            await getApplicationDocumentsDirectory();
            path = appDocDirectory.path + '/' + path;
          }
          print("Start recording: $path");
          await AudioRecorder.start(
              path: path, audioOutputFormat: AudioOutputFormat.AAC);

        bool isRecording = await AudioRecorder.isRecording;
        setState(() {
          _recording = new Recording(duration: new Duration(), path: "");
          _isRecording = isRecording;
        });
      } else {
        Scaffold.of(context).showSnackBar(
            new SnackBar(content: new Text("You must accept permissions")));
      }

    } catch (e) {
      print(e);
    }
  }





  _stop() async {
    var recording = await AudioRecorder.stop();
    print("Stop recording: ${recording.path}");
    bool isRecording = await AudioRecorder.isRecording;
    File file = widget.localFileSystem.file(recording.path);
    print("  File length: ${await file.length()}");
    setState(() {
      _recording = recording;
      _isRecording = isRecording;
    });
 //   final assetsAudioPlayer = AssetsAudioPlayer();
   // assetsAudioPlayer.open(
     // Audio.file(recording.path),
   // );
    print(recording.path);
    check_record(file);
    //upload_Record(file);
  }






  double _getSliderValue() {
    if (currentTime == null) {
      return 0;
    }
    return currentTime.inMilliseconds / totalTime.inMilliseconds;
  }
  Duration _getDuration(double sliderValue) {
    final seconds = totalTime.inSeconds * sliderValue;
    return Duration(seconds: seconds.toInt());
  }

  String getdata(data) {
    DateTime todayDate = DateTime.parse(data);
    return DateFormat("yyyy/MM/dd                hh:mm").format(todayDate);
  }


  Widget check_record(file){
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(20.0)), //this right here
            child: Container(
              height: 200,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RaisedButton(
                      onPressed: () {
                        upload_Record(file);
                      },
                      child: Text(
                        "ارسال",
                        style: TextStyle(color: Colors.white),
                      ),
                      color: const Color(0xFF1BC0C5),
                    ),
                    SizedBox(width: 20,),
                    RaisedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "الغاء",
                        style: TextStyle(color: Colors.white),
                      ),
                      color: const Color(0xFF1BC0C5),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget checkrecord_beforesend( path) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Play_record(path);
      },
    );
  }

  Future<void> upload_Record(File file) async {
    var stats=false;
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      stats=true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      stats= true;
    }
    if (stats) {
      startLoading();
      StorageReference firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child('${auth.currentUser.uid}/chats')
          .child(channelId)
          .child(DateTime.now().toString());
      StorageUploadTask uploadTask = firebaseStorageRef.putFile(file);

      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
      final url = await firebaseStorageRef.getDownloadURL();
      firestore
          .collection('orders')
          .doc(channelId)
          .collection('messages')
          .add({
        'message': url,
        'type': 'record',
        'data': DateTime.now().toIso8601String().toString(),
        'sederEmail': current_email,
      }).whenComplete(() {
        print('uploaded');
        closeLoading();
        widget.notifyParent();
      });
    }
    else{
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
                  strokeWidth: 5, backgroundColor: appcolor,),
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
}
