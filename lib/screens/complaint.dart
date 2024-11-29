// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:university_bus/screens/splash_wait.dart';
import 'package:university_bus/screens/viewcomplaint.dart';
import 'package:university_bus/widget/app_bar.dart';
import 'package:university_bus/widget/error_operation.dart';
import 'package:university_bus/widget/float_button.dart';
import 'package:university_bus/widget/gradient.dart';

class Complaint extends StatefulWidget {
  final String studentName;
  final String userType;

  const Complaint(
      {super.key, required this.studentName, required this.userType});

  @override
  State<Complaint> createState() => _ComplaintState();
}

class _ComplaintState extends State<Complaint> {
  int? busNumber;
  int? busnewNumber;
  bool isUploading = false;
  late Stream<List<DocumentSnapshot>> complaintsStream;
  late Future<DocumentSnapshot<Map<String, dynamic>>> usernameFuture;
  late Future<void> busNumberFuture;

  final StreamController<QuerySnapshot<Map<String, dynamic>>>
      _streamController =
      StreamController<QuerySnapshot<Map<String, dynamic>>>();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<String> complaints = [
    'excessive_speed'.tr(),
    'inappropriate_treatment'.tr(),
    'not_stopping'.tr(),
    'delay_in_arriving'.tr(),
    'delay_in_arriving_at_university'.tr(),
    'other'.tr(),
  ];

  List<bool> checked = [];

  Future<void> fetchComplaints() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('complaints').get();
      _streamController.add(snapshot);
    } catch (error) {
      _streamController.addError(error);
    }
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  Future<void> getBusNumber(String passengerName) async {
    setState(() {
      isUploading = true;
    });

    try {
      // استعراض جميع الأرقام من 1 إلى 100 كمستندات
      for (int i = 1; i <= 100; i++) {
        QuerySnapshot studentsSnapshot = await FirebaseFirestore.instance
            .collection('passengers')
            .doc(i.toString())
            .collection('student')
            .where('studentName', isEqualTo: passengerName)
            .get();

        if (studentsSnapshot.docs.isNotEmpty) {
          DocumentSnapshot studentDoc = studentsSnapshot.docs.first;
          setState(() {
            busnewNumber = studentDoc['busNumber'];
          });
          break; // الخروج من الحلقة إذا وجدنا الطالب
        }
      }
    } catch (e) {
      print(e);
    }

    setState(() {
      isUploading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _uploadData();
    fetchComplaints();
    usernameFuture = getUsers();
    busNumberFuture = getBusNumber(widget.studentName);
    checked = List<bool>.filled(complaints.length, false);
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
    setState(() {
      isUploading = true;
    });
    complaintsStream = FirebaseFirestore.instance
        .collection('buses')
        .snapshots()
        .map((snapshot) => snapshot.docs);

    setState(() {
      isUploading = false;
    });
  }

  sendCompliants() async {
    if (busnewNumber == null) {
      // عرض رسالة خطأ إذا كانت قيمة busnewNumber غير موجودة
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('error'.tr()),
            content: const Text('Bus number not found.'),
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
        isUploading = true;
      });
      Map<String, dynamic> data = {
        'studentName': widget.studentName,
        'busNumber': busnewNumber,
        'selectedComplaints': [],
        'timeComplaints': FieldValue.serverTimestamp(),
      };
      for (int i = 0; i < checked.length; i++) {
        if (checked[i]) {
          data['selectedComplaints'].add(complaints[i]);
        }
      }
      await FirebaseFirestore.instance
          .collection('complaints')
          .doc('$busnewNumber')
          .collection('$busnewNumber')
          .doc()
          .set(data, SetOptions(merge: true));

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('sucessfully'.tr()),
            content: Text('message_add_complaint'.tr()),
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
        isUploading = false;
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
                    isUploading = false;
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
    if (widget.userType == 'student') {
      return Scaffold(
        appBar: StyleAppBar(title: 'make_complaint'.tr()),
        body: FutureBuilder<void>(
          future: busNumberFuture,
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: SplashScreenWait(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else {
              return Container(
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: StyleGradient(),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20.0.w),
                  child: SingleChildScrollView(
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/iu-logo-jordan.png',
                            width: 200.w,
                            height: 200.h,
                          ),
                          SizedBox(height: 30.h),
                          Text(
                            '${'bus_number'.tr()}:   $busnewNumber',
                            style: TextStyle(
                              fontSize: 30.sp,
                            ),
                          ),
                          SizedBox(height: 25.h),
                          // إضافة قائمة المربعات للاختيارات
                          Column(
                            children: List.generate(
                              complaints.length,
                              (index) => CheckboxListTile(
                                title: Text(complaints[index]),
                                value: checked[index],
                                onChanged: (bool? value) {
                                  setState(() {
                                    checked[index] = value!;
                                  });
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 25.h),
                          if (isUploading)
                            const CircularProgressIndicator(
                              color: Colors.black,
                            ),
                          if (!isUploading)
                            SizedBox(
                              width: 300.w,
                              child: ElevatedButton(
                                onPressed: sendCompliants,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 0, 14, 67),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(15.r),
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'send_complaints'.tr(),
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 25.sp),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
          },
        ),
        floatingActionButton: const MyFloatingActionButton(),
      );
    } else {
      return Scaffold(
        appBar: StyleAppBar(
          title: 'complaints'.tr(),
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: StyleGradient(),
          ),
          child: StreamBuilder<List<DocumentSnapshot>>(
            stream: complaintsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SplashScreenWait();
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else if (isUploading) {
                return const SplashScreenWait();
              } else if (snapshot.hasData || !isUploading) {
                List<DocumentSnapshot> buss = snapshot.data!;
                buss.sort(
                  (a, b) => a['busNumber'].compareTo(
                    b['busNumber'],
                  ),
                ); // ترتيب السائقين حسب رقم الباص
                return Padding(
                  padding: EdgeInsets.all(15.w),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1, // عدد الأعمدة
                      mainAxisSpacing: 5, // المسافة العمودية بين الصفوف
                      childAspectRatio: 5,
                    ),
                    itemCount: (buss.length / 5).ceil(), // عدد الصفوف
                    itemBuilder: (context, index) {
                      return Row(
                        children: buss
                            .sublist(
                          index * 5,
                          (index * 5) + 5 > buss.length
                              ? buss.length
                              : (index * 5) + 5,
                        )
                            .map(
                          (bus) {
                            int busNumber = bus['busNumber'].toInt();
                            return Expanded(
                              child: Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ViewComplaint(
                                                busNumber: '$busNumber')),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: const Color.fromARGB(
                                          255, 255, 255, 255),
                                      backgroundColor:
                                          const Color.fromARGB(255, 0, 14, 67),
                                      padding: EdgeInsets.all(8.w),
                                      fixedSize: Size.fromHeight(
                                          75.h), // تحديد ارتفاع الزر
                                      shape: const CircleBorder(),
                                    ),
                                    child: Text(
                                      '$busNumber',
                                      style: TextStyle(
                                        fontSize: 25.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ).toList(),
                      );
                    },
                  ),
                );
              } else {
                return ErrorOperator(errorMessage: 'no_data_available'.tr());
              }
            },
          ),
        ),
        floatingActionButton: const MyFloatingActionButton(),
      );
    }
  }
}
