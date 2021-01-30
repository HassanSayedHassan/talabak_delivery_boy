import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Notifications {
  setNotificationReceivedHandler() {
    OneSignal.shared
        .setNotificationReceivedHandler((OSNotification notification) {
      // will be called whenever a notification is received
    });
  }

  setNotificationOpenedHandler() {
    OneSignal.shared
        .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      // will be called whenever a notification is opened/button pressed.
    });
  }

  Future<String> getPlayerID() async {
    var status = await OneSignal.shared.getPermissionSubscriptionState();
    String playerId = status.subscriptionStatus.userId;

    return playerId;
  }

  postNotification(String playerID, String title, String content) async {
    var notification = OSCreateNotification(
        playerIds: [playerID],
        content: content,
        heading: title,
        buttons: [
          OSActionButton(text: "Ok", id: "Verification"),
        ]);

    var response = await OneSignal.shared.postNotification(notification);
  }
}
