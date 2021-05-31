import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Notifications {


  initOneSignal()async{

    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
    OneSignal.shared.init(
        "ad1fd0eb-c304-4519-93d3-8af4f58260b4",
        iOSSettings: {
          OSiOSSettings.autoPrompt: false,
          OSiOSSettings.inAppLaunchUrl: false
        }
    );
    OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);

// The promptForPushNotificationsWithUserResponse function will show the iOS push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
    await OneSignal.shared.promptUserForPushNotificationPermission(fallbackToSettings: true);
  }
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
