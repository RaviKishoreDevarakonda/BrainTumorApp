
import 'package:test_app/email.dart';
import 'package:test_app/forgotpassword.dart';
import 'package:test_app/homescreen2.dart';
import 'package:test_app/homescreen1.dart';
import 'package:test_app/login.dart';
import 'package:test_app/options.dart';
import 'package:test_app/otp.dart';
import 'package:test_app/phone.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:test_app/registration.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: 'login',
    routes: {
      'email': (context) => MyEmail(),
      'phone': (context) => MyPhone(),
      'otp': (context) => MyOTP(),
      'login': (context) => LoginScreen(),
      'register': (context) => RegistrationScreen(),
      'home1': (context) => MyHome(),
      'forgotpassword': (context) => ForgotPassword(),
      'options': (context) => OptionsPage(),
      'home2':(context) => MyHome1()
    },
  ));
}
