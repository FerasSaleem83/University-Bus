import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:university_bus/screens/detailsadmin.dart';
import 'package:university_bus/screens/report.dart';
import 'package:university_bus/screens/splash_wait.dart';
import 'package:university_bus/screens/trackingbus.dart';
import 'package:university_bus/screens/trackingdriver.dart';
import 'package:university_bus/widget/app_bar.dart';
import 'package:university_bus/widget/drawer.dart';
import 'package:university_bus/widget/error_operation.dart';
import 'package:university_bus/widget/float_button.dart';
import 'package:university_bus/widget/gradient.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> usernameFuture;

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
          String username = snapshot.data!['username'];
          String usertype = snapshot.data!['userType'];
          String imageuser = snapshot.data!['image'];
          String gender = snapshot.data!['gender'];
          String phone = snapshot.data!['phonenumber'];
          String living = snapshot.data!['living'];
          String age = snapshot.data!['age'];

          return Scaffold(
            drawer: MyDrawer(
              snapshot: snapshot,
              drawemail: '${FirebaseAuth.instance.currentUser?.email}',
              drawusername: username,
              imageusers: imageuser,
              detailsUser: () {
                Navigator.pop(context);
                Navigator.of(context).pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailsAdmin(
                      userName: username,
                      userEmail: '${FirebaseAuth.instance.currentUser?.email}',
                      imageUsers: imageuser,
                      userId: FirebaseAuth.instance.currentUser!.uid,
                      gender: gender,
                      phone: phone,
                      living: living,
                      age: age,
                    ),
                  ),
                );
              },
            ),
            appBar: StyleAppBar(title: ''),
            body: Container(
              decoration: BoxDecoration(
                gradient: StyleGradient(),
              ),
              child: Padding(
                padding: EdgeInsets.all(15.w.h),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/iu-logo-jordan.png',
                        width: 200.w,
                        height: 200.h,
                      ),
                      SizedBox(height: 75.h),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // SizedBox(
                          //   width: 450.w,
                          //   height: 65.h,
                          //   child: ElevatedButton.icon(
                          //     onPressed: () async {
                          //       await Navigator.push(
                          //         context,
                          //         MaterialPageRoute(
                          //           builder: (context) => const Journey(),
                          //         ),
                          //       );
                          //     },
                          //     label: Text('journey'.tr()),
                          //     style: ElevatedButton.styleFrom(
                          //       textStyle: TextStyle(
                          //         color: Colors.white,
                          //         fontSize: 30.sp,
                          //         fontWeight: FontWeight.w900,
                          //         fontFamily: 'DecoType_Thuluth',
                          //       ),
                          //       backgroundColor:
                          //           const Color.fromARGB(255, 0, 14, 67),
                          //       shape: const BeveledRectangleBorder(),
                          //       padding: EdgeInsets.all(15.w),
                          //       foregroundColor: Colors.white,
                          //     ),
                          //     icon: Icon(
                          //       Icons.bus_alert,
                          //       size: 30.sp,
                          //     ),
                          //   ),
                          // ),
                          SizedBox(height: 20.h),
                          SizedBox(
                            width: 450.w,
                            height: 65.h,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const TrackingBus(),
                                  ),
                                );
                              },
                              label: Text('bus'.tr()),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 0, 14, 67),
                                textStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30.sp,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'DecoType_Thuluth',
                                ),
                                padding: EdgeInsets.all(15.w.h),
                                foregroundColor: Colors.white,
                                shape: const BeveledRectangleBorder(),
                              ),
                              icon: Icon(
                                Icons.train_sharp,
                                size: 30.w,
                              ),
                            ),
                          ),
                          SizedBox(height: 20.h),
                          SizedBox(
                            width: 450.w,
                            height: 65.h,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const TarackingDriver(),
                                  ),
                                );
                              },
                              label: Text('driver'.tr()),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 0, 14, 67),
                                textStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30.sp,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'DecoType_Thuluth',
                                ),
                                padding: EdgeInsets.all(15.w.h),
                                foregroundColor: Colors.white,
                                shape: const BeveledRectangleBorder(),
                              ),
                              icon: Icon(
                                Icons.person,
                                size: 30.w,
                              ),
                            ),
                          ),
                          SizedBox(height: 20.h),
                          SizedBox(
                            width: 450.w,
                            height: 65.h,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Report(
                                        studentName: username,
                                        userType: usertype),
                                  ),
                                );
                              },
                              label: Text('reports'.tr()),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 0, 14, 67),
                                textStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30.sp,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'DecoType_Thuluth',
                                ),
                                padding: EdgeInsets.all(15.w.h),
                                foregroundColor: Colors.white,
                                shape: const BeveledRectangleBorder(),
                              ),
                              icon: Icon(
                                Icons.list_alt,
                                size: 30.w,
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
            floatingActionButton: const MyFloatingActionButton(),
          );
        }
      },
    );
  }
}
