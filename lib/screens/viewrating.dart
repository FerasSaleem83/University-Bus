// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:university_bus/screens/splash_wait.dart';
import 'package:university_bus/widget/app_bar.dart';
import 'package:university_bus/widget/float_button.dart';
import 'package:university_bus/widget/gradient.dart';

class ViewRating extends StatefulWidget {
  final String busNumber;
  const ViewRating({required this.busNumber, super.key});

  @override
  State<ViewRating> createState() => _ViewRatingState();
}

class _ViewRatingState extends State<ViewRating> {
  late Stream<List<DocumentSnapshot>> tripsStream;
  var _isUploading = false;
  double _averageRating = 0.0;

  @override
  void initState() {
    super.initState();
    _uploadData();
  }

  _uploadData() {
    setState(() {
      _isUploading = true;
    });
    tripsStream = FirebaseFirestore.instance
        .collection('ratings')
        .doc(widget.busNumber)
        .collection(widget.busNumber)
        .snapshots()
        .map((snapshot) {
      double totalRating = 0.0;
      snapshot.docs.forEach((doc) {
        totalRating += doc['rate'];
      });
      if (snapshot.docs.isNotEmpty) {
        _averageRating = totalRating / snapshot.docs.length;
      } else {
        _averageRating = 0.0;
      }
      return snapshot.docs;
    });

    setState(() {
      _isUploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StyleAppBar(
        title: '${'bus_number'.tr()} ${widget.busNumber}',
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: StyleGradient(),
        ),
        child: StreamBuilder<List<DocumentSnapshot>>(
          stream: tripsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreenWait();
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else if (_isUploading) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasData || !_isUploading) {
              List<DocumentSnapshot> ratings = snapshot.data!;
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(15.w),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'average_rating'.tr(),
                            style: TextStyle(
                              fontSize: 25.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 35.w),
                          SizedBox(
                            width: 200.w,
                            child: TextFormField(
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.black,
                              ),
                              cursorColor: Colors.black,
                              decoration: const InputDecoration(
                                fillColor: Color.fromARGB(255, 255, 255, 255),
                                filled: true,
                                alignLabelWithHint: true,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              initialValue: ' $_averageRating',
                              readOnly: true,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 40.h),
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1, // عدد الأعمدة
                            mainAxisSpacing: 2, // المسافة العمودية بين الصفوف
                            childAspectRatio: 3,
                          ),
                          itemCount: (ratings.length / 3).ceil(), // عدد الصفوف
                          itemBuilder: (context, index) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: ratings
                                  .sublist(
                                index * 3,
                                (index * 3) + 3 > ratings.length
                                    ? ratings.length
                                    : (index * 3) + 3,
                              )
                                  .map((rating) {
                                String studentName = rating['studentName'];
                                double rate = rating['rate'];

                                return Card(
                                  color:
                                      const Color.fromARGB(255, 160, 188, 197),
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0.w),
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          width: 175.w,
                                          child: Text(
                                            studentName,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 25.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '${'rate'.tr()}: $rate',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 20.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return const Center(
                child: Text('no_data_available'),
              );
            }
          },
        ),
      ),
      floatingActionButton: const MyFloatingActionButton(),
    );
  }
}
