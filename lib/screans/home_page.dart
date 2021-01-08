import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:talabak_delivery_boy/screans/Profile_screan.dart';
import 'package:talabak_delivery_boy/screans/chat_clints.dart';
import 'package:talabak_delivery_boy/webServices/locations.dart';

class HomeScrean extends StatefulWidget {
  @override
  _HomeScreanState createState() => _HomeScreanState();
}

class _HomeScreanState extends State<HomeScrean> {


  @override
  void initState() {
    Locations().getLocationContenously('status');
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
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedPageIndex,
        onTap: _selectPage,
        items: [
          Icon(
            Icons.account_circle,
            size: 30,
            color: Colors.white,
          ),
          Icon(
            Icons.chat,
            size: 30,
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
