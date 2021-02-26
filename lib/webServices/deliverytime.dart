import 'package:talabak_delivery_boy/webServices/postViewModel.dart';
import 'package:talabak_delivery_boy/webServices/postViewModel.dart';
import 'package:intl/intl.dart';

class DeliveryTime {
  bool result = false;
  PostViewModel postViewModel = new PostViewModel();
  Future<bool> getDeliveryTime(String dboyid) async {
    print('delivery boy $dboyid ');
    await postViewModel.getDeliveryTime(dboyid).then((value) {
      String nameOfDay =
          DateFormat('EEEE').format(DateTime.now()).toString().trim();

      DateFormat dateFormat = DateFormat("HH:mm");
      String startime = dateFormat.format(DateTime.now());
      DateTime timeNow = dateFormat.parse(startime);

      print('delivery boy $startime  $nameOfDay $timeNow');
      switch (nameOfDay) {
        case 'Saturday':
          DateTime dateStr = new DateFormat("HH:mm").parse(value.sat_st);

          DateTime dateEnd = new DateFormat("HH:mm").parse(value.sat_end);

          print(
              'delivery boy ${timeNow.difference(dateEnd).isNegative} ${timeNow.difference(dateStr).isNegative} ');

          if (   (DateTime.now().hour>dateStr.hour)  &&
              (DateTime.now().hour<dateEnd.hour)){

            print("yessss");
            return result = true;
          } else if (   (DateTime.now().hour==dateStr.hour && DateTime.now().minute > dateStr.minute  )  ||
              (DateTime.now().hour==dateEnd.hour && DateTime.now().minute < dateEnd.minute  ) ){
            print("yessss");
            return result = true;
          }
          else{
            print("no000");
            return result = false;
          }
          break;
        case 'Sunday':
          DateTime dateStr = new DateFormat("HH:mm").parse(value.sun_st);

          DateTime dateEnd = new DateFormat("HH:mm").parse(value.sun_end);
          if (   (DateTime.now().hour>dateStr.hour)  &&
              (DateTime.now().hour<dateEnd.hour)){

            print("yessss");
            return result = true;
          } else if (   (DateTime.now().hour==dateStr.hour && DateTime.now().minute > dateStr.minute  )  ||
              (DateTime.now().hour==dateEnd.hour && DateTime.now().minute < dateEnd.minute  ) ){
            print("yessss");
            return result = true;
          }
          else{
            print("no000");
            return result = false;
          }
          break;
        case 'Monday':

          DateTime dateStr = new DateFormat("HH:mm").parse(value.mon_st);

          DateTime dateEnd = new DateFormat("HH:mm").parse(value.mon_end);

          if (   (DateTime.now().hour>dateStr.hour)  &&
              (DateTime.now().hour<dateEnd.hour)){

            print("yessss");
            return result = true;
          } else if (   (DateTime.now().hour==dateStr.hour && DateTime.now().minute > dateStr.minute  )  ||
              (DateTime.now().hour==dateEnd.hour && DateTime.now().minute < dateEnd.minute  ) ){
            print("yessss");
            return result = true;
          }
          else{
            print("no000");
            return result = false;
          }
          break;
        case 'Tuesday':
          DateTime dateStr = new DateFormat("HH:mm").parse(value.tue_st);

          DateTime dateEnd = new DateFormat("HH:mm").parse(value.tue_end);


          //  String string_time = new DateFormat("hh:mm").format(DateTime.now());
          // DateTime dateTime =DateTime.now().  DateFormat("hh:mm").;
        //  print("yessss  ${dateStr} ");
          // print("tetrr  ${dateTime} ${value.mon_st} ");
          if (   (DateTime.now().hour>dateStr.hour)  &&
              (DateTime.now().hour<dateEnd.hour)){

            print("yessss");
            return result = true;
          } else if (   (DateTime.now().hour==dateStr.hour && DateTime.now().minute > dateStr.minute  )  ||
              (DateTime.now().hour==dateEnd.hour && DateTime.now().minute < dateEnd.minute  ) ){
            print("yessss");
            return result = true;
          }
          else{
            print("no000");
            return result = false;
          }

          break;
        case 'Wednesday':
          DateTime dateStr = new DateFormat("HH:mm").parse(value.wen_st);

          DateTime dateEnd = new DateFormat("HH:mm").parse(value.wen_end);

          if (   (DateTime.now().hour>dateStr.hour)  &&
              (DateTime.now().hour<dateEnd.hour)){

            print("yessss");
            return result = true;
          } else if (   (DateTime.now().hour==dateStr.hour && DateTime.now().minute > dateStr.minute  )  ||
              (DateTime.now().hour==dateEnd.hour && DateTime.now().minute < dateEnd.minute  ) ){
            print("yessss");
            return result = true;
          }
          else{
            print("no000");
            return result = false;
          }
          break;
        case 'Thursday':
          DateTime dateStr = new DateFormat("HH:mm").parse(value.thu_st);

          DateTime dateEnd = new DateFormat("HH:mm").parse(value.thu_end);
          if (   (DateTime.now().hour>dateStr.hour)  &&
              (DateTime.now().hour<dateEnd.hour)){

            print("yessss");
            return result = true;
          } else if (   (DateTime.now().hour==dateStr.hour && DateTime.now().minute > dateStr.minute  )  ||
              (DateTime.now().hour==dateEnd.hour && DateTime.now().minute < dateEnd.minute  ) ){
            print("yessss");
            return result = true;
          }
          else{
            print("no000");
            return result = false;
          }
          break;
        case 'Friday':
          DateTime dateStr = new DateFormat("HH:mm").parse(value.fri_st);

          DateTime dateEnd = new DateFormat("HH:mm").parse(value.fri_end);
          print('deliverytime: ${dateStr.hour}:${dateStr.minute}::::${dateEnd.hour}:${dateEnd.minute}:::::${DateTime.now().hour}:${DateTime.now().minute}');
          if (   (DateTime.now().hour>dateStr.hour)  &&
              (DateTime.now().hour<dateEnd.hour)){

            print("yesss");
            return result = true;
          } else if (   (DateTime.now().hour==dateStr.hour && DateTime.now().minute > dateStr.minute  )  ||
              (DateTime.now().hour==dateEnd.hour && DateTime.now().minute < dateEnd.minute  ) ){
            print("yessssss");
            return result = true;
          }
          else{
            print("no000");
            return result = false;
          }
          break;

        default:

      }
    });

    return result;
  }
}
