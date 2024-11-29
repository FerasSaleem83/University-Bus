import 'package:flutter/material.dart';
import 'package:location/location.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SpeedScreen(),
    );
  }
}

class SpeedScreen extends StatefulWidget {
  @override
  _SpeedScreenState createState() => _SpeedScreenState();
}

class _SpeedScreenState extends State<SpeedScreen> {
  Location location = Location();
  bool _serviceEnabled = false;
  PermissionStatus _permissionGranted = PermissionStatus.denied;
  LocationData? _locationData;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        _locationData = currentLocation;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('سرعة السيارة'),
      ),
      body: Center(
        child: _locationData != null
            ? Text(
                'السرعة الحالية: ${(_locationData!.speed ?? 0 * 3.6).toStringAsFixed(2)} كم/س',
                style: TextStyle(fontSize: 24),
              )
            : CircularProgressIndicator(),
      ),
    );
  }
}
