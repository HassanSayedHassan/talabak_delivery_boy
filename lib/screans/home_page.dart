import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talabak_delivery_boy/screans/Profile_screan.dart';
import 'package:talabak_delivery_boy/screans/chat_clints.dart';
import 'package:talabak_delivery_boy/webServices/locations.dart';

class HomeScrean extends StatefulWidget {
  @override
  _HomeScreanState createState() => _HomeScreanState();
}

class _HomeScreanState extends State<HomeScrean> {
  String name = 'hi';
  String profile_image;
  String current_uid;
  String phone;
  String playerID;
shared()async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //name= prefs.getString( 'name' );
  setState(() {
    current_uid = prefs.getString('userID');
    name = prefs.getString("name");
    playerID = prefs.getString("playerID");
    phone = prefs.getString("phone");
  });
  //
  // Locations locations = new Locations();
  // locations.getLocationContenously('status',current_uid,playerID,name,phone);
}
  @override
  void initState() {
  shared();
    super.initState();
  }

  List<Map<String, Object>> _pages = [
    {
      'page': Profile_Screan(),
      'title': 'Profile Page',
    },
    {
      'page': Chat_With_Clints(),
      'title': 'Orders',
    },
  /*  {
      'page': Notifications(),
      'title': 'Notifications',
    },
    {
      'page': Chat_With_Admin(),
      'title': 'Chat With Admin',
    },

    {
      'page': Stores_screan(),
      'title': 'Stores',
    },

   */
  ];

  int _selectedPageIndex =0;
  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedPageIndex,
        onTap: _selectPage,
        items: [
          Icon(
            Icons.account_circle,
            size: size.width * (30/360.0),
            color: Colors.white,
          ),
          Icon(
            Icons.chat,
            size: size.width * (30/360.0),
            color: Colors.white,
          ),
        ],
        color: Colors.green,
        buttonBackgroundColor: Color(0xFF12c0c7),
        backgroundColor: Colors.white,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 600),
      ),
      body: _pages[_selectedPageIndex]['page'],
    );
  }
}
