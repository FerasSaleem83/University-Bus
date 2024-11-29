// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:university_bus/widget/app_bar.dart';
import 'package:university_bus/widget/float_button.dart';
import 'package:university_bus/widget/gradient.dart';
import 'package:university_bus/widget/user_image.dart';

class ViewDriver extends StatefulWidget {
  final String driverName;
  final String driverJobNumber;
  final String driverEmail;
  final String driverImageusers;
  final String licenseStartDate;
  final String licenseEndDate;
  final String driverId;
  final int busNumber;

  const ViewDriver({
    required this.driverName,
    required this.driverJobNumber,
    required this.driverEmail,
    required this.licenseStartDate,
    required this.licenseEndDate,
    required this.driverImageusers,
    required this.driverId,
    required this.busNumber,
    Key? key,
  }) : super(key: key);

  @override
  State<ViewDriver> createState() => _ViewDriverState();
}

class _ViewDriverState extends State<ViewDriver> {
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  late BitmapDescriptor carIcon;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _jobNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _licenseStartDateController =
      TextEditingController();
  final TextEditingController _licenseEndDateController =
      TextEditingController();
  final TextEditingController _busNumberController = TextEditingController();

  File? _selectImage;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late DateTime _licenseStartDate;
  late DateTime _licenseEndDate;

  bool _isUploading = false;
  @override
  void initState() {
    super.initState();
    _usernameController.text = widget.driverName;
    _jobNumberController.text = widget.driverJobNumber;
    _emailController.text = widget.driverEmail;
    _licenseStartDateController.text = widget.licenseStartDate;
    _licenseEndDateController.text = widget.licenseEndDate;
    _busNumberController.text = '${widget.busNumber}';

    DateTime startDate =
        DateTime.parse(widget.licenseStartDate.split('/').reversed.join('-'));
    DateTime endDate =
        DateTime.parse(widget.licenseEndDate.split('/').reversed.join('-'));

    _licenseStartDate = startDate;
    _licenseEndDate = endDate;
  }

  void _updateDriver() async {
    final valid = _formKey.currentState!.validate();
    if (!valid) {
      return;
    }

    try {
      setState(() {
        _isUploading = true;
      });

      if (_selectImage != null) {
        // إذا كانت الصورة مختارة، قم بتحديث الصورة
        final Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('user_image')
            .child('${widget.driverId}.jpg');
        await storageRef.putFile(_selectImage!);
        final imageUrl = await storageRef.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.driverId)
            .collection('information')
            .doc(widget.driverId)
            .set({
          'username': _usernameController.text.trim(),
          'userType': 'driver',
          'image': imageUrl,
          'JobNumber': _jobNumberController.text.trim(),
          'licenseStartDate': _licenseStartDateController.text.trim(),
          'licenseEndDate': _licenseEndDateController.text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        DocumentReference driverReference = FirebaseFirestore.instance
            .collection('drivers')
            .doc(widget.driverId);

        await driverReference.set({
          'username': _usernameController.text.trim(),
          'userType': 'driver',
          'image': imageUrl,
          'JobNumber': _jobNumberController.text.trim(),
          'licenseStartDate': _licenseStartDateController.text.trim(),
          'licenseEndDate': _licenseEndDateController.text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        setState(() {
          _isUploading = false;
        });
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.driverId)
            .collection('information')
            .doc(widget.driverId)
            .set({
          'username': _usernameController.text.trim(),
          'userType': 'driver',
          'JobNumber': _jobNumberController.text.trim(),
          'licenseStartDate': _licenseStartDateController.text.trim(),
          'licenseEndDate': _licenseEndDateController.text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        DocumentReference driverReference = FirebaseFirestore.instance
            .collection('drivers')
            .doc(widget.driverId);

        await driverReference.set({
          'username': _usernameController.text.trim(),
          'userType': 'driver',
          'JobNumber': _jobNumberController.text.trim(),
          'licenseStartDate': _licenseStartDateController.text.trim(),
          'licenseEndDate': _licenseEndDateController.text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        setState(() {
          _isUploading = false;
        });
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
                  Navigator.of(context).pop();
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
                  Navigator.of(context).pop();
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

  _deleteDriver(String driverId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(driverId)
          .delete();
      await FirebaseFirestore.instance
          .collection('drivers')
          .doc(driverId)
          .delete();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('sucessfully'.tr()),
            content: Text('delete_driver_sucessfully'.tr()),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).pop(context);
                },
                child: Text('done_button'.tr()),
              ),
            ],
          );
        },
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('error'.tr()),
            content: const Text('Authentication failed'),
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
    return Scaffold(
      appBar: StyleAppBar(
        title: 'driver_page'.tr(),
        actionBar: IconButton(
          onPressed: () async {
            // استدعاء دالة حذف السائق من Authentication و Firestore
            await _deleteDriver(widget.driverId);
            // عرض رسالة تأكيد الحذف
          },
          icon: const Icon(Icons.delete),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: StyleGradient(),
        ),
        child: Padding(
          padding: EdgeInsets.all(15.w),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    UserImagePicker(
                      onPickImage: (File? pickedImage) {
                        setState(() {
                          _selectImage = pickedImage;
                        });
                      },
                      imageCase: widget.driverImageusers,
                    ),
                    SizedBox(height: 25.h),
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
                            color: Colors.black,
                          ),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 9, 41, 248),
                          ),
                        ),
                      ),
                      controller: _usernameController,
                    ),
                    SizedBox(height: 15.h),
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
                        labelText: 'job_number'.tr(),
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
                      controller: _jobNumberController,
                    ),
                    SizedBox(height: 15.h),
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
                            color: Colors.black,
                          ),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 9, 41, 248),
                          ),
                        ),
                      ),
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 15.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 285.w,
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
                              format: DateFormat('dd/MM/yyyy', 'en'),
                              decoration: InputDecoration(
                                fillColor:
                                    const Color.fromARGB(255, 255, 255, 255),
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
                        SizedBox(width: 60.w),
                        SizedBox(
                          width: 285.w,
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
                              format: DateFormat('dd/MM/yyyy', 'en'),
                              decoration: InputDecoration(
                                fillColor:
                                    const Color.fromARGB(255, 255, 255, 255),
                                filled: true,
                                labelStyle: const TextStyle(
                                  color: Colors.black,
                                ),
                                labelText: 'license_end_date'.tr(),
                                hintText: _licenseEndDateController.text,
                                hintStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.sp,
                                  color: Colors.black,
                                ),
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
                      ],
                    ),
                    SizedBox(height: 15.h),
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
                        labelText: 'bus_number'.tr(),
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
                      controller: _busNumberController,
                      readOnly: true,
                    ),
                    SizedBox(height: 30.h),
                    if (_isUploading)
                      const CircularProgressIndicator(
                        color: Colors.blue,
                      ),
                    if (!_isUploading)
                      SizedBox(
                        width: 325.w,
                        height: 50.h,
                        child: ElevatedButton(
                          onPressed: _updateDriver,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 0, 14, 67),
                          ),
                          child: Text(
                            'update'.tr(),
                            style:
                                TextStyle(color: Colors.white, fontSize: 25.sp),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: const MyFloatingActionButton(),
    );
  }
}
