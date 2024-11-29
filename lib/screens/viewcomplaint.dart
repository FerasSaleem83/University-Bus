import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:university_bus/screens/splash_wait.dart';
import 'package:university_bus/widget/app_bar.dart';
import 'package:university_bus/widget/float_button.dart';
import 'package:university_bus/widget/gradient.dart';

class ViewComplaint extends StatefulWidget {
  final String busNumber;
  const ViewComplaint({required this.busNumber, super.key});

  @override
  State<ViewComplaint> createState() => _ViewComplaintState();
}

class _ViewComplaintState extends State<ViewComplaint> {
  late Stream<List<DocumentSnapshot>> tripsStream;
  var _isUploading = false;

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
        .collection('complaints')
        .doc(widget.busNumber)
        .collection(widget.busNumber)
        .snapshots()
        .map((snapshot) => snapshot.docs);

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
              List<DocumentSnapshot> complaints = snapshot.data!;
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(15.w),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1, // عدد الأعمدة
                      mainAxisSpacing: 2, // المسافة العمودية بين الصفوف
                      childAspectRatio: 2,
                      mainAxisExtent: 275,
                    ),
                    itemCount: (complaints.length / 2).ceil(), // عدد الصفوف
                    itemBuilder: (context, index) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: complaints
                            .sublist(
                          index * 2,
                          (index * 2) + 2 > complaints.length
                              ? complaints.length
                              : (index * 2) + 2,
                        )
                            .map((complaint) {
                          String studentName = complaint['studentName'];
                          List selectedComplaints =
                              complaint['selectedComplaints'];

                          return Card(
                            color: const Color.fromARGB(255, 69, 69, 69),
                            child: Padding(
                              padding: EdgeInsets.all(8.0.w),
                              child: Column(
                                children: [
                                  Text(
                                    '${'complainer'.tr()} $studentName',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 25.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 275.w,
                                    child: Column(
                                      children:
                                          selectedComplaints.map((complaint) {
                                        return ListTile(
                                          title: Text(
                                            complaint,
                                            style: TextStyle(
                                              fontSize: 20.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        );
                                      }).toList(),
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
