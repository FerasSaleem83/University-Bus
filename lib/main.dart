// ignore_for_file: unused_element, avoid_print

import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:university_bus/firebase_options.dart';
import 'package:university_bus/screens/splash.dart';
import 'package:university_bus/screens/splash_wait.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _requestLocationPermission();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await initNotifications();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await EasyLocalization.ensureInitialized();
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('ar', 'SA'),
      ],
      path: 'assets/translation',
      child: const MyApp(),
    ),
  );
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  _showNotification(message);
}

Future<void> _showNotification(RemoteMessage message) async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'your_channel_id',
    'your_channel_name',
    channelDescription: 'your_channel_description',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
  );

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  final notification = message.notification;
  if (notification != null) {
    await flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title ??
          'No Title', // توفير قيمة افتراضية إذا كان العنوان null
      notification.body ?? 'No Body', // توفير قيمة افتراضية إذا كان الجسم null
      platformChannelSpecifics,
      payload: 'item x',
    );
  }
}

//طلب الاذن بالسماح الوصول للموقع
Future<void> _requestLocationPermission() async {
  final PermissionStatus status = await Permission.location.request();
  if (status != PermissionStatus.granted) {
    Permission.location.request();
  }
}

// السماح للتطبيق بارسال اشعارات
Future<void> initNotifications() async {
  var initializationSettingsAndroid =
      const AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await FlutterLocalNotificationsPlugin().initialize(
    initializationSettings,
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    // بنية التطبيق الاساسية
    return ScreenUtilInit(
        designSize: const Size(660, 990),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            // عنوان التطبيق
            title: 'app_title'.tr(),
            // لتغيير لغة التطبيق
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            //اللون الاساسي للتطبيق
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple,
              ),
              useMaterial3: true,
            ),
            // لازالة علامة البناء عن التطبيق
            debugShowCheckedModeBanner: false,

            home: Scaffold(
              body: StreamBuilder(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SplashScreenWait();
                  } else {
                    return const Scaffold(
                      body: SplashScreen(),
                    );
                  }
                },
              ),
            ),
          );
        });
  }
}
