import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:university_bus/screens/addbus.dart';
import 'package:university_bus/screens/splash_wait.dart';
import 'package:university_bus/screens/viewbus.dart';
import 'package:university_bus/widget/app_bar.dart';
import 'package:university_bus/widget/error_operation.dart';
import 'package:university_bus/widget/float_button.dart';
import 'package:university_bus/widget/gradient.dart';

class TrackingBus extends StatefulWidget {
  const TrackingBus({super.key});

  @override
  State<TrackingBus> createState() => _TrackingBusState();
}

class _TrackingBusState extends State<TrackingBus> {
  late Stream<List<DocumentSnapshot>> bussStream;
  late Future<DocumentSnapshot<Map<String, dynamic>>> usernameFuture;
  var _isUploading = false;

  @override
  void initState() {
    super.initState();
    _uploadData();
    usernameFuture = getUsers();
  }

  _uploadData() {
    setState(
      () {
        _isUploading = true;
      },
    );
    bussStream = FirebaseFirestore.instance
        .collection('buses')
        .snapshots()
        .map((snapshot) => snapshot.docs);

    setState(
      () {
        _isUploading = false;
      },
    );
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: usernameFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreenWait();
        } else if (snapshot.hasError) {
          return ErrorOperator(errorMessage: '${'error'}: ${snapshot.error}');
        } else if (snapshot.data == null) {
          return ErrorOperator(errorMessage: 'no_loading_data'.tr());
        } else {
          return Scaffold(
            appBar: StyleAppBar(
              title: 'bus_routes_title'.tr(),
              actionBar: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddBus(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.add,
                ),
              ),
            ),
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: StyleGradient(),
              ),
              child: StreamBuilder<List<DocumentSnapshot>>(
                stream: bussStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SplashScreenWait();
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else if (_isUploading) {
                    return const CircularProgressIndicator(
                      color: Colors.blue,
                    );
                  } else if (snapshot.hasData || !_isUploading) {
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
                                String busId = bus['busId'];
                                String busType = bus['busType'];
                                int busNumber = bus['busNumber'].toInt();
                                int numberstudents =
                                    bus['numberstudents'].toInt();
                                int numberchairs = bus['numberchairs'].toInt();
                                String busModel = bus['busModel'];
                                double latitude = bus['latitude'];
                                double longitude = bus['longitude'];
                                int coding = bus['coding'].toInt();
                                int registrationNumber =
                                    bus['registrationNumber'].toInt();
                                String licenseStartDate =
                                    bus['licenseStartDate'];
                                String licenseEndDate = bus['licenseEndDate'];
                                String speed = bus['speed'];
                                return Expanded(
                                  child: Column(
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ViewBus(
                                                busType: busType,
                                                busNumber: busNumber,
                                                numberstudents: numberstudents,
                                                numberchairs: numberchairs,
                                                busModel: busModel,
                                                latitude: latitude,
                                                longitude: longitude,
                                                coding: coding,
                                                registrationNumber:
                                                    registrationNumber,
                                                licenseStartDate:
                                                    licenseStartDate,
                                                licenseEndDate: licenseEndDate,
                                                busId: busId,
                                                speed: speed,
                                              ),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: const Color.fromARGB(
                                              255, 255, 255, 255),
                                          backgroundColor: const Color.fromARGB(
                                              255, 0, 14, 67),
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
                    return ErrorOperator(
                        errorMessage: 'no_data_available'.tr());
                  }
                },
              ),
            ),
            floatingActionButton: const MyFloatingActionButton(),
          );
        }
      },
    );
  }
}
