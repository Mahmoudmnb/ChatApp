import 'package:chat_app/featurs/auth/presentaion/widgets/auth_card.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Stack(
        children: [
          Positioned(
            bottom: 0,
            child: Container(
              alignment: Alignment.center,
              height: deviceSize.height * 0.7,
              width: deviceSize.width,
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50)),
                  color: Color.fromARGB(255, 233, 203, 213)),
            ),
          ),
          Align(alignment: const Alignment(0, 0), child: AuthCard())
        ],
      ),
    );
  }
}
