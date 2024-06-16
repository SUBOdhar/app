import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


class Notify extends StatefulWidget {
  @override
  State<Notify> createState() => _NotifyState();
}

class _NotifyState extends State<Notify> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Notification Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NotificationScreen(),
    );
  }
}

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    initializeNotifications();
  }

  void initializeNotifications() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) {
    // Handle notification tapped logic here
    if (notificationResponse.payload != null) {
      print('Notification payload: ${notificationResponse.payload}');
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Notification'),
        content: Text('Payload: ${notificationResponse.payload}'),
      ),
    );
  }

  Future<void> _showNotification() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key2 = prefs.getString('key') ?? '';
    final url = Uri.parse('https://api.svp.com.np/notice');

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'key': key2,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String title = data['title'];
        final String body = data['body'];

        var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
          '001',
          'SVP',
          channelDescription: 'SVP notifier',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
         // icon: '@mipmap/ic_launcher', // Specify your icon here
        );
        var platformChannelSpecifics =
            NotificationDetails(android: androidPlatformChannelSpecifics);
        await flutterLocalNotificationsPlugin.show(
          0,
          title,
          body,
          platformChannelSpecifics,
          payload: 'Notification Payload',
        );

        print('Notification API call successful');
      } else {
        print(
            'Failed to call notification API: ${response.statusCode} ${response.reasonPhrase}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Failed to call notification API: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Local Notification'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _showNotification,
          child: const Text('Show Notification'),
        ),
      ),
    );
  }
}
