import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'constants.dart' as k;
import 'dart:convert';

class LocationPage extends StatefulWidget {
  LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  bool isLoaded = true;
  late String cityname = '';
  late num temp;
  late num press;
  late num hum;
  late num cover;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentLocation();
  }

  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Color(0xffeeaeca),
            Color(0xff94bbe9),
          ], begin: Alignment.bottomRight, end: Alignment.topRight),
        ),
        child: Visibility(
          visible: isLoaded,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 3, spreadRadius: 3, offset: Offset(4, 4)),
                ]),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                        errorBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        border: InputBorder.none,
                        hintText: 'Enter A City..',
                        helperStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        )),
                    onFieldSubmitted: (String s) {
                      setState(() {
                        cityname = s;
                        getCityWeather(s);
                        isLoaded = false;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.pin_drop,
                      color: Colors.purple,
                      size: 30,
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      cityname,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          replacement: Center(child: CircularProgressIndicator()),
        ),
      ),
    ));
  }

  getCurrentLocation() async {
    var p = await _determinePosition();

    if (p != null) {
      print('Lat :${p.latitude}, Long :${p.longitude}');
      await getCurrentCityWeather(p);
    } else {
      print("Unavilable Location");
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
      forceAndroidLocationManager: true,
    );
  }

  getCityWeather(String cityName) async {
    var client = http.Client();
    var uri = '${k.domain}q=$cityName&appid=${k.apikey}';

    var url = Uri.parse(uri);
    var response = await client.get(url);
    if (response.statusCode == 200) {
      var data = response.body;
      var decodedData = json.decode(data);
      print(data);
      updateUi(decodedData);
      setState(() {
        isLoaded = true;
      });
    } else {
      print(response.statusCode);
    }
  }

  Future<void> getCurrentCityWeather(Position position) async {
    var client = http.Client();
    var uri = '${k.domain}/current.json?'
        'q=${11.0510},${75.9825}&key=${k.apikey}';
    print('====================');
    print(uri);
    print('====================');

    var url = Uri.parse(uri);
    var response = await client.get(url);
    print(response.body);
    if (response.statusCode == 200) {
      var data = response.body;
      var decodedData = json.decode(data);
      setState(() {
        isLoaded = true;
      });
      print(data);
      // updateUi(decodedData);
    } else {
      print(response.statusCode);
    }
  }

  updateUi(var decodedData) {
    setState(() {
      if (decodedData == null) {
        temp = 0;
        press = 0;
        hum = 0;
        cover = 0;
        cityname = 'Not avilable';
      } else {
        temp = decodedData['main']['temp'] - 273;
        press = decodedData['main']['pressure'];
        hum = decodedData['main']['humidity'];
        cover = decodedData['clouds']['all'];
        cityname = decodedData['name'];
      }
    });
  }
}
