// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:university_bus/screens/authscreen.dart';
import 'package:university_bus/widget/app_bar.dart';
import 'package:university_bus/widget/float_button.dart';
import 'package:university_bus/widget/gradient.dart';
import 'package:university_bus/widget/user_image.dart';

class DetailsDriver extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String imageUsers;
  final String userId;
  final String gender;
  final String phone;
  final String living;
  final String age;
  final String licenseStartDate;
  final String licenseEndDate;
  const DetailsDriver({
    required this.userName,
    required this.userEmail,
    required this.imageUsers,
    required this.userId,
    required this.gender,
    required this.phone,
    required this.living,
    required this.age,
    required this.licenseStartDate,
    required this.licenseEndDate,
    Key? key,
  }) : super(key: key);

  @override
  State<DetailsDriver> createState() => _DetailsDriverState();
}

class _DetailsDriverState extends State<DetailsDriver> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _livingController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _licenseStartDateController =
      TextEditingController();
  final TextEditingController _licenseEndDateController =
      TextEditingController();
  late DateTime _licenseStartDate;
  late DateTime _licenseEndDate;
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
    // Convert date strings to DateTime objects
    DateTime startDate =
        DateTime.parse(widget.licenseStartDate.split('/').reversed.join('-'));
    DateTime endDate =
        DateTime.parse(widget.licenseEndDate.split('/').reversed.join('-'));

    // Set initial values for date pickers
    _licenseStartDate = startDate;
    _licenseEndDate = endDate;
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
          'licenseStartDate': _licenseStartDateController.text.trim(),
          'licenseEndDate': _licenseEndDateController.text.trim(),
        }, SetOptions(merge: true));
        DocumentReference driverReference =
            FirebaseFirestore.instance.collection('drivers').doc(widget.userId);

        await driverReference.set({
          'username': _usernameController.text.trim(),
          'image': imageUrl,
          'timestamp': FieldValue.serverTimestamp(),
          'gender': _genderController.text.trim(),
          'phonenumber': _phoneController.text.trim(),
          'living': _livingController.text.trim(),
          'age': _ageController.text.trim(),
          'licenseStartDate': _licenseStartDateController.text.trim(),
          'licenseEndDate': _licenseEndDateController.text.trim(),
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
          'licenseStartDate': _licenseStartDateController.text.trim(),
          'licenseEndDate': _licenseEndDateController.text.trim(),
        }, SetOptions(merge: true));
        DocumentReference driverReference =
            FirebaseFirestore.instance.collection('drivers').doc(widget.userId);

        await driverReference.set({
          'username': _usernameController.text.trim(),
          'userType': 'driver',
          'timestamp': FieldValue.serverTimestamp(),
          'gender': _genderController.text.trim(),
          'phonenumber': _phoneController.text.trim(),
          'living': _livingController.text.trim(),
          'age': _ageController.text.trim(),
          'licenseStartDate': _licenseStartDateController.text.trim(),
          'licenseEndDate': _licenseEndDateController.text.trim(),
        }, SetOptions(merge: true));
      }

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
        title: 'my_profile'.tr(),
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
            Icons.arrow_forward,
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
                      fillColor: const Color.fromARGB(0, 255, 255, 255),
                      filled: true,
                      alignLabelWithHint: true,
                      labelText: 'email_label'.tr(),
                      labelStyle: const TextStyle(
                        color: Colors.black,
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black,
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
                      fillColor: const Color.fromARGB(0, 255, 255, 255),
                      filled: true,
                      alignLabelWithHint: true,
                      labelText: 'username_label'.tr(),
                      labelStyle: const TextStyle(
                        color: Colors.black,
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black,
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
                      fillColor: const Color.fromARGB(0, 255, 255, 255),
                      filled: true,
                      alignLabelWithHint: true,
                      labelText: 'phonenumber'.tr(),
                      labelStyle: const TextStyle(
                        color: Colors.black,
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black,
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
                      fillColor: const Color.fromARGB(0, 255, 255, 255),
                      filled: true,
                      alignLabelWithHint: true,
                      labelText: 'living'.tr(),
                      labelStyle: const TextStyle(
                        color: Colors.black,
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black,
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
                      fillColor: const Color.fromARGB(0, 255, 255, 255),
                      filled: true,
                      alignLabelWithHint: true,
                      labelText: 'age'.tr(),
                      labelStyle: const TextStyle(
                        color: Colors.black,
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black,
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
                  SizedBox(
                    child: Expanded(
                      flex: 6,
                      child: FormBuilderDateTimePicker(
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                        controller: _licenseStartDateController,
                        name: 'license_start_date'.tr(),
                        inputType: InputType.date,
                        initialValue: _licenseStartDate,
                        locale: const Locale('en', 'US'),
                        decoration: InputDecoration(
                          fillColor: const Color.fromARGB(0, 255, 255, 255),
                          filled: true,
                          labelStyle: const TextStyle(
                            color: Colors.black,
                          ),
                          labelText: 'license_start_date'.tr(),
                          hintText: _licenseStartDateController.text,
                          hintStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.sp,
                              color: Colors.black),
                          alignLabelWithHint: true,
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                            ),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 9, 41, 248),
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 5.0.w,
                            horizontal: 20.h,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15.h),
                  SizedBox(
                    child: Expanded(
                      flex: 6,
                      child: FormBuilderDateTimePicker(
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                        controller: _licenseEndDateController,
                        name: 'license_end_date'.tr(),
                        inputType: InputType.date,
                        initialValue: _licenseEndDate,
                        locale: const Locale('en', 'US'),
                        decoration: InputDecoration(
                          fillColor: const Color.fromARGB(0, 255, 255, 255),
                          filled: true,
                          labelStyle: const TextStyle(
                            color: Colors.black,
                          ),
                          labelText: 'license_end_date'.tr(),
                          hintText: _licenseEndDateController.text,
                          hintStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.sp,
                              color: Colors.black),
                          alignLabelWithHint: true,
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                            ),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 9, 41, 248),
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 5.0.w,
                            horizontal: 20.h,
                          ),
                        ),
                      ),
                    ),
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
                          style: const TextStyle(
                            color: Colors.white,
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
