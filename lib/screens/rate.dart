// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:university_bus/screens/splash_wait.dart';
import 'package:university_bus/screens/viewrating.dart';
import 'package:university_bus/widget/app_bar.dart';
import 'package:university_bus/widget/error_operation.dart';
import 'package:university_bus/widget/float_button.dart';
import 'package:university_bus/widget/gradient.dart';

class Evaluation extends StatefulWidget {
  final String studentName;
  final String userType;

  const Evaluation(
      {super.key, required this.studentName, required this.userType});

  @override
  State<Evaluation> createState() => _EvaluationState();
}

class _EvaluationState extends State<Evaluation> {
  double _rating = 0;
  List<int> _busNumbers = []; // تعريف القائمة لحفظ أرقام الباصات
  int? busNumber;
  int? busnewNumber;
  late Future<void> busNumberFuture;
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
    usernameFuture = getUsers();
    viewBusNumbers(); // استدعاء دالة لجلب أرقام الباصات عند بدء التطبيق
    busNumberFuture = getBusNumber(widget.studentName);
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

  sendRating() async {
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
        'rate': _rating,
        'timeComplaints': FieldValue.serverTimestamp(),
      };
      await FirebaseFirestore.instance
          .collection('ratings')
          .doc('$busnewNumber')
          .collection('$busnewNumber')
          .doc()
          .set(data, SetOptions(merge: true));

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('sucessfully'.tr()),
            content: Text('message_add_rating'.tr()),
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
        appBar: StyleAppBar(title: 'bus_evaluation'.tr()),
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
                          SizedBox(height: 60.h),
                          // إضافة قائمة المربعات للاختيارات
                          Text(
                            '${'bus_number'.tr()}:   $busnewNumber',
                            style: TextStyle(
                              fontSize: 30.sp,
                            ),
                          ),
                          SizedBox(height: 25.h),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RatingBar.builder(
                                initialRating: _rating,
                                minRating: 1,
                                direction: Axis.horizontal,
                                allowHalfRating: false,
                                itemCount: 5,
                                itemSize: 70.w,
                                unratedColor: Colors.amber.withAlpha(50),
                                itemBuilder: (context, _) => Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 45.w,
                                ),
                                onRatingUpdate: (rating) {
                                  setState(() {
                                    _rating = rating;
                                  });
                                },
                              ),
                              SizedBox(height: 20.h),
                              Text(
                                '${'evaluation'.tr()} $_rating',
                                style: TextStyle(
                                  fontSize: 30.sp,
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
                                  height: 50.h,
                                  child: ElevatedButton(
                                    onPressed: sendRating,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color.fromARGB(255, 0, 14, 67),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(15.w),
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'submit_evaluation'.tr(),
                                      style: TextStyle(
                                        fontSize: 25.sp,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
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
          title: 'ratings'.tr(),
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: StyleGradient(),
          ),
          child: StreamBuilder<List<DocumentSnapshot>>(
            stream: ratingsStream,
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
                                            builder: (context) => ViewRating(
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
