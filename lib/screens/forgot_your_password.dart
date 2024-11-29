// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:university_bus/widget/email_message.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _emailController = TextEditingController();
  bool _isUploading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _submit() async {
    final valid = _formKey.currentState!.validate();
    if (!valid) {
      return;
    }

    try {
      setState(() {
        _isUploading = true;
      });
      FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('worng'.tr()),
            content: Text(
              'message_password_recovery'.tr(),
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _isUploading = false;
                  });
                  Navigator.of(context).pop;
                },
                child: Text(
                  'done_button'.tr(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Authentication failed'),
        ),
      );
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AlertDialog(
        backgroundColor: const Color.fromARGB(255, 197, 215, 230),
        title: Text('password_recovery'.tr()),
        scrollable: true,
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 16.h),
              TextFormField(
                style: const TextStyle(color: Colors.black),
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  labelText: 'email_label'.tr(),
                  labelStyle: const TextStyle(
                    color: Colors.black,
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black,
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black,
                    ),
                  ),
                  suffixIcon: SizedBox(
                    width: 24.0.w,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        iconSize: 15.w,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return const EmailMessage();
                            },
                          );
                        },
                        icon: Icon(
                          Icons.help,
                          color: const Color.fromARGB(255, 14, 0, 138),
                          size: 20.w,
                        ),
                      ),
                    ),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                textCapitalization: TextCapitalization.none,
                controller: _emailController,
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty ||
                      !value.contains('@iu.edu.jo')) {
                    return 'email_message'.tr();
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isUploading)
                    const CircularProgressIndicator(
                      color: Color.fromARGB(255, 14, 0, 138),
                    ),
                  if (!_isUploading)
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 14, 0, 138),
                        textStyle: const TextStyle(color: Colors.white),
                        padding: EdgeInsets.all(16.w),
                      ),
                      child: Text(
                        'send_password_reset_email'.tr(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  SizedBox(width: 20.w),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 128, 125, 125),
                      textStyle: const TextStyle(color: Colors.white),
                      padding: EdgeInsets.all(16.w),
                    ),
                    child: Text(
                      'cancel'.tr(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
