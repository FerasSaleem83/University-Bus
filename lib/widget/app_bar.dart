// ignore_for_file: non_constant_identifier_names, must_be_immutable

import 'package:flutter/material.dart';

class StyleAppBar extends StatelessWidget implements PreferredSizeWidget {
  String title;
  final Widget? actionBar;
  StyleAppBar({
    Key? key,
    required this.title,
    this.actionBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(title),
      backgroundColor: const Color.fromARGB(255, 0, 14, 67),
      foregroundColor: const Color.fromARGB(255, 255, 255, 255),
      actions: actionBar != null ? [actionBar!] : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
