// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:university_bus/screens/authscreen.dart';
import 'package:university_bus/widget/app_bar.dart';
import 'package:university_bus/widget/float_button.dart';
import 'package:university_bus/widget/gradient.dart';
import 'package:university_bus/widget/user_image.dart';

class DetailsAdmin extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String imageUsers;
  final String userId;
  final String gender;
  final String phone;
  final String living;
  final String age;

  const DetailsAdmin({
    required this.userName,
    required this.userEmail,
    required this.imageUsers,
    required this.userId,
    required this.gender,
    required this.phone,
    required this.living,
    required this.age,
    Key? key,
  }) : super(key: key);

  @override
  State<DetailsAdmin> createState() => _DetailsAdminState();
}

class _DetailsAdminState extends State<DetailsAdmin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _livingController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  bool _isUploading = false;
  File? _selectImage;

  @override
  void initState() {
    super.initState();

    _emailController.text = widget.userEmail;
    _usernameController.text = widget.userName;
    _genderController.text = widget.gender;
    _phoneController.text = widget.phone;
    _livingController.text = widget.living;
    _ageController.text = widget.age;
  }

  void _updatUser() async {
    try {
      setState(() {
        _isUploading = true;
      });

      if (_selectImage != null) {
        // إذا كانت الصورة مختارة، قم بتحديث الصورة
        final Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('user_image')
            .child('${widget.userId}.jpg');
        await storageRef.putFile(_selectImage!);
        final imageUrl = await storageRef.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .collection('information')
            .doc(widget.userId)
            .set({
          'username': _usernameController.text.trim(),
          'image': imageUrl,
          'timestamp': FieldValue.serverTimestamp(),
          'gender': _genderController.text.trim(),
          'phonenumber': _phoneController.text.trim(),
          'living': _livingController.text.trim(),
          'age': _ageController.text.trim(),
        }, SetOptions(merge: true));
        DocumentReference driverReference =
            FirebaseFirestore.instance.collection('admins').doc(widget.userId);

        await driverReference.set({
          'username': _usernameController.text.trim(),
          'image': imageUrl,
          'timestamp': FieldValue.serverTimestamp(),
          'gender': _genderController.text.trim(),
          'phonenumber': _phoneController.text.trim(),
          'living': _livingController.text.trim(),
          'age': _ageController.text.trim(),
        }, SetOptions(merge: true));
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .collection('information')
            .doc(widget.userId)
            .set({
          'username': _usernameController.text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
          'gender': _genderController.text.trim(),
          'phonenumber': _phoneController.text.trim(),
          'living': _livingController.text.trim(),
          'age': _ageController.text.trim(),
        }, SetOptions(merge: true));
        DocumentReference driverReference =
            FirebaseFirestore.instance.collection('admins').doc(widget.userId);

        await driverReference.set({
          'username': _usernameController.text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
          'gender': _genderController.text.trim(),
          'phonenumber': _phoneController.text.trim(),
          'living': _livingController.text.trim(),
          'age': _ageController.text.trim(),
        }, SetOptions(merge: true));
      }
      setState(() {
        _isUploading = false;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('sucessfully'.tr()),
            content: Text('update_data'.tr()),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  setState(() {
                    _isUploading = false;
                  });
                  Navigator.pop(context);
                },
                child: Text('done_button'.tr()),
              ),
            ],
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isUploading = false;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('error'.tr()),
            content: Text(e.message ?? 'Authentication failed'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  setState(() {
                    _isUploading = false;
                  });
                  Navigator.pop(context);
                },
                child: Text('done_button'.tr()),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StyleAppBar(
        title: ''.tr(),
        actionBar: IconButton(
          onPressed: () async {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Auth(),
              ),
            );
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: StyleGradient(),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(15.w),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // image
                  UserImagePicker(
                    onPickImage: (File? pickedImage) {
                      setState(() {
                        _selectImage = pickedImage;
                      });
                    },
                    imageCase: widget.imageUsers,
                  ),
                  SizedBox(height: 15.h),
                  // email
                  TextFormField(
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      fillColor: const Color.fromARGB(255, 255, 255, 255),
                      filled: true,
                      alignLabelWithHint: true,
                      labelText: 'email_label'.tr(),
                      labelStyle: const TextStyle(
                        color: Colors.black,
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 9, 41, 248),
                        ),
                      ),
                    ),
                    readOnly: true,
                    controller: _emailController,
                  ),
                  SizedBox(height: 15.h),
                  //username
                  TextFormField(
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      fillColor: const Color.fromARGB(255, 255, 255, 255),
                      filled: true,
                      alignLabelWithHint: true,
                      labelText: 'username_label'.tr(),
                      labelStyle: const TextStyle(
                        color: Colors.black,
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 9, 41, 248),
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.name,
                    autocorrect: false,
                    textCapitalization: TextCapitalization.words,
                    controller: _usernameController,
                  ),

                  SizedBox(height: 15.h),
                  // phone
                  TextFormField(
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      fillColor: const Color.fromARGB(255, 255, 255, 255),
                      filled: true,
                      alignLabelWithHint: true,
                      labelText: 'phonenumber'.tr(),
                      labelStyle: const TextStyle(
                        color: Colors.black,
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 9, 41, 248),
                        ),
                      ),
                    ),
                    maxLength: 10,
                    keyboardType: TextInputType.phone,
                    autocorrect: false,
                    controller: _phoneController,
                  ),
                  SizedBox(height: 15.h),
                  //living
                  TextFormField(
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      fillColor: const Color.fromARGB(255, 255, 255, 255),
                      filled: true,
                      alignLabelWithHint: true,
                      labelText: 'living'.tr(),
                      labelStyle: const TextStyle(
                        color: Colors.black,
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 9, 41, 248),
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.name,
                    autocorrect: false,
                    textCapitalization: TextCapitalization.words,
                    controller: _livingController,
                  ),
                  SizedBox(height: 15.h),
                  //age
                  TextFormField(
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      fillColor: const Color.fromARGB(255, 255, 255, 255),
                      filled: true,
                      alignLabelWithHint: true,
                      labelText: 'age'.tr(),
                      labelStyle: const TextStyle(
                        color: Colors.black,
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 9, 41, 248),
                        ),
                      ),
                    ),
                    maxLength: 2,
                    keyboardType: TextInputType.number,
                    autocorrect: false,
                    controller: _ageController,
                  ),

                  SizedBox(height: 15.h),
                  if (_isUploading)
                    const CircularProgressIndicator(
                      color: Colors.blue,
                    ),
                  if (!_isUploading)
                    SizedBox(
                      width: 200.w,
                      child: ElevatedButton(
                        onPressed: _updatUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 0, 14, 67),
                        ),
                        child: Text(
                          'update'.tr(),
                          style: TextStyle(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            fontSize: 25.sp,
                          ),
                        ),
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
  }
}
