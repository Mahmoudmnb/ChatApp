import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'featurs/auth/presentaion/pages/auth_page.dart';
import 'featurs/auth/presentaion/provider/auth_provider.dart';
import 'featurs/chat/presentaion/providers/chat_provider.dart';
import 'firebase_options.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      theme: ThemeData(primaryColor: Colors.orangeAccent),
      debugShowCheckedModeBanner: false,
      home: const AuthPage(),
    );
  }
}

class Mnb extends StatelessWidget {
  const Mnb({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Expanded(child: Text('data')),
            Container(
              color: Colors.teal,
              child: const Text(
                'jfdkljfldjfd',
                style: TextStyle(fontSize: 50),
              ),
            )
          ],
        ),
      ),
    );
  }
}
