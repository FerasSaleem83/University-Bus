// ignore_for_file: library_private_types_in_public_api, avoid_print, use_build_context_synchronously, unused_element, deprecated_member_use

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
import 'package:permission_handler/permission_handler.dart';

import 'package:university_bus/screens/detailsuser.dart';
import 'package:university_bus/screens/report.dart';
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

class StudentScreen extends StatefulWidget {
  const StudentScreen({Key? key}) : super(key: key);

  @override
  _StudentScreenState createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> usernameFuture;
  late Future<QuerySnapshot<Map<String, dynamic>>> usernameFuture2;

  GoogleMapController? mapController;
  String currentLocation = '';
  Set<Marker> markers = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late BitmapDescriptor carIcon;
  late BitmapDescriptor boyIcon;
  int nearbyPeopleCount = 0;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  String? selectedRegistrationPlace;
  late Timer _timer; // إنشاء متغير لتخزين العداد
  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;
  Position? _position;
  var _isUploading = false;
  bool notificationSent = false;
  bool isPassenger = false;
  bool _isSharingLocation = false;

  Future<void> _loadCarIcon() async {
    carIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(
        size: Size(40.w, 40.h),
      ),
      'assets/images/bus_icon.png',
    );
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

  void _checkNearbyPeople(Position position) async {
    const double proximityThreshold = 25;

    nearbyPeopleCount = 0;
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
        bool isPassenger = await checkIfUserIsPassenger();
        if (notificationSent == false && !isPassenger) {
          notificationSent = true;

          _sendNotification();
        }
        nearbyPeopleCount++;
      }
    }

    setState(
      () {},
    );
  }

  Future<bool> checkIfUserIsPassenger() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String email = user.email!;
      for (int i = 1; i <= 100; i++) {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('passengers')
            .doc(i.toString())
            .collection('student')
            .where('email', isEqualTo: email)
            .get();
        if (snapshot.docs.isNotEmpty) {
          setState(() {
            isPassenger = true;
          });
          return true;
        }
      }
    }
    setState(() {
      isPassenger = false;
    });
    return false;
  }

  double distanceBetweenPoints(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0;
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
      'bus_approaching_you'.tr(),
      platformChannelSpecifics,
      payload: 'item x',
    );
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

  void _subscribeToLocationUpdates() {
    _subscription = _firestore.collectionGroup('buses').snapshots().listen(
      (QuerySnapshot<Map<String, dynamic>> snapshot) {
        setState(
          () {
            markers.clear();
            for (final doc in snapshot.docs) {
              final lat = doc['latitude'] as double;
              final long = doc['longitude'] as double;
              final busNumber = doc['busNumber'] as String;
              final numberChairs = doc['numberchairsavailable'] as double;
              markers.add(
                Marker(
                  markerId: MarkerId(doc.id),
                  position: LatLng(lat, long),
                  infoWindow: InfoWindow(
                    title: busNumber,
                    snippet: numberChairs == 0 ? 'Full' : '$numberChairs',
                  ),
                  icon: carIcon,
                ),
              );
            }
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _timer.cancel(); // إلغاء تنفيذ العملية عندما يتم تجديد الشاشة أو إغلاقها
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadCarIcon();
    _getCurrentLocation();
    _getUpdateCurrentLocation();
    Timer.periodic(
      const Duration(seconds: 10),
      (Timer timer) {
        _getUpdateCurrentLocation();
      },
    );

    _timer = Timer.periodic(
      const Duration(seconds: 10),
      (Timer timer) {
        _subscribeToLocationUpdates();
      },
    );
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
    _initMessaging();
    Timer.periodic(
      const Duration(seconds: 10),
      (timer) {
        checkIfUserIsPassenger();
      },
    );
    usernameFuture = getUsers();
    usernameFuture2 = getUsers2();
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
    return await usersRef
        .where(
          'email',
          isEqualTo: '${users.email}',
        )
        .get();
  }

  @override
  Widget build(BuildContext context) {
    User user = FirebaseAuth.instance.currentUser!;
    String userId = user.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collectionGroup('buses').snapshots(),
      builder: (context, snapshot) {
        markers.clear();
        if (snapshot.hasData && snapshot.data != null) {
          for (var doc in snapshot.data!.docs) {
            final long = doc.get('longitude');
            final lat = doc.get('latitude');
            final busNumber = doc.get('busNumber');
            markers.add(
              Marker(
                markerId: MarkerId(doc.id),
                position: LatLng(lat, long),
                infoWindow: InfoWindow(title: '$busNumber'),
                icon: carIcon,
              ),
            );
          }
        }

        return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: usernameFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreenWait();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              String username = snapshot.data!['username'];
              String usertype = snapshot.data!['userType'];
              String imageuser = snapshot.data!['image'];
              String gender = snapshot.data!['gender'];
              String phone = snapshot.data!['phonenumber'];
              String living = snapshot.data!['living'];
              String age = snapshot.data!['age'];
              String college = snapshot.data!['college'];
              String specialization = snapshot.data!['specialization'];
              String academicYear = snapshot.data!['academic_year'];

              return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                future: usernameFuture2,
                builder: (context, snapshot) {
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
                            builder: (context) => DetailsUser(
                              userName: username,
                              userEmail:
                                  '${FirebaseAuth.instance.currentUser?.email}',
                              imageUsers: imageuser,
                              userId: FirebaseAuth.instance.currentUser!.uid,
                              gender: gender,
                              phone: phone,
                              living: living,
                              age: age,
                              college: college,
                              specialization: specialization,
                              academicYear: academicYear,
                            ),
                          ),
                        );
                      },
                    ),
                    appBar: StyleAppBar(title: username),
                    body: Container(
                      decoration: BoxDecoration(
                        gradient: StyleGradient(),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(15.w),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/iu-logo-jordan.png',
                                width: 200.w,
                                height: 200.h,
                              ),
                              SizedBox(height: 20.h),
                              if (_isUploading)
                                const CircularProgressIndicator(
                                  color: Colors.blue,
                                ),
                              if (!_isUploading)
                                SizedBox(
                                  height: 450.h,
                                  child: GoogleMap(
                                    onMapCreated: (controller) {
                                      setState(
                                        () {
                                          mapController = controller;
                                        },
                                      );
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
                              SizedBox(height: 20.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  if (!isPassenger)
                                    SizedBox(
                                      width: 250.w,
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                                          setState(() {
                                            _isSharingLocation = true;
                                          });
                                          if (mapController != null) {
                                            mapController!.dispose();
                                          }

                                          var status = await Permission.location
                                              .request();

                                          if (status ==
                                              PermissionStatus.granted) {
                                            Position position = await Geolocator
                                                .getCurrentPosition();
                                            setState(
                                              () {
                                                _updateUserLocation(
                                                  position.latitude,
                                                  position.longitude,
                                                  username,
                                                );

                                                mapController!.animateCamera(
                                                  CameraUpdate.newLatLngZoom(
                                                    LatLng(
                                                      position.latitude,
                                                      position.longitude,
                                                    ),
                                                    17.0,
                                                  ),
                                                );
                                              },
                                            );
                                          } else {
                                            ErrorOperator(
                                              errorMessage:
                                                  'location_permission_denied'
                                                      .tr(),
                                            );
                                          }
                                        },
                                        label: Text('share_location'.tr()),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                              255, 0, 14, 67),
                                          textStyle: const TextStyle(
                                            color: Colors.white,
                                          ),
                                          padding: EdgeInsets.all(15.w),
                                          foregroundColor: Colors.white,
                                        ),
                                        icon: const Icon(Icons.share),
                                      ),
                                    ),
                                  SizedBox(width: 7.w),
                                  if (!isPassenger)
                                    SizedBox(
                                      width: 250.w,
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                                          setState(() {
                                            _isSharingLocation = false;
                                          });
                                          markers.clear();
                                          await FirebaseFirestore.instance
                                              .collection('students')
                                              .doc(userId)
                                              .update({
                                            'latitude': 0,
                                            'longitude': 0,
                                          });
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text('sucessfully'.tr()),
                                                content: Text(
                                                    'delete_location_sucessfully'
                                                        .tr()),
                                                actions: <Widget>[
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text(
                                                        'done_button'.tr()),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        label: Text('delete_location'.tr()),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                              255, 134, 2, 2),
                                          textStyle: const TextStyle(
                                            color: Colors.white,
                                          ),
                                          padding: EdgeInsets.all(15.w),
                                          foregroundColor: Colors.white,
                                        ),
                                        icon: const Icon(Icons.delete),
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 20.h),
                              if (isPassenger)
                                SizedBox(
                                  width: 250.w,
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Report(
                                            studentName: username,
                                            userType: usertype,
                                          ),
                                        ),
                                      );
                                    },
                                    label: Text('report'.tr()),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color.fromARGB(255, 67, 0, 0),
                                      textStyle: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      padding: EdgeInsets.all(15.w),
                                      foregroundColor: Colors.white,
                                    ),
                                    icon: const Icon(Icons.list_alt),
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
            } else {
              return const Center(
                child: SplashScreenWait(),
              );
            }
          },
        );
      },
    );
  }

  void _updateUserLocation(
      double latitude, double longitude, String username) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;
      // إضافة الموقع لقاعدة البيانات
      await _addUserLocationToFirestore(
        userId,
        latitude,
        longitude,
        username,
      );
      // تحديث الموقع للمستخدم في قاعدة البيانات
      await _updateUserLocationInDatabase(
        userId,
        latitude,
        longitude,
        username,
      );
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('sucessfully'.tr()),
            content: Text('share_location_sucessfully'.tr()),
            actions: <Widget>[
              TextButton(
                onPressed: () {
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

  void _updateUserLocationdirect(double latitude, double longitude) async {
    if (_isSharingLocation == true || isPassenger == false) {
      DocumentReference locationReference =
          _firestore.collection('students').doc(userId);

      await locationReference.set({
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } else {
      _subscription?.cancel();
    }
  }

  Future<void> _addUserLocationToFirestore(
      String userId, double latitude, double longitude, String username) async {
    DocumentReference locationReference = _firestore
        .collection('users')
        .doc(userId)
        .collection('location')
        .doc(userId);

    await locationReference.set({
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': FieldValue.serverTimestamp(),
      'username': username,
      'email': FirebaseAuth.instance.currentUser!.email
    }, SetOptions(merge: true));
  }

  Future<void> _updateUserLocationInDatabase(
      String userId, double latitude, double longitude, String username) async {
    DocumentReference locationReference2 =
        _firestore.collection('students').doc(userId);

    await locationReference2.set({
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': FieldValue.serverTimestamp(),
      'username': username,
      'email': FirebaseAuth.instance.currentUser!.email
    }, SetOptions(merge: true));
  }

  Future<void> _getUpdateCurrentLocation() async {
    if (_isSharingLocation == true || isPassenger == false) {
      try {
        User user = FirebaseAuth.instance.currentUser!;
        String userId = user.uid;
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        // Check if the user is present in the locationStudent collection
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('students')
            .doc(userId)
            .get();

        if (snapshot.exists) {
          // If user exists in locationStudent, update the location
          await FirebaseFirestore.instance
              .collection('students')
              .doc(userId)
              .set({
            'latitude': position.latitude,
            'longitude': position.longitude,
            'timestamp': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      } catch (e) {
        ErrorOperator(errorMessage: '$e');
      }
    } else {
      _subscription?.cancel();
    }
  }
}
