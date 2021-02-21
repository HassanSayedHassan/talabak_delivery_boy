

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Message_page_clint_dileveryboy.dart';


class Chat_With_Clints extends StatefulWidget {
  @override
  _Chat_With_ClintsState createState() => _Chat_With_ClintsState();
}

class _Chat_With_ClintsState extends State<Chat_With_Clints> {
  //FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference users = FirebaseFirestore.instance.collection('orders');

  var appcolor=Color(0xFF12c0c7);
  List<String> my_orders=[];

  var current_uid;
  getshareschat() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //name= prefs.getString( 'name' );
    current_uid = prefs.getString( 'userID' );
    //final QuerySnapshot result =
    await FirebaseFirestore.instance.collection('orders') .get()
        .then((QuerySnapshot querySnapshot) => {
      querySnapshot.docs.forEach((doc) {
        if(doc["received_uid"]==current_uid){
          setState(() {
            my_orders.add(doc.id);
          });
        }
      })
    });
  }
    @override
    initState()  {

      getshareschat();

    }
  @override
  Widget build(BuildContext context) {
    return
      my_orders.length==0?
      Scaffold(
        body:Center(
          child: CircularProgressIndicator(strokeWidth: 5,backgroundColor: appcolor,),
        )
    )
    :
      Scaffold(
          body: StreamBuilder<QuerySnapshot>(
            stream: users.snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text("Loading");
              }

              return new ListView(
                // ignore: deprecated_member_use
                children: snapshot.data.documents.map((DocumentSnapshot document) {
                  return
                    my_orders.contains(document.id.toString())?
                    DrowListItem(
                      document.data()['sender_name'],
                      document.data()['sender_uid'],
                      document.data()['send_time'],
                      document.data()['orderId'],
                      document.data()['order_status'],
                    )
                        :
                SizedBox()
                  ;
                }).toList(),
              );
            },
          )
      )
    ;
  }

  Widget DrowListItem(String name, String uid, send_time,orderId,order_status) {
    Size size = MediaQuery.of(context).size;
    return InkWell(
      onTap: () {
       Navigator.push(context, MaterialPageRoute(builder: (c) {
         return Message_Dilevery_Clint( uid,orderId);}));
      },
      child: Card(
        elevation: 5,
        child: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: size.width * (60/360.0),
              height: size.height * (60/756.0),
            ),
            SizedBox(
              width: size.width * (20/360.0),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  " طلب بتاريخ      ${getdata(send_time)}  ",
                  style: TextStyle(
                    color: appcolor,
                    fontSize: size.width* (16/360.0),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      get_order_status(order_status),
                      style: TextStyle(
                        fontSize: size.width * (15/360.0),
                        color: Colors.black26,
                      ),
                    ),
                    SizedBox(width: size.width * (20/360.0),),
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: size.width * (15/360.0),
                        color: Colors.black26,
                      ),
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );

  }
  String getdata(data) {
    DateTime todayDate = DateTime.parse(data);
    return DateFormat("yyyy/MM/dd   hh:mm").format(todayDate);
  }
  String get_order_status(order_status){
    if(order_status==0) {
      return "تم الإلغاء";
    }
    if(order_status==1) {
      return "تم الارسال";
    }
    if(order_status==2) {
      return "تم القبول";
    }
    if(order_status==3) {
      return "تم الاستلام";
    }
    if(order_status==4) {
      return "تم التوصيل";
    }
  }
}
