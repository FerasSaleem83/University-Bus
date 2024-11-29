// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:university_bus/widget/app_bar.dart';
import 'package:university_bus/widget/email_message.dart';
import 'package:university_bus/widget/float_button.dart';
import 'package:university_bus/widget/gradient.dart';
import 'package:university_bus/widget/user_image.dart';

class AddDriver extends StatefulWidget {
  final String password;
  final String userEmail;

  const AddDriver({super.key, required this.password, required this.userEmail});

  @override
  State<AddDriver> createState() => _AddDriverState();
}

class _AddDriverState extends State<AddDriver> {
  final FirebaseAuth _firebase = FirebaseAuth.instance;

  late Future<DocumentSnapshot<Map<String, dynamic>>> usernameFuture;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _jobNumberController = TextEditingController();
  final TextEditingController _licenseStartDateController =
      TextEditingController();
  final TextEditingController _licenseEndDateController =
      TextEditingController();
  List<int> _busNumbers = [];
  int? busNumber;
  bool _isUploading = false;

  File? _selectImage;

  @override
  void initState() {
    super.initState();
    _uploadData();
    usernameFuture = getUsers();
    viewBusNumbers();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUsers() async {
    User user = FirebaseAuth.instance.currentUser!;
    String userId = user.uid;
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('users')
        .doc(userId)
        .collection('information')
        .doc(userId)
        .get();

    return snapshot;
  }

  _uploadData() {
    setState(
      () {
        _isUploading = true;
      },
    );
    FirebaseFirestore.instance
        .collection('buses')
        .snapshots()
        .map((snapshot) => snapshot.docs);

    setState(
      () {
        _isUploading = false;
      },
    );
  }

  void viewBusNumbers() async {
    QuerySnapshot busSnapshot =
        await FirebaseFirestore.instance.collection('buses').get();
    QuerySnapshot driverSnapshot =
        await FirebaseFirestore.instance.collection('drivers').get();

    List<int> assignedBusNumbers =
        driverSnapshot.docs.map((doc) => doc['busNumber'] as int).toList();

    setState(() {
      _busNumbers = busSnapshot.docs
          .map((doc) => doc['busNumber'] as int)
          .where((busNumber) => !assignedBusNumbers.contains(busNumber))
          .toList();
      _busNumbers.sort();
    });

    if (_busNumbers.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('error'.tr()),
            content: Text('no_buses_available'
                .tr()
                .tr()), // Add translation key in your localization files
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).pop(); // Close the current page
                },
                child: Text('done_button'.tr()),
              ),
            ],
          );
        },
      );
    }
  }

  void _addDriver() async {
    final valid = _formKey.currentState!.validate();
    if (!valid) {
      return;
    }
    if (_selectImage == null) {
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
        'driverId': userCredential.user!.uid,
        'driverName': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'userType': 'driver',
        'image': imageUrl,
        'licenseStartDate': _licenseStartDateController.text.trim(),
        'licenseEndDate': _licenseEndDateController.text.trim(),
        'JobNumber': _jobNumberController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'busNumber': busNumber,
        'gender': '',
        'phonenumber': '',
        'living': '',
        'age': '',
      });

      DocumentReference driverReference = FirebaseFirestore.instance
          .collection('drivers')
          .doc(userCredential.user!.uid);

      await driverReference.set(
        {
          'driverId': userCredential.user!.uid,
          'driverName': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'userType': 'driver',
          'image': imageUrl,
          'latitude': 31.788938,
          'longitude': 35.928986,
          'licenseStartDate': _licenseStartDateController.text.trim(),
          'licenseEndDate': _licenseEndDateController.text.trim(),
          'JobNumber': _jobNumberController.text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
          'busNumber': busNumber,
          'gender': '',
          'phonenumber': '',
          'living': '',
          'age': '',
        },
      );

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('sucessfully'.tr()),
            content: Text('message_add_driver'.tr()),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  setState(() {
                    _isUploading = false;
                  });
                  FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: widget.userEmail, password: widget.password);
                  Navigator.pop(context);
                  Navigator.of(context).pop();
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
                  Navigator.of(context).pop();
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
    return StreamBuilder<Object>(
      stream: null,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: StyleAppBar(title: 'add_driver'.tr()),
          body: Container(
            decoration: BoxDecoration(
              gradient: StyleGradient(),
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              //image
                              UserImagePicker(
                                onPickImage: (File pickedImage) {
                                  _selectImage = pickedImage;
                                },
                                imageCase: '',
                              ),
                              SizedBox(height: 20.h),
                              //email
                              TextFormField(
                                style: const TextStyle(color: Colors.black),
                                cursorColor: Colors.black,
                                decoration: InputDecoration(
                                  labelText: 'email_label'.tr(),
                                  labelStyle: TextStyle(
                                    fontSize: 25.sp,
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
                                        iconSize: 25.w,
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
                                              255, 70, 70, 70),
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
                              //username
                              TextFormField(
                                style: const TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  labelText: 'username_label'.tr(),
                                  labelStyle: TextStyle(
                                    fontSize: 25.sp,
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
                              //job number
                              TextFormField(
                                style: const TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  labelText: 'job_number'.tr(),
                                  labelStyle: TextStyle(
                                    fontSize: 25.sp,
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
                                controller: _jobNumberController,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().length < 5) {
                                    return 'job_number_message'.tr();
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10.h),
                              //password
                              TextFormField(
                                style: const TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  labelText: 'password_label'.tr(),
                                  labelStyle: TextStyle(
                                    fontSize: 25.sp,
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
                                    width: 24.0.w,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: IconButton(
                                        iconSize: 25.w,
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
                                                  255, 103, 184, 250)
                                              : const Color.fromARGB(
                                                  255, 70, 70, 70),
                                          size: 30.w,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                obscureText: !_isPasswordVisible,
                                controller: _passwordController,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().length < 5) {
                                    return 'password_message'.tr();
                                  }
                                  return null;
                                },
                              ),

                              SizedBox(height: 15.h),
                              Row(
                                //////// License date
                                children: [
                                  Expanded(
                                    flex: 6,
                                    child: FormBuilderDateTimePicker(
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                      validator: (value) {
                                        if (value == null) {
                                          return 'license_start_date_message'
                                              .tr();
                                        }
                                        return null;
                                      },
                                      controller: _licenseStartDateController,
                                      name: 'license_start_date'.tr(),
                                      inputType: InputType.date,
                                      locale: const Locale('en', 'US'),
                                      format: DateFormat('dd/MM/yyyy', 'en'),
                                      decoration: InputDecoration(
                                        labelStyle: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25.sp,
                                            color: Colors.black),
                                        labelText: 'license_start_date'.tr(),
                                        hintText: 'license_start_date'.tr(),
                                        hintStyle: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25.sp,
                                            color: Colors.black),
                                        alignLabelWithHint: true,
                                        floatingLabelAlignment:
                                            FloatingLabelAlignment.center,
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.always,
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.black,
                                            width: 1.0.w,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10.0.r),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 5.0.w,
                                          horizontal: 20.h,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 6,
                                    child: FormBuilderDateTimePicker(
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                      validator: (value) {
                                        if (value == null) {
                                          return 'license_end_date_message'
                                              .tr();
                                        }
                                        return null;
                                      },
                                      controller: _licenseEndDateController,
                                      name: 'license_end_date'.tr(),
                                      inputType: InputType.date,
                                      locale: const Locale('en', 'US'),
                                      format: DateFormat('dd/MM/yyyy', 'en'),
                                      decoration: InputDecoration(
                                        labelStyle: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25.sp,
                                            color: Colors.black),
                                        labelText: 'license_end_date'.tr(),
                                        hintText: 'license_end_date'.tr(),
                                        hintStyle: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25.sp,
                                            color: Colors.black),
                                        alignLabelWithHint: true,
                                        floatingLabelAlignment:
                                            FloatingLabelAlignment.center,
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.always,
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.black,
                                            width: 1.0.w,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10.0.r),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.blue,
                                            width: 2.5.w,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10.0.r),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 5.0.w,
                                          horizontal: 20.h,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 15.h),
                              DropdownButtonFormField<int>(
                                value: busNumber,
                                validator: (value) {
                                  if (value == null) {
                                    return 'busNumber_message'.tr();
                                  }
                                  return null;
                                },
                                items: _busNumbers.map((int busNumber) {
                                  return DropdownMenuItem<int>(
                                    alignment: AlignmentDirectional.center,
                                    value: busNumber,
                                    child: Text(
                                      '$busNumber',
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    busNumber = newValue;
                                  });
                                },
                                style: TextStyle(
                                  fontSize: 25.sp,
                                  color: Colors.black,
                                ),
                                decoration: InputDecoration(
                                  labelStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25.sp,
                                  ),
                                  hintText: 'select_bus_number'.tr(),
                                  fillColor: Colors.grey[100],
                                  filled: true,
                                  alignLabelWithHint: true,
                                  floatingLabelAlignment:
                                      FloatingLabelAlignment.center,
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                      width: 1.0.w,
                                    ),
                                    borderRadius: BorderRadius.circular(10.0.r),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 5.0.w,
                                    horizontal: 20.h,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blue,
                                      width: 2.5.w,
                                    ),
                                    borderRadius: BorderRadius.circular(10.0.r),
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
                                  width: 250.w,
                                  child: ElevatedButton(
                                    onPressed: _addDriver,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color.fromARGB(255, 0, 14, 67),
                                    ),
                                    child: Text(
                                      'add_driver'.tr(),
                                      style: TextStyle(
                                        color: Colors.white,
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
                  ],
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
