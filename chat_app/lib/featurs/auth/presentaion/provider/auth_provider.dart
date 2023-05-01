import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool success = true;
  Future<bool> signIn() async {
    // FirebaseAuth auth = FirebaseAuth.instance;
    // String myNumber = '+963968108307';
    // String seriatelNumber = '+963980573740';
    // String abdNumber = '+963947276369';
    // await auth.verifyPhoneNumber(
    //   timeout: const Duration(minutes: 1),
    //   forceResendingToken: 10,
    //   phoneNumber: myNumber,
    //   verificationCompleted: (phoneAuthCredential) async {
    //     await auth.signInWithCredential(phoneAuthCredential);
    //     success = true;
    //   },
    //   verificationFailed: (error) {
    //     success = false;
    //     print(error);
    //   },
    //   codeSent: (verificationId, forceResendingToken) async {
    //     String smsCode = '123123';
    //     // Create a PhoneAuthCredential with the code
    //     PhoneAuthCredential credential = PhoneAuthProvider.credential(
    //         verificationId: verificationId, smsCode: smsCode);
    //     var s = await auth.signInWithCredential(credential);
    //     success = true;
    //   },
    //   codeAutoRetrievalTimeout: (verificationId) {
    //     success = false;
    //     print('out');
    //   },
    // );

    return success;
  }
}
