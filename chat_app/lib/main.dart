import 'dart:convert';

import 'package:chat_app/core/constant.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'featurs/auth/presentaion/pages/auth_page.dart';
import 'featurs/auth/presentaion/provider/auth_provider.dart';
import 'featurs/chat/presentaion/providers/chat_provider.dart';
import 'firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Constant.localPath = await getApplicationDocumentsDirectory();
  RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => ChatProvider(),
        )
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          primaryColor: Colors.orangeAccent,
        ),
        debugShowCheckedModeBanner: false,
        home:  const AuthPage(),
        );
  }
}

class Noti extends StatefulWidget {
  const Noti({super.key});

  @override
  State<Noti> createState() => _NotiState();
}

class _NotiState extends State<Noti> {
  @override
  void initState() {
    getPermision();
    initInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
            onPressed: () async {
              var t = await FirebaseMessaging.instance.getToken();
              print(t);
              sendPushMessage('hi', 'title', t!);
            },
            child: const Text('Click me')),
      ),
    );
  }

  void initInfo() {
    var androidSettings =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var settings = InitializationSettings(android: androidSettings);
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) => print(details),
    );
    FirebaseMessaging.onMessage.listen((event) {
      print(event);
      BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
        event.notification!.body.toString(),
        htmlFormatBigText: true,
        contentTitle: event.notification!.title.toString(),
        htmlFormatContent: true,
      );
      AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'dbfood',
        'dbfood',
        importance: Importance.high,
        styleInformation: bigTextStyleInformation,
        priority: Priority.high,
        playSound: true,
      );
      NotificationDetails details =
          NotificationDetails(android: androidNotificationDetails);
      flutterLocalNotificationsPlugin.show(
          0, event.notification!.title, event.notification!.body, details,
          payload: event.data['title']);
      print('event');
    });
  }

  getPermision() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');
  }

  void sendPushMessage(String body, String title, String token) async {
    try {
      var s = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAApisdxjw:APA91bGy4m2H8sUXgHbDIuof13KaMqTjapWYf15Gcmd1-Z1xeA3Y858rUaoojcGh6lii9-p9wS6aMacQgxzVYqK9-bFPpQyf7QfrlgNOyyhkEFMM6_1iFyFMX_rHp1FZiq7gHf76IbJA'
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': body,
              'title': title,
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            "to": token,
          },
        ),
      );
      print(s.body);
      print('done');
      setState(() {});
    } catch (e) {
      print("error push notification");
    }
  }
}
