// ignore_for_file: avoid_print, use_build_context_synchronously,

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:university_bus/widget/app_bar.dart';
import 'package:university_bus/widget/float_button.dart';
import 'package:university_bus/widget/gradient.dart';

class AddBus extends StatefulWidget {
  const AddBus({super.key});

  @override
  State<AddBus> createState() => _AddBusState();
}

class _AddBusState extends State<AddBus> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> usernameFuture;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _busTypeController = TextEditingController();
  final TextEditingController _numberchairsController = TextEditingController();
  final TextEditingController _busNumberController = TextEditingController();
  final TextEditingController _busModelController = TextEditingController();
  final TextEditingController _codingController = TextEditingController();
  final TextEditingController _registrationNumberController =
      TextEditingController();
  final TextEditingController _licenseStartDateController =
      TextEditingController();
  final TextEditingController _licenseEndDateController =
      TextEditingController();

  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    usernameFuture = getUsers();
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

  void _addBus() async {
    final valid = _formKey.currentState!.validate();
    if (!valid) {
      return;
    }
    try {
      setState(() {
        _isUploading = true;
      });

      DocumentReference busReference = FirebaseFirestore.instance
          .collection('buses')
          .doc(_busNumberController.text);
      await busReference.set(
        {
          'busId': '',
          'speed': '0.00',
          'busType': _busTypeController.text.trim(),
          'numberstudents': 0,
          'numberchairsavailable':
              int.parse(_numberchairsController.text.trim()),
          'numberchairs': int.parse(_numberchairsController.text.trim()),
          'busNumber': int.parse(_busNumberController.text.trim()),
          'busModel': _busModelController.text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
          'latitude': 31.788938,
          'longitude': 35.928986,
          'coding': int.parse(_codingController.text.trim()),
          'registrationNumber':
              int.parse(_registrationNumberController.text.trim()),
          'licenseStartDate': _licenseStartDateController.text.trim(),
          'licenseEndDate': _licenseEndDateController.text.trim(),
        },
      );

      await FirebaseFirestore.instance
          .collection('buses')
          .doc(busReference.id)
          .set({
        'busId': busReference.id,
      }, SetOptions(merge: true));

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('sucessfully'.tr()),
            content: Text('message_add_bus'.tr()),
            actions: <Widget>[
              TextButton(
                onPressed: () {
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
          appBar: StyleAppBar(title: 'add_bus'.tr()),
          body: Container(
            decoration: BoxDecoration(
              gradient: StyleGradient(),
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/iu-logo-jordan.png',
                      width: 200.w,
                      height: 200.h,
                    ),
                    SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // bus number
                              TextFormField(
                                style: const TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  labelText: 'bus_number'.tr(),
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
                                keyboardType: TextInputType.number,
                                controller: _busNumberController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'bus_number_message'.tr();
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10.h),

                              Row(
                                children: [
                                  Expanded(
                                    flex: 13,
                                    child: TextFormField(
                                      style:
                                          const TextStyle(color: Colors.black),
                                      decoration: InputDecoration(
                                        labelText: 'registration_number'.tr(),
                                        labelStyle: TextStyle(
                                          fontSize: 25.sp,
                                          color: Colors.black,
                                        ),
                                        enabledBorder:
                                            const UnderlineInputBorder(
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
                                      keyboardType: TextInputType.number,
                                      controller: _registrationNumberController,
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'registration_number_message'
                                              .tr();
                                        }
                                        return null;
                                      },
                                      maxLength: 10,
                                    ),
                                  ),
                                  SizedBox(width: 16.w),
                                  Expanded(
                                    flex: 6,
                                    child: TextFormField(
                                      style:
                                          const TextStyle(color: Colors.black),
                                      decoration: InputDecoration(
                                        labelText: 'coding'.tr(),
                                        labelStyle: TextStyle(
                                          fontSize: 25.sp,
                                          color: Colors.black,
                                        ),
                                        enabledBorder:
                                            const UnderlineInputBorder(
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
                                      keyboardType: TextInputType.number,
                                      controller: _codingController,
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'coding_message'.tr();
                                        }
                                        return null;
                                      },
                                      maxLength: 2,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.h),
                              //Bus Type
                              TextFormField(
                                style: const TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  labelText: 'bus_type'.tr(),
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
                                controller: _busTypeController,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().length < 3) {
                                    return 'bus_type_message'.tr();
                                  }
                                  return null;
                                },
                              ),

                              SizedBox(height: 10.h),
                              //number chairs
                              TextFormField(
                                style: const TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  labelText: 'number_chairs'.tr(),
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
                                keyboardType: TextInputType.number,
                                controller: _numberchairsController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'number_chairs_message'.tr();
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10.h),
                              //Bus Model
                              TextFormField(
                                style: const TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  labelText: 'bus_model'.tr(),
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
                                controller: _busModelController,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().length < 4) {
                                    return 'error_bus_model'.tr();
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.number,
                              ),
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
                              if (_isUploading)
                                const CircularProgressIndicator(
                                  color: Colors.blue,
                                ),
                              if (!_isUploading)
                                SizedBox(
                                  width: 200.w,
                                  child: ElevatedButton(
                                    onPressed: _addBus,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color.fromARGB(255, 0, 14, 67),
                                    ),
                                    child: Text(
                                      'add_bus'.tr(),
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
