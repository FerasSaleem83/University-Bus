import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:university_bus/screens/adddriver.dart';
import 'package:university_bus/screens/splash_wait.dart';
import 'package:university_bus/screens/viewdriver.dart';
import 'package:university_bus/widget/app_bar.dart';
import 'package:university_bus/widget/error_operation.dart';
import 'package:university_bus/widget/float_button.dart';
import 'package:university_bus/widget/gradient.dart';

class TarackingDriver extends StatefulWidget {
  const TarackingDriver({super.key});

  @override
  State<TarackingDriver> createState() => _TarackingDriverState();
}

class _TarackingDriverState extends State<TarackingDriver> {
  late Stream<List<DocumentSnapshot>> driversStream;
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
    driversStream = FirebaseFirestore.instance
        .collection('drivers')
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
          String adminPassword = snapshot.data!['password'];

          return Scaffold(
            appBar: StyleAppBar(
              title: 'drivers'.tr(),
              actionBar: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddDriver(
                        password: adminPassword,
                        userEmail:
                            '${FirebaseAuth.instance.currentUser?.email}',
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.person_add_alt_1,
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
                stream: driversStream,
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
                    List<DocumentSnapshot> drivers = snapshot.data!;
                    drivers.sort(
                      (a, b) => a['busNumber'].compareTo(
                        b['busNumber'],
                      ),
                    ); // ترتيب السائقين حسب رقم الباص
                    return Padding(
                      padding: EdgeInsets.all(15.w.h),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1, // عدد الأعمدة
                          mainAxisSpacing: 3, // المسافة العمودية بين الصفوف
                          childAspectRatio: 4,
                        ),
                        itemCount: (drivers.length / 3).ceil(), // عدد الصفوف
                        itemBuilder: (context, index) {
                          return Row(
                            children: drivers
                                .sublist(
                              index * 3,
                              (index * 3) + 3 > drivers.length
                                  ? drivers.length
                                  : (index * 3) + 3,
                            )
                                .map(
                              (driver) {
                                String driverId = driver['driverId'];
                                String driverName = driver['driverName'];
                                String driverJobNumber = driver['JobNumber'];
                                String driverEmail = driver['email'];
                                String driverImageusers = driver['image'];
                                String licenseStartDate =
                                    driver['licenseStartDate'];
                                String licenseEndDate =
                                    driver['licenseEndDate'];
                                int busNumber = driver['busNumber'];
                                return Expanded(
                                  child: Column(
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ViewDriver(
                                                driverName: driverName,
                                                driverJobNumber:
                                                    driverJobNumber,
                                                driverEmail: driverEmail,
                                                driverImageusers:
                                                    driverImageusers,
                                                driverId: driverId,
                                                licenseStartDate:
                                                    licenseStartDate,
                                                licenseEndDate: licenseEndDate,
                                                busNumber: busNumber,
                                              ),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: const Color.fromARGB(
                                              255, 255, 255, 255),
                                          backgroundColor: const Color.fromARGB(
                                              255, 0, 14, 67),
                                          padding: EdgeInsets.all(20.w.h),

                                          fixedSize: Size.fromHeight(
                                              150.h.w), // تحديد ارتفاع الزر
                                          shape: const CircleBorder(),
                                        ),
                                        child: Text(
                                          driverName,
                                          style: TextStyle(fontSize: 25.sp),
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
                      errorMessage: 'no_data_available'.tr(),
                    );
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
