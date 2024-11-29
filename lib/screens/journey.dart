import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:university_bus/widget/app_bar.dart';
import 'package:university_bus/widget/gradient.dart';

class Journey extends StatefulWidget {
  const Journey({super.key});

  @override
  State<Journey> createState() => _JourneyState();
}

class _JourneyState extends State<Journey> {
  List<int> _busNumbers = [];

  int? busNumber;
  bool isUploading = false;
  late Stream<List<DocumentSnapshot>> ratingsStream;
  late Future<DocumentSnapshot<Map<String, dynamic>>> usernameFuture;

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
        isUploading = true;
      },
    );
    ratingsStream = FirebaseFirestore.instance
        .collection('buses')
        .snapshots()
        .map((snapshot) => snapshot.docs);
    setState(
      () {
        isUploading = false;
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _uploadData();
    usernameFuture = getUsers();
    viewBusNumbers(); // استدعاء دالة لجلب أرقام الباصات عند بدء التطبيق
  }

  void viewBusNumbers() {
    FirebaseFirestore.instance
        .collection('buses')
        .get()
        .then((QuerySnapshot querySnapshot) {
      setState(() {
        _busNumbers = querySnapshot.docs
            .map((doc) => doc['busNumber'])
            .cast<int>()
            .toList();
        _busNumbers.sort();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StyleAppBar(title: 'set_journey'.tr()),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: StyleGradient(),
        ),
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(25.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 15.h),
                  Padding(
                    padding: EdgeInsets.all(25.w),
                    child: SizedBox(
                      width: 800.w,
                      height: 450.h,
                      child: Padding(
                        padding: EdgeInsets.all(25.w),
                        child: Form(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('bus_number'.tr()),
                              DropdownButtonFormField<int>(
                                value: busNumber,
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
                                  fontSize: 20.sp,
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
                                    borderRadius: BorderRadius.circular(10.0),
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
                              SizedBox(height: 35.h),
                              Text(
                                'itinerary'.tr(),
                                style: TextStyle(
                                  color: const Color.fromARGB(255, 0, 0, 0),
                                  fontSize: 25.sp,
                                ),
                              ),
                              TextFormField(
                                style: const TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  labelText: 'from'.tr(),
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
                                keyboardType: TextInputType.name,
                                //controller: _busNumberController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'enter_journey_start'.tr();
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10.h),
                              TextFormField(
                                style: const TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  labelText: 'to'.tr(),
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
                                keyboardType: TextInputType.name,
                                //controller: _busNumberController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'enter_journey_end'.tr();
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10.h),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30.h),
                  SizedBox(
                    width: 200.w,
                    height: 50.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 0, 14, 67),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(15.r),
                          ),
                        ),
                      ),
                      onPressed: () {},
                      child: Text(
                        'add'.tr(),
                        style: TextStyle(
                          fontSize: 20.sp,
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
    );
  }
}
