
import 'dart:io' as io;
import 'package:assets_audio_player/assets_audio_player.dart';
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
import 'package:toast/toast.dart';
class Play_record extends StatefulWidget {
  var path;
  final LocalFileSystem localFileSystem;

  Play_record(this.path,{localFileSystem}):
        this.localFileSystem = localFileSystem ?? LocalFileSystem();



  @override
  _PlayRecordState createState() => _PlayRecordState(path);
}

class _PlayRecordState extends State<Play_record> {
  var path;
  _PlayRecordState(path);
  bool _play = false;
  bool isPlaying=false;

  double _sliderValue;
  bool _userIsMovingSlider;
  Duration _currentTime;
  Duration _totalTime;

  var appcolor = Color(0xFF12c0c7);
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
    return Container(
      padding: EdgeInsets.symmetric(vertical: 7, horizontal: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
     //   crossAxisAlignment: senderEmail == current_email
       //     ? CrossAxisAlignment.end
         //   : CrossAxisAlignment.start,
        children: [
          Material(
            borderRadius: BorderRadius.circular(10),
            elevation: 5,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              child: Column(
                children: [
                  Card(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            AudioWidget.assets(
                             path: path,
                              play: _play,

                              child:InkWell(
                                onTap: (){
                                  setState(() {
                                    _play = !_play;
                                  });
                                },
                                child: Icon(_play?Icons.stop:Icons.play_arrow,size: 38,
                                ),
                              ) ,


                              onReadyToPlay: (duration) {
                                print(duration);
                              },
                              onPositionChanged: (current, duration) {
                                setState(() {
                                  _currentTime=current;
                                  _totalTime=duration;

                                });
                              },
                              onFinished: (){
                                setState(() {
                                  _play=false;
                                });
                              },
                            ),
                            Slider(
                              value: _sliderValue ,
                              activeColor: Theme.of(context).textTheme.bodyText2.color,
                              inactiveColor: Theme.of(context).disabledColor,
                              onChangeStart: (value) {
                                _userIsMovingSlider = true;
                              },
                              // 2
                              onChanged: (value) {
                                setState(() {
                                  _sliderValue = value;
                                });
                              },
                              // 3
                              onChangeEnd: (value) {
                                _userIsMovingSlider = false;
                                final currentTime = _getDuration(value);
                                // assetsAudioPlayer.seek(currentTime);
                              },
                            ),
                            Text(path.toString())
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getSliderValue() {
    if (_currentTime == null) {
      return 0;
    }

    return _currentTime.inMilliseconds / _totalTime.inMilliseconds;
  }

  Duration _getDuration(double sliderValue) {
    final seconds = _totalTime.inSeconds * sliderValue;
    return Duration(seconds: seconds.toInt());
  }

  String getdata(data) {
    DateTime todayDate = DateTime.parse(data);
    return DateFormat("yyyy/MM/dd                hh:mm").format(todayDate);
  }
}
