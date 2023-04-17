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
  double mph = 0.0;
  String _speedLimit = "";
  int speedLimit = 0;

  Color backgroundColor = Colors.lightGreen;

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
    speedLimit = 0;
    if(response.statusCode == 200){
      var body = jsonDecode(response.body);
      if(body['elements'][0]['tags']['maxspeed'] != null){
        print(body['elements'][0]['tags']['maxspeed']);
        _speedLimit = body['elements'][0]['tags']['maxspeed'];
        RegExp regex = RegExp(r'\d+');
        Match? match = regex.firstMatch(_speedLimit);
        if(match != null){
          speedLimit = int.parse(match.group(0)!);
        }
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
        mph = _currentLocation!.speed!*2.23694;
        print("lat: $lat, long: $long");
        if (mph - speedLimit > 10) {
          backgroundColor = Colors.red;
        } else if (mph - speedLimit > 5) {
          backgroundColor = Colors.yellow;
        } else if(mph - speedLimit > 0) {
          double progress = (mph / speedLimit).clamp(0.0, 1.0);
          backgroundColor = Color.lerp(Colors.yellow, Colors.green, progress)!;
        }else{
          backgroundColor = Colors.green;
        }
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
      body: Container(
        color: backgroundColor, // 设置背景颜色为绿色
        child: Center(
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
                      // In meters/second
                      Text('Speed: ${_currentLocation != null ? mph.toInt() : 0.0 } mph'),
                      Text('Speed Accuracy: ${_currentLocation!.speedAccuracy}'),
                      Text('Speed Limit: $speedLimit mph'),
                    ],
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
