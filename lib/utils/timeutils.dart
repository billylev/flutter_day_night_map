// day night computations orginally written by J.Giesen, converted to dart

import 'dart:math' as math;
import 'package:flutter/material.dart';

class DayNightPath {
  final double K = math.pi / 180.0;

  Path createDaynightPath(double viewWidth, double viewHeight, DateTime dt) {
    double std = 1.0 * (dt.hour) + dt.minute / 60.0 + dt.second / 3600.0;
    double dec = computeDeclination(dt.day, dt.month, dt.year, std);
    double gha = computeGHA(dt.day, dt.month, dt.year, std);

    int x = 180 - gha.toInt();
    if (x < 0) x = x + 360;
    if (x > 360) x = x - 360;
    int e = dec > 0 ? 180 : -180;

    double fx = x.toDouble();
    double fy, fyy;
    double fy0 = 90;
    double xpos = 0, ypos = 0;

    var points = <Offset>[];
    for (double i = -fx; fx + i <= 360; i += 1) {
      fyy = computeLat(i, dec);
      fy = fy0 - fyy;
      ypos = fy;
      points.add(Offset(xpos, ypos));
      xpos += 1;
    }

    double xp = viewWidth / 360.0;
    double yp = viewHeight / 180.0;

    Path map = Path()..moveTo(points[0].dx * xp, points[0].dy * yp);

    double x1, y1, x2, y2 = 0;

    for (int p = 1; p < points.length - 1; p++) {
      x1 = points[p].dx * xp;
      y1 = points[p].dy * yp;
      x2 = points[p + 1].dx * xp;
      y2 = points[p + 1].dy * yp;
      map..quadraticBezierTo(x1, y1, x2, y2);
    }

    if (e < 0) {
      map.lineTo(viewWidth, 0);
      map.lineTo(0, 0);
    } else {
      map.lineTo(viewWidth - 1, viewHeight - 1);
      map.lineTo(0, viewHeight - 1);
    }

    return map;
  }

  double computeDeclination(int T, int M, int J, double STD) {
    double N;
    double X;
    double ekLipTik, J2k;

    N = 365.0 * J + T + 31 * M - 46;
    if (M < 3)
      N = N + ((J - 1) / 4);
    else
      N = N - (0.4 * M + 2.3) + (J / 4.0);

    X = (N - 693960) / 1461.0;
    X = (X - X.toInt()) * 1440.02509 + X * 0.0307572;
    X = X + STD / 24.0 * 0.9856645 + 356.6498973;
    X = X + 1.91233 * math.sin(0.9999825 * X * K);
    X = (X + math.sin(1.999965 * X * K) / 50.0 + 282.55462) / 360.0;
    X = (X - X.toInt()) * 360.0;

    J2k = (J - 2000) / 100.0;
    ekLipTik = 23.43929111 -
        (46.8150 + (0.00059 - 0.001813 * J2k) * J2k) * J2k / 3600.0;

    X = math.sin(X * K) * math.sin(K * ekLipTik);

    return math.atan(X / math.sqrt(1.0 - X * X)) / K + 0.00075;
  }

  double computeLat(double longitude, double dec) {
    double ltan, itan;

    ltan = -math.cos(longitude * K) / math.tan(dec * K);
    itan = math.atan(ltan);
    itan = itan / K;

    return itan;
  }

  double computeGHA(int T, int M, int J, double std) {
    double N; // int
    double X, XX, P;

    N = 365.0 * J + T + 31 * M - 46;
    if (M < 3)
      N = N + ((J - 1) / 4);
    else
      N = N - (0.4 * M + 2.3) + (J / 4.0);
    P = std / 24.0;
    X = (P + N - 7.22449E5) * 0.98564734 + 279.306;
    X = X * K;
    XX = -104.55 * math.sin(X) -
        429.266 * math.cos(X) +
        595.63 * math.sin(2.0 * X) -
        2.283 * math.cos(2.0 * X);
    XX = XX + 4.6 * math.sin(3.0 * X) + 18.7333 * math.cos(3.0 * X);
    XX = XX -
        13.2 * math.sin(4.0 * X) -
        math.cos(5.0 * X) -
        math.sin(5.0 * X) / 3.0 +
        0.5 * math.sin(6.0 * X) +
        0.231;
    XX = XX / 240.0 + 360.0 * (P + 0.5);
    if (XX > 360) XX = XX - 360.0;
    return XX;
  }
}
