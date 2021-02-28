
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Drow_record extends StatefulWidget {
  var message, senderEmail, data,current_email;
  Drow_record(this.message,this.senderEmail,this.data,this.current_email);
  @override
  _Drow_recordState createState() => _Drow_recordState(message,senderEmail,data,current_email);
}

class _Drow_recordState extends State<Drow_record> {
  var message, senderEmail, data,current_email;
  _Drow_recordState(this.message,this.senderEmail,this.data,this.current_email);


  bool _play = false;
  bool isPlaying=false;

  double _sliderValue=0.0;
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
                  Card(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            AudioWidget.network(
                              url: message,
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
                                  print("funushshshshsh");
                                  _play=false;

                                });
                              },
                            ),
                            Slider(
                              value: _sliderValue,
                             // min: 0,
                            //  max: _totalTime==null?0:_totalTime.inSeconds.toDouble(),
                             // divisions: 5,
                            //  label: _sliderValue.round().toString(),
                              activeColor: Colors.black,
                              inactiveColor: Colors.black26,
                              onChangeStart: (value) {
                                print("_sliderValue_sliderValue $_sliderValue");
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
                          ],
                        ),
                      ],
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

  double _getSliderValue() {
    if (_currentTime == null) {
      return 0;
    }

    return 1;
     /// _currentTime.inSeconds / _totalTime.inSeconds;
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
