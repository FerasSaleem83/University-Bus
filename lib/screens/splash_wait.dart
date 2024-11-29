// ignore_for_file: library_private_types_in_public_api

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:university_bus/widget/gradient.dart';

// شاشة الانتظار
class SplashScreenWait extends StatefulWidget {
  const SplashScreenWait({super.key});

  @override
  _SplashScreenWaitState createState() => _SplashScreenWaitState();
}

class _SplashScreenWaitState extends State<SplashScreenWait> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: StyleGradient(),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logoBus.png',
              width: 350.w,
              height: 350.h,
            ),
            SizedBox(height: 20.h),
            Center(
              child: Column(
                children: [
                  Text(
                    'loading'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      letterSpacing: 1,
                      fontSize: 35.sp,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w900,
                      color: const Color.fromARGB(255, 15, 7, 89),
                      decorationThickness: 3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
