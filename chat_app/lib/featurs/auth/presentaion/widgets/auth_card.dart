import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../../../../core/constant.dart';
import '../../../chat/presentaion/pages/home_page.dart';
import '../../domain/entities/user.dart';

// ignore: must_be_immutable
class AuthCard extends StatelessWidget {
  TextEditingController nameCon = TextEditingController();
  TextEditingController numberCon = TextEditingController();
  AuthCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color.fromARGB(255, 232, 209, 178)),
      height: 350,
      width: 250,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
              child: Text(
            'Sign in',
            style: TextStyle(
                fontSize: 30, fontWeight: FontWeight.bold, letterSpacing: 1),
          )),
          const SizedBox(height: 20),
          const Text('UserName'),
          const SizedBox(height: 10),
          TextFormField(
            keyboardType: TextInputType.name,
            controller: nameCon,
            decoration: const InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black))),
          ),
          const SizedBox(height: 10),
          const Text('phone number'),
          const SizedBox(height: 10),
          TextFormField(
            keyboardType: TextInputType.phone,
            controller: numberCon,
            decoration: const InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black))),
          ),
          const SizedBox(height: 10),
          TextButton(
            style: ButtonStyle(
                minimumSize: MaterialStatePropertyAll(
                    Size(MediaQuery.of(context).size.width * 0.8, 30)),
                backgroundColor: const MaterialStatePropertyAll(Colors.amber)),
            onPressed: () async {
              if (nameCon.text.isNotEmpty && numberCon.text.isNotEmpty) {
                DocumentSnapshot<Map<String, dynamic>>? isFound =
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(numberCon.text)
                        .get();
                String? token = await FirebaseMessaging.instance.getToken();

                if (isFound.data() == null) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(numberCon.text)
                      .set({
                    'name': nameCon.text,
                    'number': numberCon.text,
                    'token': token
                  });
                }
                Constant.currentUsre = UserEntity(
                    name: nameCon.text,
                    phoneNamber: numberCon.text,
                    token: token!);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => HomePage(
                    user: UserEntity(
                        token: token,
                        name: nameCon.text,
                        phoneNamber: numberCon.text),
                  ),
                ));
              }
            },
            child: const Text(
              'send code',
              style: TextStyle(fontSize: 20),
            ),
          )
        ],
      ),
    );
  }
}
