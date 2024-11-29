// ignore_for_file: use_build_context_synchronously, unused_local_variable

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:university_bus/screens/forgot_your_password.dart';
import 'package:university_bus/widget/app_bar.dart';
import 'package:university_bus/widget/email_message.dart';
import 'package:university_bus/widget/float_button.dart';
import 'package:university_bus/widget/gradient.dart';
import 'package:university_bus/widget/user_image.dart';

class LoginAndSignup extends StatefulWidget {
  const LoginAndSignup({super.key});

  @override
  State<LoginAndSignup> createState() => _LoginAndSignupState();
}

class _LoginAndSignupState extends State<LoginAndSignup> {
  String imagepersonal =
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcShB7IwN9gr4q2Tn-1CRfbgANRN-8SWlYMMy9iq467T1A&s';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _firebase = FirebaseAuth.instance;
  var _islogin = true;
  var _isPasswordVisible = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  File? _selectImage;
  var _isUploading = false;

  void _submit() async {
    final valid = _formKey.currentState!.validate();
    if (!valid) {
      return;
    }
    if (!_islogin && _selectImage == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('error'.tr()),
            content: Text('message_error_photo'.tr()),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('done_button'.tr()),
              ),
            ],
          );
        },
      );
      return;
    }
    try {
      setState(() {
        _isUploading = true;
      });
      if (_islogin) {
        final UserCredential userCredential =
            await _firebase.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        final UserCredential userCredential =
            await _firebase.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        final Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('user_image')
            .child('${userCredential.user!.uid}.jpg');

        await storageRef.putFile(_selectImage!);

        final imageUrl = await storageRef.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .collection('information')
            .doc(userCredential.user!.uid)
            .set({
          'userId': userCredential.user!.uid,
          'username': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
          'userType': 'student',
          'image': imageUrl,
          'latitude': 31.788938,
          'longitude': 35.928986,
          'timestamp': FieldValue.serverTimestamp(),
          'gender': '',
          'phonenumber': '',
          'living': '',
          'age': '',
          'college': '',
          'specialization': '',
          'academic_year': '',
        });
        DocumentReference locationReference2 = FirebaseFirestore.instance
            .collection('students')
            .doc(userCredential.user!.uid);
        await locationReference2.set({
          'userId': userCredential.user!.uid,
          'username': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
          'userType': 'student',
          'image': imageUrl,
          'latitude': 31.788938,
          'longitude': 35.928986,
          'timestamp': FieldValue.serverTimestamp(),
          'gender': '',
          'phonenumber': '',
          'living': '',
          'age': '',
          'college': '',
          'specialization': '',
          'academic_year': '',
        });
      }
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
    return StreamBuilder<Object>(
      stream: null,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: StyleAppBar(
            title:
                _islogin ? 'login_button'.tr() : 'create_account_button'.tr(),
            actionBar: IconButton(
              onPressed: () async {
                await EasyLocalization.of(context)?.setLocale(
                  EasyLocalization.of(context)?.locale ==
                          const Locale('en', 'US')
                      ? const Locale('ar', 'SA')
                      : const Locale('en', 'US'),
                );
              },
              icon: const Icon(
                Icons.translate,
              ),
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: StyleGradient(),
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(10.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/iu-logo-jordan.png',
                        width: 250.w,
                      ),
                      SizedBox(height: 40.h),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            if (!_islogin)
                              UserImagePicker(
                                onPickImage: (File pickedImage) {
                                  _selectImage = pickedImage;
                                },
                                imageCase: imagepersonal,
                              ),
                            SizedBox(height: 20.h),
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
                                  width: 30.0.w,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: IconButton(
                                      iconSize: 30.w,
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
                                        color: const Color.fromARGB(
                                            249, 14, 0, 138),
                                        size: 30.w,
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
                            SizedBox(height: 10.h),
                            if (!_islogin)
                              TextFormField(
                                style: const TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  labelText: 'username_label'.tr(),
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
                                  border: const OutlineInputBorder(),
                                ),
                                controller: _usernameController,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().length < 3) {
                                    return 'username_message'.tr();
                                  }
                                  return null;
                                },
                              ),
                            SizedBox(height: 10.h),
                            TextFormField(
                              style: const TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                labelText: 'password_label'.tr(),
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
                                border: const OutlineInputBorder(),
                                suffixIcon: SizedBox(
                                  width: 30.0.w,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: IconButton(
                                      iconSize: 30.w,
                                      onPressed: () {
                                        setState(() {
                                          _isPasswordVisible =
                                              !_isPasswordVisible;
                                        });
                                      },
                                      icon: Icon(
                                        _isPasswordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: _isPasswordVisible
                                            ? const Color.fromARGB(
                                                255, 82, 177, 255)
                                            : const Color.fromARGB(
                                                249, 14, 0, 138),
                                        size: 30.w,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              obscureText: !_isPasswordVisible,
                              controller: _passwordController,
                              validator: (value) {
                                if (value == null || value.trim().length < 5) {
                                  return 'password_message'.tr();
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 10.h),
                            if (_islogin)
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ForgotPassword(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'forgot_password'.tr(),
                                  style: TextStyle(
                                    fontSize: 25.sp,
                                    color:
                                        const Color.fromARGB(255, 46, 143, 255),
                                  ),
                                ),
                              ),
                            SizedBox(height: 15.h),
                            if (_isUploading)
                              const CircularProgressIndicator(
                                color: Color.fromARGB(255, 14, 0, 138),
                              ),
                            if (!_isUploading)
                              SizedBox(
                                width: 300.w,
                                child: ElevatedButton(
                                  onPressed: _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromARGB(255, 0, 14, 67),
                                  ),
                                  child: Text(
                                    _islogin
                                        ? 'login_button'.tr()
                                        : 'sign_up'.tr(),
                                    style: TextStyle(
                                      color: const Color.fromARGB(
                                          255, 255, 255, 255),
                                      fontSize: 25.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            if (!_isUploading)
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _islogin = !_islogin;
                                  });
                                },
                                child: Text(
                                  _islogin
                                      ? 'create_account_button'.tr()
                                      : 'already_have_account'.tr(),
                                  style: TextStyle(
                                    fontSize: 25.sp,
                                    color:
                                        const Color.fromARGB(249, 14, 0, 138),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          floatingActionButton: const MyFloatingActionButton(),
        );
      },
    );
  }
}
