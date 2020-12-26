import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:playground/utils/timeutils.dart';
import 'package:lat_lng_to_timezone/lat_lng_to_timezone.dart' as tzmap;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:intl/intl.dart' as intl;

class City {
  final double lat;
  final double lon;
  final String name;
  final String timeZone;
  String time;

  City(this.lat, this.lon, this.name, {this.time})
      : this.timeZone = tzmap.latLngToTimezoneString(lat, lon);

  void updateTime(DateTime dateTime) {
    tz.initializeTimeZones();
    var location = tz.getLocation(timeZone);
    var now = tz.TZDateTime.from(dateTime, location);
    time = intl.DateFormat.jm().format(now);
  }
}

class DayNightMap extends StatelessWidget {
  final DayNightPath _dayNightPath = DayNightPath();
  final List<City> cityList;
  final DateTime datetime;

  DayNightMap({Key key, @required this.cityList, @required this.datetime})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    print(datetime.toString());

    Path path = _dayNightPath.createDaynightPath(width, width / 2, datetime);

    return Stack(children: [
      Image.asset('assets/day.jpg', width: width, height: width / 2),
      CustomPaint(
        painter: DayNightMapPainter(path, cityList),
        size: Size(width, width / 2),
      ),
    ]);
  }
}

class DayNightMapPainter extends CustomPainter {
  Size _size;
  Canvas _canvas;
  Paint _paintObject;

  final Path path;
  final List<City> cityList;

  DayNightMapPainter(this.path, this.cityList);

  @override
  void paint(Canvas canvas, Size size) {
    _init(canvas, size);
    _paintDaynightOverlay();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  void _init(Canvas canvas, Size size) {
    this._canvas = canvas;
    this._size = size;
    _paintObject = Paint();
  }

  void _drawCity(double x, double y, String name) {
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 8,
    );
    final textSpan = TextSpan(
      text: name,
      style: textStyle,
    );
    final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center);
    textPainter.layout(
      minWidth: 0,
      maxWidth: _size.width,
    );

    var xp = x - textPainter.width / 2;
    if (xp < 0) {
      xp = 5;
    } else if (xp + textPainter.width > _size.width) {
      xp = _size.width - textPainter.width - 5;
    }
    var yp = y - textPainter.height;
    if (yp < 0) {
      xp = 5;
    } else if (yp + textPainter.height > _size.height) {
      yp = _size.height - textPainter.height - 5;
    }

    final offset = Offset(xp, yp);

    textPainter.paint(_canvas, offset);
  }

  void _paintDaynightOverlay() {
    _paintObject
      ..color = Color(0x45000000)
      ..style = PaintingStyle.fill;

    _canvas.drawPath(path, _paintObject);

    double xscale = _size.width / 360.0;
    double yscale = _size.height / 180.0;
    double aspectRatio = _size.height / _size.width;

    _paintObject
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    cityList.forEach((city) {
      double cityX = (180 + city.lon);
      double cityY = (90 - city.lat);

      _canvas.drawCircle(Offset(cityX * xscale, cityY * yscale),
          8 * aspectRatio, _paintObject);

      _drawCity(cityX * xscale, cityY * yscale - (8 * aspectRatio),
          city.name + ' ' + city.time);
    });
  }
}
