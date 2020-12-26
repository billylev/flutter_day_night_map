import 'dart:async';

import 'package:flutter/material.dart';
import 'package:playground/zoomOverlay.dart';
import 'daynightMap.dart';
import 'package:intl/intl.dart' as intl;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'City time',
      theme:
          ThemeData(primarySwatch: Colors.blue, brightness: Brightness.light),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _cityList = <City>[];
  final _startDate = DateTime.now();
  int _minutes = 0;

  @override
  void initState() {
    super.initState();

    _cityList.add(City(41.8083, -74.2318, 'New York'));
    _cityList.add(City(51.5084152563931, -0.125532746315002, 'London'));
    _cityList.add(City(39.9042, 116.4074, 'Beijing'));
    _cityList.add(City(30.0444, 31.2357, 'Cairo'));
    _cityList.add(City(19.0760, 72.8777, 'Mumbai'));
    _cityList.add(City(-23.5505, -46.6333, 'São Paulo'));
    _cityList.add(City(19.4326, -99.1332, 'Mexico City'));
    _cityList.add(City(35.6762, 139.6503, 'Tokyo'));
    _cityList.add(City(-33.8688, 151.2093, 'Sydney'));

    Timer.periodic(
        Duration(milliseconds: 100),
        (Timer t) => {
              setState(() {
                _minutes = _minutes + 30;
              }),
            });
  }

  @override
  Widget build(BuildContext context) {
    final showDate = _startDate.add(Duration(minutes: _minutes));

    _cityList.forEach((city) => city.updateTime(showDate));

    return Scaffold(
        body: ListView(children: [
      ZoomOverlay(
          twoTouchOnly: true,
          child: DayNightMap(cityList: _cityList, datetime: showDate.toUtc())),
      Center(child: Text(intl.DateFormat.yMd().add_jm().format(showDate)))
    ]));
  }
}
