import 'dart:async';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  LocationData? _currentLocation;
  StreamSubscription<LocationData>? _locationSubscription;
  void getCurrentLocation(){
    Location location = Location();
    location.getLocation().then((value) => setState(() {
      _currentLocation = value;
      print(_currentLocation!.latitude);
    }));
  }
  Future<void> _listenCurrentLocation() async {
    Location location = Location();
    _locationSubscription = location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        _currentLocation = currentLocation;
      });
    });
  }
  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    _listenCurrentLocation();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(widget.title),
      // ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _currentLocation == null
              ? CircularProgressIndicator()
              : Column(
                  children: [
                    Text('Latitude: ${_currentLocation!.latitude}'),
                    Text('Longitude: ${_currentLocation!.longitude}'),
                    Text('Accuracy: ${_currentLocation!.accuracy}'),
                    Text('Altitude: ${_currentLocation!.altitude}'),
                    Text('Speed: ${_currentLocation!.speed}'),
                    Text('Speed Accuracy: ${_currentLocation!.speedAccuracy}'),
                  ],
                ),
          ],
        ),
      ),
    );
  }
}
