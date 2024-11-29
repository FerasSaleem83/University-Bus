// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, avoid_print, prefer_collection_literals, unnecessary_null_comparison, avoid_function_literals_in_foreach_calls

import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:university_bus/screens/detailsdriver.dart';
import 'package:university_bus/screens/splash_wait.dart';
import 'package:university_bus/widget/app_bar.dart';
import 'package:university_bus/widget/drawer.dart';
import 'package:university_bus/widget/error_operation.dart';
import 'package:university_bus/widget/float_button.dart';
import 'package:university_bus/widget/gradient.dart';

User users = FirebaseAuth.instance.currentUser!;

String userId = users.uid;

final usersRef = FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .collection('information');

class DriverScreen extends StatefulWidget {
  const DriverScreen({
    Key? key,
  }) : super(key: key);

  @override
  _DriverScreenState createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen> {
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late BitmapDescriptor customIcon;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  Position? _position;
  int nearbyPeopleCount = 0;
  late Future<DocumentSnapshot<Map<String, dynamic>>> usernameFuture;
  late Future<QuerySnapshot<Map<String, dynamic>>> usernameFuture2;
  bool notificationSent = false;
  late Timer _timer;
  late Timer timer;
  String currentLocation = '';
  var _isUploading = false;
  late int busNumberNew;
  double _currentSpeed = 0.0;
  Position? _previousPosition;
  DateTime? _previousTimestamp;
  Map<String, Timer?> studentTimers = {};
  bool _isAvailable = false;
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(seconds: 10),
      (timer) {
        setState(
          () {
            notificationSent = false;
          },
        );
      },
    );

    _loadCustomIcon();
    _getCurrentLocation();
    //_getUpdateCurrentLocation();
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        _getUpdateCurrentLocation();
      },
    );
    usernameFuture = getUsers();
    usernameFuture2 = getUsers2();

    _initMessaging();

    // استدعاء الدالة للتحقق وحذف المستخدمين القريبين كل دقيقة
    Timer.periodic(
      const Duration(seconds: 30),
      (Timer timer) {
        _checkAndDeleteNearbyUsers();
      },
    );
    usernameFuture.then((snapshot) {
      setState(() {
        busNumberNew = snapshot.data()?['busNumber'] ?? 0;
      });
    });
    Timer.periodic(
      const Duration(minutes: 1),
      (Timer timer) {
        _checkSpeedAndSendComplaint();
      },
    );
  }

  void _checkSpeedAndSendComplaint() {
    if (_currentSpeed > 90) {
      sendCompliants();
    }
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

  Future<QuerySnapshot<Map<String, dynamic>>> getUsers2() async {
    User user = FirebaseAuth.instance.currentUser!;
    userId = user.uid;
    return await usersRef.where('email', isEqualTo: '${users.email}').get();
  }

  void _updateUserLocationdirect(double latitude, double longitude) async {
    User user = FirebaseAuth.instance.currentUser!;
    if (user != null) {
      String userId = user.uid;

      await FirebaseFirestore.instance
          .collection('drivers')
          .doc(userId)
          .update({
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': FieldValue.serverTimestamp(),
        'speed': _currentSpeed.toStringAsFixed(2)
      });
      await FirebaseFirestore.instance
          .collection('buses')
          .doc('$busNumberNew')
          .update({
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': FieldValue.serverTimestamp(),
        'speed': _currentSpeed.toStringAsFixed(2)
      });
    }
  }

  sendCompliants() async {
    Map<String, dynamic> data = {
      'studentName': 'Automatice',
      'busNumber': busNumberNew,
      'selectedComplaints': [('${'excessive_speed'.tr()}$_currentSpeed')],
      'timeComplaints': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance
        .collection('complaints')
        .doc('$busNumberNew')
        .collection('$busNumberNew')
        .doc()
        .set(data, SetOptions(merge: true));
  }

  void _getUpdateCurrentLocation() async {
    _position = await Geolocator.getCurrentPosition();
    DateTime currentTimestamp = DateTime.now();

    if (_previousPosition != null && _previousTimestamp != null) {
      double distanceInMeters = distanceBetweenPoints(
        _previousPosition!.latitude,
        _previousPosition!.longitude,
        _position!.latitude,
        _position!.longitude,
      );

      double timeInSeconds =
          currentTimestamp.difference(_previousTimestamp!).inSeconds.toDouble();

      if (timeInSeconds > 0) {
        double speedInMetersPerSecond = distanceInMeters / timeInSeconds;
        double speedInKilometersPerHour = speedInMetersPerSecond * 3.6;

        setState(() {
          _currentSpeed = speedInKilometersPerHour;
        });

        print('Current speed: $speedInKilometersPerHour km/h');
      }
    }

    _previousPosition = _position;
    _previousTimestamp = currentTimestamp;

    _updateUserLocationdirect(_position!.latitude, _position!.longitude);
  }

  void _getCurrentLocation() {
    try {
      setState(
        () {
          _isUploading = true;
        },
      );
      Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        forceAndroidLocationManager: true,
        timeLimit: const Duration(seconds: 10),
      ).then(
        (Position position) {
          setState(
            () {
              _position = position;
              _isUploading = false;
            },
          );
          mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(
                  position.latitude,
                  position.longitude,
                ),
                zoom: 19,
              ),
            ),
          );
        },
      ).catchError(
        (error) {
          ErrorOperator(
            errorMessage: '$error',
          );
        },
      );
    } catch (e) {
      ErrorOperator(
        errorMessage: '$e',
      );
      setState(
        () {
          _isUploading = false;
        },
      );
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _initMessaging() async {
    await Firebase.initializeApp();
    _firebaseMessaging.requestPermission();
    _firebaseMessaging.getToken().then(
      (token) {
        ErrorOperator(errorMessage: '${'firebase_token'.tr()}: $token');
      },
    );
    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        ErrorOperator(errorMessage: '${'error'.tr()}: $message');
      },
    );
    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) {
        ErrorOperator(errorMessage: '${'error'.tr()}: $message');
      },
    );
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
    _geolocatorPlatform.getPositionStream().listen(
      (position) {
        _checkNearbyPeople(position);
      },
    );
  }

  Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    ErrorOperator(errorMessage: '${'error'.tr()}: $message');
  }

  void _checkNearbyPeople(Position position) {
    const double proximityThreshold = 40; // المسافة بالأمتار

    nearbyPeopleCount = 0; // إعادة تهيئة العداد

    for (var marker in markers) {
      var personLat = marker.position.latitude;
      var personLon = marker.position.longitude;
      var distance = distanceBetweenPoints(
        position.latitude,
        position.longitude,
        personLat,
        personLon,
      );
      if (distance <= proximityThreshold) {
        if (notificationSent == false) {
          notificationSent = true;

          _sendNotification();
        }
        nearbyPeopleCount++; // زيادة العداد لكل شخص قريب
      }
    }
    // حدث واجهة المستخدم لعرض عدد الأشخاص القريبين
    setState(
      () {},
    );
  }

  void _sendNotification() async {
    var androidDetails = const AndroidNotificationDetails(
      'channelId',
      'channelName',
      priority: Priority.high,
      importance: Importance.max,
    );
    var platformChannelSpecifics = NotificationDetails(
      android: androidDetails,
    );
    await FlutterLocalNotificationsPlugin().show(
      0,
      'worng'.tr(),
      'In_front_of_you_is_a_student_on_the_road'.tr(),
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  Future<void> _loadCustomIcon() async {
    customIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), 'assets/images/Icon.png');
  }

  void _checkAndDeleteNearbyUsers() async {
    var busDocSnapshot = await FirebaseFirestore.instance
        .collection('buses')
        .doc('$busNumberNew')
        .get();
    if (busDocSnapshot.exists) {
      var busDoc = busDocSnapshot.data();
      if (busDoc != null) {
        // يمكنك الآن الوصول إلى بيانات وثيقة الحافلة باستخدام busDoc
        int numberChairsAvailable = busDoc['numberchairsavailable'];
        setState(() {
          _isAvailable = numberChairsAvailable > 0;
        });
      } else {
        print('Document data is null');
      }
    } else {
      print('Document does not exist');
    }
    if (_isAvailable == true) {
      const double proximityThreshold = 5; // المسافة بالأمتار

      for (var marker in markers) {
        var personLat = marker.position.latitude;
        var personLon = marker.position.longitude;
        var distance = distanceBetweenPoints(
          _position!.latitude,
          _position!.longitude,
          personLat,
          personLon,
        );

        if (distance <= proximityThreshold) {
          // تحقق من بقاء الطالب في نفس الموقع لمدة 30 ثانية
          Timer(const Duration(seconds: 30), () async {
            Position newPosition = await Geolocator.getCurrentPosition();
            double newDistance = distanceBetweenPoints(
              newPosition.latitude,
              newPosition.longitude,
              personLat,
              personLon,
            );

            if (newDistance <= proximityThreshold) {
              // اجلب الوثيقة من جدول الطلاب
              var querySnapshot = await FirebaseFirestore.instance
                  .collection('students') // افترض هنا اسم الكولكشن للطلاب
                  .where('latitude', isEqualTo: personLat)
                  .where('longitude', isEqualTo: personLon)
                  .get();

              // تحقق إذا كانت الوثيقة موجودة
              if (querySnapshot.docs.isNotEmpty) {
                var studentDoc = querySnapshot.docs.first;

                // احفظ اسم الطالب والبريد الإلكتروني
                String studentName = studentDoc.get('username');
                String studentEmail = studentDoc.get('email');

                // إضافة الطالب إلى جدول الركاب
                await FirebaseFirestore.instance
                    .collection('passengers')
                    .doc('$busNumberNew')
                    .collection('student')
                    .add({
                  'email': studentEmail,
                  'studentName': studentName,
                  'busNumber': busNumberNew,
                  'latitude': personLat,
                  'longitude': personLon,
                  'timestamp': FieldValue.serverTimestamp(),
                });
                // تحديث عدد الطلاب والكراسي المتاحة في وثيقة الباص
                await FirebaseFirestore.instance
                    .collection('buses')
                    .doc('$busNumberNew')
                    .update({
                  'numberstudents': FieldValue.increment(1),
                  'numberchairsavailable': FieldValue.increment(-1),
                });

                // حذف الطالب من جدول الطلاب
                //studentDoc.reference.delete();
                await studentDoc.reference.update({
                  'latitude': 0,
                  'longitude': 0,
                });
              }
            }
          });
        }
      }
    }
  }

  Future<void> deleteCollection(String busNumbers) async {
    // Reference to the 'students' collection
    var collectionRef = FirebaseFirestore.instance
        .collection('passengers')
        .doc(busNumbers)
        .collection('student');

    // Get all documents in the collection
    var snapshots = await collectionRef.get();

    // Delete each document
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }

    print('Collection deleted successfully');
  }

  void _updateChairsAvailable(int newChairsAvailable) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await deleteCollection('$busNumberNew');
      await FirebaseFirestore.instance
          .collection('buses')
          .doc('$busNumberNew')
          .update({'numberchairsavailable': newChairsAvailable});
      await FirebaseFirestore.instance
          .collection('buses')
          .doc('$busNumberNew')
          .update({'numberstudents': 0});
      await FirebaseFirestore.instance
          .collection('passengers')
          .doc('$busNumberNew')
          .delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          return StreamBuilder<QuerySnapshot>(
            stream: _firestore.collectionGroup('students').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                markers.clear();
                for (var doc in snapshot.data!.docs) {
                  final long = doc.get('longitude');
                  final lat = doc.get('latitude');
                  final username = doc.get('username');
                  markers.add(
                    Marker(
                      markerId: MarkerId(doc.id),
                      position: LatLng(lat, long),
                      infoWindow: InfoWindow(title: username ?? 'User Name'),
                      icon: customIcon,
                    ),
                  );
                }

                return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  future: usernameFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SplashScreenWait();
                    } else if (snapshot.hasError) {
                      return ErrorOperator(
                          errorMessage: '${'error'}: ${snapshot.error}');
                    } else if (snapshot.hasData) {
                      String username = snapshot.data!['driverName'];
                      String imageuser = snapshot.data!['image'];
                      String gender = snapshot.data!['gender'];
                      String phone = snapshot.data!['phonenumber'];
                      String living = snapshot.data!['living'];
                      String age = snapshot.data!['age'];
                      int busNumber = snapshot.data!['busNumber'];

                      String licenseStartDate =
                          snapshot.data!['licenseStartDate'];
                      String licenseEndDate = snapshot.data!['licenseEndDate'];

                      return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        future: usernameFuture2,
                        builder: (context, snapshot) {
                          return Scaffold(
                            drawer: MyDrawer(
                              snapshot: snapshot,
                              drawemail:
                                  '${FirebaseAuth.instance.currentUser?.email}',
                              drawusername: username,
                              imageusers: imageuser,
                              detailsUser: () {
                                Navigator.pop(context);
                                Navigator.of(context).pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailsDriver(
                                      userName: username,
                                      userEmail:
                                          '${FirebaseAuth.instance.currentUser?.email}',
                                      imageUsers: imageuser,
                                      userId: userId,
                                      gender: gender,
                                      phone: phone,
                                      living: living,
                                      age: age,
                                      licenseStartDate: licenseStartDate,
                                      licenseEndDate: licenseEndDate,
                                    ),
                                  ),
                                );
                              },
                            ),
                            appBar: StyleAppBar(title: username),
                            body: Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              decoration: BoxDecoration(
                                gradient: StyleGradient(),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(15.w),
                                child: Column(
                                  children: [
                                    Image.asset(
                                      'assets/images/iu-logo-jordan.png',
                                      width: 125.w,
                                      height: 125.h,
                                    ),
                                    SizedBox(height: 15.h),
                                    SizedBox(
                                      child: Text(
                                        '${'number_of_students_near_you'.tr()} : $nearbyPeopleCount',
                                        style: TextStyle(
                                          fontSize: 30.sp,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10.h),
                                    if (_isUploading)
                                      const CircularProgressIndicator(
                                        color: Colors.blue,
                                      ),
                                    if (!_isUploading)
                                      SizedBox(
                                        height: 390.h,
                                        child: GoogleMap(
                                          onMapCreated: (controller) {
                                            setState(() {
                                              mapController = controller;
                                            });
                                          },
                                          myLocationEnabled: true,
                                          initialCameraPosition: CameraPosition(
                                            target: LatLng(
                                              _position!.latitude,
                                              _position!.longitude,
                                            ),
                                            zoom: 17,
                                          ),
                                          markers: markers,
                                        ),
                                      ),
                                    SizedBox(height: 15.h),
                                    StreamBuilder<DocumentSnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection('buses')
                                          .doc('$busNumber')
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasError) {
                                          return ErrorOperator(
                                              errorMessage:
                                                  '${'error'}: ${snapshot.error}');
                                        } else if (snapshot.hasData) {
                                          int numberChairs = snapshot.data![
                                                  'numberchairsavailable'] ??
                                              0;
                                          int numberStudents = snapshot
                                                  .data!['numberstudents'] ??
                                              0;
                                          if (numberChairs <= 0) {
                                            return AlertDialog(
                                              backgroundColor:
                                                  const Color.fromARGB(
                                                      255, 251, 143, 143),
                                              title: Text(
                                                'warning'.tr(),
                                                style: TextStyle(
                                                  fontSize: 20.sp,
                                                  color: const Color.fromARGB(
                                                      255, 136, 22, 22),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              content: Text(
                                                'number_chairs_run_out'.tr(),
                                                style: TextStyle(
                                                  fontSize: 17.sp,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    _updateChairsAvailable(
                                                        snapshot.data![
                                                                'numberchairs'] ??
                                                            0);
                                                  },
                                                  child: Text(
                                                    'evacuation'.tr(),
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          } else {
                                            return Column(
                                              children: [
                                                SizedBox(height: 10.h),
                                                Padding(
                                                  padding: EdgeInsets.all(15.w),
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        '${'number_chairs'.tr()} : $numberChairs',
                                                        style: TextStyle(
                                                          fontSize: 30.sp,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      SizedBox(height: 10.h),
                                                      Text(
                                                        '${'number_students'.tr()} : $numberStudents',
                                                        style: TextStyle(
                                                          fontSize: 30.sp,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      Text(
                                                        'Current Speed: ${_currentSpeed.toStringAsFixed(2)} km/h',
                                                        style: TextStyle(
                                                          fontSize: 30.sp,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            );
                                          }
                                        } else {
                                          return Center(
                                            child:
                                                Text('no_data_available'.tr()),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            floatingActionButton:
                                const MyFloatingActionButton(),
                          );
                        },
                      );
                    } else {
                      return const Center(
                        child: SplashScreenWait(),
                      );
                    }
                  },
                );
              } else {
                return const Center(
                  child: SplashScreenWait(),
                );
              }
            },
          );
        },
      );
    });
  }

  double distanceBetweenPoints(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0; // نصف قطر الأرض بالكيلومترات
    var dLat = _toRadians(lat2 - lat1);
    var dLon = _toRadians(lon2 - lon1);
    var a = pow(sin(dLat / 2), 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * pow(sin(dLon / 2), 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c * 100;
  }

  double _toRadians(double degree) {
    return degree * (pi / 180);
  }
}
