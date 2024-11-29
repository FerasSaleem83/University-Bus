// ignore_for_file: use_build_context_synchronously, prefer_typing_uninitialized_variables

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:university_bus/screens/settingspage.dart';

class MyDrawer extends StatefulWidget {
  final AsyncSnapshot<dynamic> snapshot;
  final String drawemail;
  final String drawusername;
  final String? imageusers;
  final Function() detailsUser;

  const MyDrawer({
    Key? key,
    required this.snapshot,
    required this.drawemail,
    required this.drawusername,
    required this.imageusers,
    required this.detailsUser,
  }) : super(key: key);

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  String imagepersonal =
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcShB7IwN9gr4q2Tn-1CRfbgANRN-8SWlYMMy9iq467T1A&s';

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color.fromARGB(255, 193, 202, 203),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 0, 14, 67),
              ),
              accountName: widget.snapshot.hasData
                  ? Text(
                      widget.drawusername,
                    )
                  : Text('username_label'.tr()),
              accountEmail: widget.snapshot.hasData
                  ? Text(widget.drawemail)
                  : Text('email_label'.tr()),
              currentAccountPicture: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullScreenImage(
                        imageUrl: widget.imageusers ?? imagepersonal,
                      ),
                    ),
                  );
                },
                child: CircleAvatar(
                  backgroundImage: NetworkImage(
                    widget.imageusers ?? imagepersonal,
                  ),
                  radius: 100.r,
                  backgroundColor:
                      Theme.of(context).colorScheme.primary.withAlpha(180),
                ),
              ),
            ),
            ListTile(
              title: TextButton.icon(
                onPressed: widget.detailsUser,
                icon: const Icon(
                  Icons.person,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
                label: Text(
                  'my_profile'.tr(),
                  style: const TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              title: TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingPage(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.settings,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
                label: Text(
                  'setting'.tr(),
                  style: const TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 25.h),
            ListTile(
              title: widget.snapshot.hasData
                  ? TextButton.icon(
                      onPressed: () async {
                        // تسجيل الخروج من Firebase Auth
                        await FirebaseAuth.instance.signOut();
                      },
                      icon: const Icon(
                        Icons.logout,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                      label: Text(
                        'sign_out'.tr(),
                        style: const TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.login,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                      label: Text(
                        'login_button'.tr(),
                        style: const TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Image.network(
          imageUrl,
          width: 500.w,
          height: 500.h,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
