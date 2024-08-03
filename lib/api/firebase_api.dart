import 'dart:io';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseApi {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications(BuildContext context) async {
    print("Init notifications part");
    var androidInitialization = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitialization = const DarwinInitializationSettings();

    var initializationSettings = InitializationSettings(
      android: androidInitialization,
      iOS: iosInitialization,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (payload) {
      },
    );

    // Request notification permissions
    print("Req permission");
    await _firebaseMessaging.requestPermission();
    final token = await _firebaseMessaging.getToken();
    print("This is token: $token");

    // Handle foreground messages
    // Messages which are shown during the app is running
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (Platform.isAndroid) {
        print("Platform is android");
        showNotification(message);
      }
      print('Foreground Message Title: ${message.notification?.title}');
      print('Foreground Message Body: ${message.notification?.body}');
      print('Foreground Message Data: ${message.data}');
      print("Now in this foreground state state");
    });
  }

  Future<void> showNotification(RemoteMessage message) async {
    const channelId = 'high_importance_channel';
    const channelName = 'High Importance Notifications';

    var androidChannel = AndroidNotificationChannel(
      channelId,
      channelName,
      importance: Importance.high,
    );

    var androidNotificationDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'Your channel description',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const darwinNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    var notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title ?? 'No Title',
      message.notification?.body ?? 'No Body',
      notificationDetails,
      payload: message.data['route'],
    );
  }
}
