import 'package:easy_localization/easy_localization.dart';
import 'package:easy_url_launcher/easy_url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class MyFloatingActionButton extends StatelessWidget {
  const MyFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      backgroundColor: const Color.fromARGB(255, 0, 14, 67),
      //animatedIcon: AnimatedIcons.list_view,
      icon: Icons.message,
      iconTheme: const IconThemeData(color: Colors.white),
      overlayColor: Colors.black,
      overlayOpacity: 0.5,
      curve: Curves.easeInOut,
      children: [
        SpeedDialChild(
          child: SizedBox(
            width: 90.w,
            child: MaterialButton(
              onPressed: () async {
                await EasyLauncher.url(
                  url: "https://iu.edu.jo",
                  mode: Mode.platformDefault,
                );
              },
              child: Image.asset(
                'assets/images/linkIu.png',
                width: 150.w,
                height: 150.h,
              ),
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 4, 25, 101),
        ),
        SpeedDialChild(
          child: SizedBox(
            width: 90.w,
            child: MaterialButton(
              onPressed: () async {
                await EasyLauncher.url(
                  url: "https://web.facebook.com/alisrauni",
                  mode: Mode.platformDefault,
                );
              },
              child: Image.asset(
                'assets/images/facebook.png',
                width: 150.w,
                height: 150.h,
              ),
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 4, 25, 101),
        ),
        SpeedDialChild(
          child: SizedBox(
            width: 90.w,
            child: MaterialButton(
              onPressed: () async {
                await EasyLauncher.url(
                  url: "https://www.instagram.com/alisrauni",
                  mode: Mode.platformDefault,
                );
              },
              child: Image.asset(
                'assets/images/instagram.png',
                width: 150.w,
                height: 150.h,
              ),
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 4, 25, 101),
        ),
        SpeedDialChild(
          child: SizedBox(
            width: 90.w,
            child: MaterialButton(
              onPressed: () async {
                await EasyLauncher.sendToWhatsApp(
                    phone: "+962779488888", message: "hello".tr());
              },
              child: Image.asset(
                'assets/images/whatsapp.png',
                width: 150.w,
                height: 150.h,
              ),
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 4, 25, 101),
        ),
      ],
    );
  }
}
