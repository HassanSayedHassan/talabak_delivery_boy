
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Fire_baseDeliveryTime {
  bool result = true;
  var flag=1;
  Future<bool> fire_base_getDeliveryTime(uid) async {


    var sat_st;
    var sat_end;

    var sun_st;
    var sun_end;

    var mon_st;
    var mon_end;

    var tue_st;
    var tue_end;

    var wen_st;
    var wen_end;

    var thu_st;
    var thu_end;

    var fri_st;
    var fri_end;

   await   FirebaseFirestore.instance
        .collection('delivery_boys')
        .doc(uid).collection("times").doc("times")
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        sat_st= documentSnapshot.data()['sat_st'];
        sat_end= documentSnapshot.data()['sat_end'];

        sun_st= documentSnapshot.data()['sun_st'];
        sun_end= documentSnapshot.data()['sun_end'];

        mon_st= documentSnapshot.data()['mon_st'];
        mon_end= documentSnapshot.data()['mon_end'];

        tue_st= documentSnapshot.data()['tue_st'];
        tue_end= documentSnapshot.data()['tue_end'];

        wen_st= documentSnapshot.data()['wen_st'];
        wen_end= documentSnapshot.data()['wen_end'];

        thu_st= documentSnapshot.data()['thu_st'];
        thu_end= documentSnapshot.data()['thu_end'];

        fri_st= documentSnapshot.data()['fri_st'];
        fri_end= documentSnapshot.data()['fri_end'];
      } else {
        print("doccno");
        flag=0;
        return result = false;
        print('Document does not exist on the database');
      }
    }).whenComplete(() {

    if(flag==1){
      String nameOfDay = DateFormat('EEEE').format(DateTime.now()).toString().trim();

      switch (nameOfDay) {
        case 'Saturday':
          DateTime dateStr = new DateFormat('yyyy-MM-dd HH:mm').parse("${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day} $sat_st");
          DateTime dateEnd = new DateFormat('yyyy-MM-dd HH:mm').parse("${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day} $sat_end");

          if ( DateTime.now().isAfter(dateStr)  && DateTime.now().isBefore(dateEnd)) {

            print("yessss1");
            return result = true;

          }
          else{
            print("no000");
            return    result =  false;
          }
          break;
        case 'Sunday':
          DateTime dateStr = new DateFormat('yyyy-MM-dd HH:mm').parse("${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day} $sun_st");
          DateTime dateEnd = new DateFormat('yyyy-MM-dd HH:mm').parse("${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day} $sun_end");

          if ( DateTime.now().isAfter(dateStr)  && DateTime.now().isBefore(dateEnd)) {

            print("yessss1");
            return result = true;

          }
          else{
            print("no000");
            return    result =  false;
          }
          break;
        case 'Monday':
          DateTime dateStr = new DateFormat('yyyy-MM-dd HH:mm').parse("${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day} $mon_st");
          DateTime dateEnd = new DateFormat('yyyy-MM-dd HH:mm').parse("${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day} $mon_end");

          if ( DateTime.now().isAfter(dateStr)  && DateTime.now().isBefore(dateEnd)) {

            print("yessss1");
            return result = true;

          }
          else{
            print("no000");
            return    result =  false;
          }
          break;
        case 'Tuesday':
          DateTime dateStr = new DateFormat('yyyy-MM-dd HH:mm').parse("${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day} $tue_st");
          DateTime dateEnd = new DateFormat('yyyy-MM-dd HH:mm').parse("${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day} $tue_end");


          print("dateStrdateStr ${dateStr}   ${dateStr.minute}");
          print("dateEnddateEnd ${dateEnd}   ${dateEnd.minute}");

          print("nowhour  ${DateTime.now()} ");
          print("nowmin  ${DateTime.now().minute} ");

          if ( DateTime.now().isAfter(dateStr)  && DateTime.now().isBefore(dateEnd)) {

            print("yessss1");
            return result = true;

          }
          else{
            print("no000");
            return    result =  false;
          }

          break;
        case 'Wednesday':
          DateTime dateStr = new DateFormat('yyyy-MM-dd HH:mm').parse("${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day} $wen_st");
          DateTime dateEnd = new DateFormat('yyyy-MM-dd HH:mm').parse("${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day} $wen_end");

          if ( DateTime.now().isAfter(dateStr)  && DateTime.now().isBefore(dateEnd)) {

            print("yessss1");
            return result = true;

          }
          else{
            print("no000");
            return    result =  false;
          }
          break;
        case 'Thursday':
          DateTime dateStr = new DateFormat('yyyy-MM-dd HH:mm').parse("${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day} $thu_st");
          DateTime dateEnd = new DateFormat('yyyy-MM-dd HH:mm').parse("${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day} $thu_end");

          if ( DateTime.now().isAfter(dateStr)  && DateTime.now().isBefore(dateEnd)) {

            print("yessss1");
            return result = true;

          }
          else{
            print("no000");
            return    result =  false;
          }
          break;
        case 'Friday':
          DateTime dateStr = new DateFormat('yyyy-MM-dd HH:mm').parse("${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day} $fri_st");
          DateTime dateEnd = new DateFormat('yyyy-MM-dd HH:mm').parse("${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day} $fri_end");

          if ( DateTime.now().isAfter(dateStr)  && DateTime.now().isBefore(dateEnd)) {

            print("yessss1");
            return result = true;

          }
          else{
            print("no000");
            return    result =  false;
          }
          break;

        default:
      }
    }

    });
    return result;
  }
}

