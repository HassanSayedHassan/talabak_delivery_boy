import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:talabak_delivery_boy/webServices/notifications.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:talabak_delivery_boy/screans/home_page.dart';
import 'package:talabak_delivery_boy/screans/log_in_screan.dart';
import 'package:talabak_delivery_boy/webServices/locations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Notifications notifications = new Notifications();
  SharedPreferences getUserData;
  Future<SharedPreferences> preferences = SharedPreferences.getInstance();
  String name = "";
  Widget app = Container();

  var current_name;
  Future check_current_user() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    current_name = prefs.getString( 'name' );
    if (current_name == ""||current_name==null) {
      setState(() {
        app = LogIn();
      });
    }else{
      setState(() {
        app = HomeScrean();
      });
    }
  }
  @override
  Future<void> initState()  {
    check_current_user();


    notifications.initOneSignal();
    notifications.setNotificationReceivedHandler();
    notifications.setNotificationOpenedHandler();
    super.initState();
  }

  @override
  Widget build(BuildContext context)  {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'طلبك_الموصل ',
      home: MyApplication(
        app: app,
      ),
      routes: {
        'homeScrean': (context) => new HomeScrean(),
        'login': (context) => new LogIn(),
      },
    );
  }
}

class MyApplication extends StatefulWidget {
  final Widget app;

  const MyApplication({Key key, this.app}) : super(key: key);
  @override
  _MyApplicationState createState() => _MyApplicationState();
}

class _MyApplicationState extends State<MyApplication> {
  Locations locations;

  @override
  void initState() {
    locations = new Locations();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    locations.checkRequestPermission().then((value) {
      print("status: $value");
      switch (value) {
        case "denied":
          _showAlert(context);
          break;
        case "deniedForEver":
          _showAlert(context);
          break;
        default:
      }
    });
    return widget.app;
  }

  void _showAlert(BuildContext context) {
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        locations.requestLocation();
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Location permission"),
      content: Text(
          "In order to benefit from the application properly,\n the site service must be activated, and that is to choose the nearest delegate to collect the images within the fastest time"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
