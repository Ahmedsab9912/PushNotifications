import 'dart:io';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'Message_Screen.dart';

class NotificationsServices {

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  //FUNCTION FOR THE PERMISSION
  void requestNotificationPermission()async{
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if(settings.authorizationStatus == AuthorizationStatus.authorized){
       print('user granted permission');
    }else if(settings.authorizationStatus == AuthorizationStatus.authorized){
       print('user granted previous permission');
    }else{
      print('user denied permission');
    }
  }


  // FUNCTION FOR THE TOKEN
  Future<String> getDeviceToken()async{
    String? token = await messaging.getToken();
    return token!;
  }

  void isTokenRefresh()async{
    messaging.onTokenRefresh.listen((event) {
      event.toString();
      print('refresh');
    });
  }

  //THIS FUNCTION IS USED TO SHOW THE TITLE AND BODY OF NOTIFICATION
  void firebaseInIt(BuildContext context){

    FirebaseMessaging.onMessage.listen((message) {
      if (kDebugMode) {
        print(message.notification!.title.toString());
        print(message.notification!.body.toString());
        print(message.data.toString());
        print(message.data['type']);
        print(message.data['id']);
      }

      if(Platform.isAndroid) {
        initLocalNotifications(context, message);
      }else {
        showNotification(message);
      }
    });
  }


  //SHOW NOTIFICATION FUNCTION
  Future<void> showNotification(RemoteMessage message)async {
    
    AndroidNotificationChannel channel = AndroidNotificationChannel(
        Random.secure().nextInt(100000).toString(),
        'Important Message',
        importance: Importance.max,

    );
    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        channel.id.toString(),
        channel.name.toString(),
        channelDescription: 'your channel description',
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'ticker',
    );

    DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(
      presentBadge: true,
      presentAlert: true,
      presentSound: true,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );
    Future.delayed(Duration.zero,() {
      _flutterLocalNotificationsPlugin.show(
          1,
          message.notification!.title.toString(),
          message.notification!.body.toString(),
          notificationDetails);
    }
        );
  }

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();



  //FUNCTION FOR THE LOCAL NOTIFICATION IN MOBILE APP
  void initLocalNotifications(BuildContext context, RemoteMessage message)async{
    var androidInitializationSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitializationSettings = DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
    onDidReceiveNotificationResponse: (payload){
      handleMessage(context, message);
    }
    );
  }

  void handleMessage(BuildContext context, RemoteMessage message){
    if(message.data['type'] == 'msg'){
      Navigator.push(context, MaterialPageRoute(builder: (context)=> MessageScreen(
        id: message.data['id'],
      )));
    }
  }

  //WHEN APP IS TERMINATED
  Future<void> setupIneractionMessage(BuildContext context)async{
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if(initialMessage != null){
      handleMessage(context, initialMessage);
    }

    //WHEN APP IS IN BACKGROUND
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleMessage(context, event);
    });
  }

}