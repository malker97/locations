import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

void main(){
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
  LocationData? _currentLocation;
  StreamSubscription<LocationData>? _locationSubscription;
  double lat = 0.0;
  double long = 0.0;
  String _speedLimit = "";
  void getCurrentLocation(){
    Location location = Location();
    location.getLocation().then((value) => setState(() {
      _currentLocation = value;
      // print(_currentLocation!.latitude);
    }));
  }
  Future<void> getSpeedLimit(double lat, double lng) async {
    // http://www.overpass-api.de/api/interpreter?data=[out:json];way[%22maxspeed%22](around:10,48.071615,7.338893);out;
    var url = Uri.parse('http://www.overpass-api.de/api/interpreter?data=[out:json];way[%22maxspeed%22](around:10,$lat,$lng);out;');
    var response = await http.get(url);
    var speedLimit = "";
    if(response.statusCode == 200){
      var body = jsonDecode(response.body);
      if(body['elements'][0]['tags']['maxspeed'] != null){
        print(body['elements'][0]['tags']['maxspeed']);
        _speedLimit = body['elements'][0]['tags']['maxspeed'];
        // speedLimit = int.parse(body['elements'][0]['tags']['maxspeed']);
        // return speedLimit;
        // return int.parse(body['elements'][0]['tags']['maxspeed']);
      }
    }
  }

  Future<void> _listenCurrentLocation() async {
    Location location = Location();
    _locationSubscription = location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        _currentLocation = currentLocation;
        lat = _currentLocation!.latitude!;
        long = _currentLocation!.longitude!;
        print("lat: $lat, long: $long");
      });
    });
    Timer.periodic(Duration(seconds: 1), (timer) async {
      await getSpeedLimit(lat, long);
      print('Current speed limit: $_speedLimit');
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
                    Text('Speed Limit: $_speedLimit')
                  ],
                ),
          ],
        ),
      ),
    );
  }
}
