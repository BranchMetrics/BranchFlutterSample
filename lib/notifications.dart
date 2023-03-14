import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'branch_utils.dart';

late FlutterLocalNotificationsPlugin localNotificationsPlugin;

Future<void> setupLocalNotificationsAsync() async {
  localNotificationsPlugin = FlutterLocalNotificationsPlugin();
  // initialize the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings();
  final LinuxInitializationSettings initializationSettingsLinux =
      LinuxInitializationSettings(defaultActionName: 'Open notification');
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux);
  await localNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);
}

/*
  Initializes the notification system
  • calling this function inside of initState()
  • initState() cannot be marked async so had to wrap 
  • setupLocalNotificationsAsync() inside of setupLocalNotifications()
*/
void setupLocalNotifications() async {
  await setupLocalNotificationsAsync();
}

/*
  Trigger a local notification
  • Immediately (no timer delay)
  • Payload is the Branch link as a String
*/
void triggerLocalNotification(
    String title, String message, String deepLink) async {
  //for Android
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails('1234', 'Rob G\'s channel',
          channelDescription: 'A channel about superheros',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker');

  //for iOS
  const DarwinNotificationDetails iosNotificationDetails =
      DarwinNotificationDetails();

  //for both platforms
    const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails, iOS: iosNotificationDetails);
  await localNotificationsPlugin.show(0, title, message, notificationDetails,
      payload: deepLink);
}
