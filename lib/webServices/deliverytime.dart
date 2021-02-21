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

      DateFormat dateFormat = DateFormat("kk:mm");
      String startime = dateFormat.format(DateTime.now());
      DateTime timeNow = dateFormat.parse(startime);

      print('delivery boy $startime  $nameOfDay $timeNow');
      switch (nameOfDay) {
        case 'Saturday':
          DateTime dateStr = new DateFormat("kk:mm").parse(value.sat_st);

          DateTime dateEnd = new DateFormat("kk:mm").parse(value.sat_end);

          print(
              'delivery boy ${timeNow.difference(dateEnd).isNegative} ${timeNow.difference(dateStr).isNegative} ');

          if (timeNow.isAfter(dateStr) && timeNow.isBefore(dateEnd)) {
            print('currennnt::::: ${value.dboyname} $nameOfDay is online');
            result = true;
          } else {
            print('currennnt::::: ${value.dboyname} $nameOfDay is offline');
            result = false;
          }
          break;
        case 'Sunday':
          DateTime dateStr = new DateFormat("kk:mm").parse(value.sun_st);

          DateTime dateEnd = new DateFormat("kk:mm").parse(value.sun_end);
          if (timeNow.isAfter(dateStr) && timeNow.isBefore(dateEnd)) {
            print('currennnt:: $dateStr:: $timeNow: $dateEnd::  is online');
            result = true;
          } else {
            print('currennnt:: $dateStr:: $timeNow: $dateEnd::  is online');
            result = false;
          }
          break;
        case 'Monday':
          DateTime dateStr = new DateFormat("kk:mm").parse(value.mon_st);

          DateTime dateEnd = new DateFormat("kk:mm").parse(value.mon_end);
          if (timeNow.isAfter(dateStr) && timeNow.isBefore(dateEnd)) {
            print('delivery boy ${value.dboyname} $nameOfDay is online');
            result = true;
          } else {
            print('delivery boy ${value.dboyname} $nameOfDay is offline');
            result = false;
          }
          break;
        case 'Tuesday':
          DateTime dateStr = new DateFormat("kk:mm").parse(value.tue_st);

          DateTime dateEnd = new DateFormat("kk:mm").parse(value.tue_end);
          if (timeNow.isAfter(dateStr) && timeNow.isBefore(dateEnd)) {
            print('delivery boy ${value.dboyname} $nameOfDay is online');
            result = true;
          } else {
            print('delivery boy ${value.dboyname} $nameOfDay is offline');
            result = false;
          }
          break;
        case 'Wednesday':
          DateTime dateStr = new DateFormat("kk:mm").parse(value.wen_st);

          DateTime dateEnd = new DateFormat("kk:mm").parse(value.wen_end);
          if (timeNow.isAfter(dateStr) && timeNow.isBefore(dateEnd)) {
            print('delivery boy ${value.dboyname} $nameOfDay is online');
            result = true;
          } else {
            print('delivery boy ${value.dboyname} $nameOfDay is offline');
            result = false;
          }
          break;
        case 'Thursday':
          DateTime dateStr = new DateFormat("kk:mm").parse(value.thu_st);

          DateTime dateEnd = new DateFormat("kk:mm").parse(value.thu_end);
          if (timeNow.isAfter(dateStr) && timeNow.isBefore(dateEnd)) {
            print('delivery boy ${value.dboyname} $nameOfDay is online');
            result = true;
          } else {
            print('delivery boy ${value.dboyname} $nameOfDay is offline');
            result = false;
          }
          break;
        case 'Friday':
          DateTime dateStr = new DateFormat("kk:mm").parse(value.fri_st);

          DateTime dateEnd = new DateFormat("kk:mm").parse(value.fri_end);
          if (timeNow.isAfter(dateStr) && timeNow.isBefore(dateEnd)) {
            print('delivery boy ${value.dboyname} $nameOfDay is online');
            result = true;
          } else {
            print('delivery boy ${value.dboyname} $nameOfDay is offline');
            result = false;
          }
          break;

        default:
          result = false;
      }
    });

    return result;
  }
}
