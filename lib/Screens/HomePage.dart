import 'dart:convert';

import 'package:fire_project/Screens/Notification_Services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  NotificationsServices notificationsServices = NotificationsServices();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    notificationsServices.firebaseInIt(context);
    notificationsServices.requestNotificationPermission();
    notificationsServices.setupIneractionMessage(context);
    // notificationsServices.isTokenRefresh();
    notificationsServices.getDeviceToken().then((value) {
      if (kDebugMode)
      print('device token');
      print(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: Center(
        child: TextButton(
          onPressed: (){
            notificationsServices.getDeviceToken().then((value)async{
              var data = {
                'to' : 'cuxQqyJIS1iK3WkpOEvAB5:APA91bFE-JXpWYbIZRqT07FMAS5hsx-6P-RzQ-gfiw3nk6JgCuu56euRnjIxWGrvLU_mT19i0OA1B_2r_k67cyuN-K6EVl7fHCbicRPihWACZIMtZl1GIR7H7tBvianLNCku0CW9Sb_Q',
                'priority' : 'high',
                'notification' : {
                  'title' : 'Ahmed',
                  'body' : 'I live in Pakistan',
                },
                'data' : {
                  'type' : 'msg',
                  'id' : '295'
                }
              };
              await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
              body: jsonEncode(data),
              headers: {
                'Content-Type': 'application/json; charset=UTF-8',
                'Authorization' : 'key=AAAAhhmyyjQ:APA91bFyiyMF212ep5nf40upOaF7y4NYmGqEzCZj9FGuZxI8jAaJp_chzhyqvmNo1k6CqvF_U5c9cHtLLfScvSgZt0vaA0H5Z5HpIkRza2XjEVk5XkNW95KAiL7NGMI_G-uymHHlolLL'
              }
              );
            });
          },
          child: Text('Send Notifications'),
        ),
      ),
    );
  }
}
