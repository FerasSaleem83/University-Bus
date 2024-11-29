// ignore_for_file: public_member_api_docs, sort_constructors_first, must_be_immutable
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ErrorOperator extends StatelessWidget {
  String errorMessage;
  ErrorOperator({
    Key? key,
    required this.errorMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('error'.tr()),
      content: Text('${'error_is'.tr()}: $errorMessage'),
    );
  }
}
