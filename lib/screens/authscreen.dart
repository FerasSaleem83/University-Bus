// ignore_for_file: use_key_in_widget_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:university_bus/screens/auth.dart';
import 'package:university_bus/screens/login.dart';

class Auth extends StatefulWidget {
  const Auth({Key? key});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const AuthScreen();
        } else {
          return const LoginAndSignup();
        }
      },
    ));
  }
}
