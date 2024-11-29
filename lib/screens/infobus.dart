// ignore_for_file: avoid_print, unused_field, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:university_bus/widget/app_bar.dart';
import 'package:university_bus/widget/float_button.dart';
import 'package:university_bus/widget/gradient.dart';

class BusInfo extends StatefulWidget {
  final String busType;
  final int busNumber;
  final int numberchairs;
  final String busModel;
  final int coding;
  final int registrationNumber;
  final String licenseStartDate;
  final String licenseEndDate;
  final String busId;

  const BusInfo({
    required this.busType,
    required this.busNumber,
    required this.numberchairs,
    required this.busModel,
    required this.coding,
    required this.registrationNumber,
    required this.licenseStartDate,
    required this.licenseEndDate,
    required this.busId,
    Key? key,
  }) : super(key: key);

  @override
  State<BusInfo> createState() => _BusInfoState();
}

class _BusInfoState extends State<BusInfo> {
  final TextEditingController _busTypeController = TextEditingController();
  final TextEditingController _busNumberController = TextEditingController();
  final TextEditingController _numberstudentsController =
      TextEditingController();
  final TextEditingController _numberchairsController = TextEditingController();
  final TextEditingController _busModelController = TextEditingController();
  final TextEditingController _codingController = TextEditingController();
  final TextEditingController _registrationNumberController =
      TextEditingController();
  final TextEditingController _licenseStartDateController =
      TextEditingController();
  final TextEditingController _licenseEndDateController =
      TextEditingController();

  late DateTime _licenseStartDate;
  late DateTime _licenseEndDate;

  GoogleMapController? mapController;
  Set<Marker> markers = {};
  late BitmapDescriptor carIcon;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _busTypeController.text = widget.busType;
    _busNumberController.text = widget.busNumber.toString();
    _numberchairsController.text = widget.numberchairs.toString();
    _busModelController.text = widget.busModel;
    _codingController.text = widget.coding.toString();
    _registrationNumberController.text = widget.registrationNumber.toString();

    DateTime startDate =
        DateTime.parse(widget.licenseStartDate.split('/').reversed.join('-'));
    DateTime endDate =
        DateTime.parse(widget.licenseEndDate.split('/').reversed.join('-'));

    _licenseStartDate = startDate;
    _licenseEndDate = endDate;
  }

  void _updatBus() async {
    try {
      setState(() {
        _isUploading = true;
      });

      DocumentReference driverReference =
          FirebaseFirestore.instance.collection('buses').doc(widget.busId);

      await driverReference.set({
        'timestamp': FieldValue.serverTimestamp(),
        'busType': _busTypeController.text.trim(),
        'numberchairs': int.parse(_numberchairsController.text.trim()),
        'busModel': _busModelController.text.trim(),
        'coding': int.parse(_codingController.text.trim()),
        'registrationNumber':
            int.parse(_registrationNumberController.text.trim()),
        'licenseStartDate': _licenseStartDateController.text.trim(),
        'licenseEndDate': _licenseEndDateController.text.trim(),
      }, SetOptions(merge: true));

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('sucessfully'.tr()),
            content: Text('update_data'.tr()),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  setState(() {
                    _isUploading = false;
                  });
                  Navigator.pop(context);
                  Navigator.of(context).pop(context);
                },
                child: Text('done_button'.tr()),
              ),
            ],
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isUploading = false;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('error'.tr()),
            content: Text(e.message ?? 'Authentication failed'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  setState(() {
                    _isUploading = false;
                  });
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

  _deleteBus(String busId) async {
    try {
      await FirebaseFirestore.instance.collection('buses').doc(busId).delete();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('sucessfully'.tr()),
            content: Text('delete_bus_sucessfully'.tr()),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).pop(context);
                },
                child: Text('done_button'.tr()),
              ),
            ],
          );
        },
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('error'.tr()),
            content: const Text('Authentication failed'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  setState(() {
                    _isUploading = false;
                  });
                  Navigator.of(context).pop();
                },
                child: Text('done_button'.tr()),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StyleAppBar(
        title: '${'bus_number'.tr()}: ${widget.busNumber}',
        actionBar: IconButton(
          onPressed: () async {
            await _deleteBus(widget.busId);
          },
          icon: const Icon(Icons.delete),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: StyleGradient(),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(25.w),
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
                  SizedBox(height: 70.h),
                  TextFormField(
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      fillColor: const Color.fromARGB(255, 255, 255, 255),
                      filled: true,
                      alignLabelWithHint: true,
                      labelText: 'bus_type'.tr(),
                      labelStyle: const TextStyle(
                        color: Colors.black,
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black,
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 9, 41, 248),
                        ),
                      ),
                    ),
                    controller: _busTypeController,
                  ),
                  SizedBox(height: 15.h),
                  TextFormField(
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      fillColor: const Color.fromARGB(255, 255, 255, 255),
                      filled: true,
                      alignLabelWithHint: true,
                      labelText: 'bus_model'.tr(),
                      labelStyle: const TextStyle(
                        color: Colors.black,
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black,
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 9, 41, 248),
                        ),
                      ),
                    ),
                    controller: _busModelController,
                    keyboardType: TextInputType.datetime,
                  ),
                  SizedBox(height: 15.h),
                  TextFormField(
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      fillColor: const Color.fromARGB(255, 255, 255, 255),
                      filled: true,
                      alignLabelWithHint: true,
                      labelText: 'number_chairs'.tr(),
                      labelStyle: const TextStyle(
                        color: Colors.black,
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black,
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 9, 41, 248),
                        ),
                      ),
                    ),
                    controller: _numberchairsController,
                    keyboardType: TextInputType.datetime,
                  ),
                  SizedBox(height: 15.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 200.w,
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            fillColor: const Color.fromARGB(255, 255, 255, 255),
                            filled: true,
                            alignLabelWithHint: true,
                            labelText: 'coding'.tr(),
                            labelStyle: const TextStyle(
                              color: Colors.black,
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black,
                              ),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 9, 41, 248),
                              ),
                            ),
                          ),
                          controller: _codingController,
                          keyboardType: TextInputType.datetime,
                        ),
                      ),
                      SizedBox(
                        width: 30.w,
                        child: Text(
                          '.',
                          style: TextStyle(
                            fontSize: 50.sp,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        width: 370.w,
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            fillColor: const Color.fromARGB(255, 255, 255, 255),
                            filled: true,
                            alignLabelWithHint: true,
                            labelText: 'registration_number'.tr(),
                            labelStyle: const TextStyle(
                              color: Colors.black,
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black,
                              ),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 9, 41, 248),
                              ),
                            ),
                          ),
                          controller: _registrationNumberController,
                          keyboardType: TextInputType.datetime,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 275.w,
                        child: Expanded(
                          flex: 6,
                          child: FormBuilderDateTimePicker(
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                            controller: _licenseStartDateController,
                            name: 'license_start_date'.tr(),
                            inputType: InputType.date,
                            initialValue: _licenseStartDate,
                            locale: const Locale('en', 'US'),
                            format: DateFormat('dd/MM/yyyy', 'en'),
                            decoration: InputDecoration(
                              fillColor:
                                  const Color.fromARGB(255, 255, 255, 255),
                              filled: true,
                              labelStyle: const TextStyle(
                                color: Colors.black,
                              ),
                              labelText: 'license_start_date'.tr(),
                              hintText: _licenseStartDateController.text,
                              hintStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.sp,
                                  color: Colors.black),
                              alignLabelWithHint: true,
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 9, 41, 248),
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 5.0.w,
                                horizontal: 20.h,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 50.w),
                      SizedBox(
                        width: 275.w,
                        child: Expanded(
                          flex: 6,
                          child: FormBuilderDateTimePicker(
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                            controller: _licenseEndDateController,
                            name: 'license_end_date'.tr(),
                            inputType: InputType.date,
                            initialValue: _licenseEndDate,
                            locale: const Locale('en', 'US'),
                            format: DateFormat('dd/MM/yyyy', 'en'),
                            decoration: InputDecoration(
                              fillColor:
                                  const Color.fromARGB(255, 255, 255, 255),
                              filled: true,
                              labelStyle: const TextStyle(
                                color: Colors.black,
                              ),
                              labelText: 'license_end_date'.tr(),
                              hintText: _licenseEndDateController.text,
                              hintStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20.sp,
                                color: Colors.black,
                              ),
                              alignLabelWithHint: true,
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 9, 41, 248),
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 5.0.w,
                                horizontal: 20.h,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30.h),
                  if (_isUploading)
                    const CircularProgressIndicator(
                      color: Colors.blue,
                    ),
                  if (!_isUploading)
                    SizedBox(
                      width: 330.w,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: _updatBus,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 0, 14, 67),
                        ),
                        child: Text(
                          'update'.tr(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: const MyFloatingActionButton(),
    );
  }
}
