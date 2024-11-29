import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmailMessage extends StatelessWidget {
  const EmailMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color.fromARGB(255, 197, 215, 230),
      title: Text('email_message_title'.tr()),
      scrollable: true,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/emailmessage.png',
              width: 300.w,
              height: 300.h,
            ),
            SizedBox(height: 16.h),
            Text(
              'email_message_description'.tr(),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            'done_button'.tr(),
            style: const TextStyle(
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
