// ignore_for_file: library_private_types_in_public_api

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:university_bus/screens/authscreen.dart';
import 'package:university_bus/widget/gradient.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(
      const Duration(seconds: 5),
      () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const Auth(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: StyleGradient(),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(15.0.w),
            child: Column(
              children: [
                Image.asset(
                  'assets/images/logoSplashApp.png',
                  width: 300.w,
                  height: 200.h,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 150.h),
                    Image.asset(
                      'assets/images/logoBus.png',
                      width: 350.w,
                      height: 350.h,
                    ),
                    SizedBox(height: 20.h),
                    Center(
                      child: Column(
                        children: [
                          SizedBox(height: 20.h),
                          Text(
                            'splash_screen'.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              letterSpacing: 1,
                              fontSize: 35.w,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w900,
                              color: const Color.fromARGB(255, 2, 32, 142),
                              decorationThickness: 3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
