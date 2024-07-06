import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:svp/main.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseApi {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotify() async {
    // Request notification permissions
    await _firebaseMessaging.requestPermission();
    final String? fcmToken = await _firebaseMessaging.getToken();
    print('Token: $fcmToken');

    // Initialize push notifications
    await initPushNotify();
    _configureLocalNotification();
  }

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;
    navKey.currentState?.pushNamed('/notifyscreen', arguments: message);
  }

  Future<void> initPushNotify() async {
    // Handle messages that open the app from a terminated state
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    // Handle messages when the app is in the background or foreground
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a message while in foreground: ${message.messageId}');
      if (message.notification != null) {
        _showNotification(message);
      }
    });
  }

  void _configureLocalNotification() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      '01', // Change this to your channel ID
      'Svp', // Change this to your channel name
      sound: RawResourceAndroidNotificationSound('custom_sound'),
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      message.notification?.title ?? 'Default Title',
      message.notification?.body ?? 'Default Body',
      platformChannelSpecifics,
      payload: 'Custom_Sound',
    );
  }
}
