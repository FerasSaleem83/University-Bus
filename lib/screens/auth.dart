// ignore_for_file: use_key_in_widget_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:university_bus/screens/driverpage.dart';
import 'package:university_bus/screens/adminpage.dart';
import 'package:university_bus/screens/splash_wait.dart';
import 'package:university_bus/screens/studentpage.dart';
import 'package:university_bus/widget/error_operation.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late Future<QuerySnapshot<Map<String, dynamic>>> usernameFuture;

  @override
  void initState() {
    super.initState();
    usernameFuture = getUsers();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getUsers() async {
    User? user = FirebaseAuth.instance.currentUser;
    String userId = user!.uid;
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('information')
        .where('email', isEqualTo: user.email)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: usernameFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreenWait();
          } else if (snapshot.hasError) {
            return ErrorOperator(
              errorMessage: '${'error'.tr()}: ${snapshot.error}',
            );
          } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            final userType = snapshot.data!.docs.first['userType'];
            if (userType == 'student') {
              return const StudentScreen();
            } else if (userType == 'admin') {
              return const AdminScreen();
            } else if (userType == 'driver') {
              return const DriverScreen();
            } else {
              return ErrorOperator(errorMessage: 'no_loading_data'.tr());
            }
          } else {
            return const SplashScreenWait();
          }
        },
      ),
    );
  }
}
