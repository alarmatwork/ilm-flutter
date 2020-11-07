import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';

class Compass extends StatefulWidget {
  final dynamic stationData;

  Compass({Key key, this.stationData}) : super(key: key);

  @override
  _CompassState createState() => _CompassState();
}

class _CompassState extends State<Compass> {
  double _heading = 0;

  StreamSubscription<double> _subscription;

  String get _readout => ''; //_heading.toStringAsFixed(0) + '°';

  @override
  void initState() {
    super.initState();
    print("COMPASS init was called");
  }

  @override
  void dispose() {
    super.dispose();
    print("COMPASS dispose was called");
    _subscription.cancel();
    print("COMPASS-PAUSE");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _subscription = FlutterCompass.events.listen(_onData);
    print("COMPASS didChangeDependencies was called");
  }

  void _onData(double x) {
    int windDirection = widget.stationData['windDirection'];
    if (mounted && windDirection != null) {
      setState(() {
        _heading = (x + 180 + windDirection) % 360;
        // print("compass: $x calculcated: $_heading from station: ${widget.stationData['windDirection']}");
      });
    } else {
      //   print("Cant paint. not mounted");
    }
  }

  final TextStyle _style = TextStyle(
    color: Colors.red[50].withOpacity(0.9),
    fontSize: 32,
    fontWeight: FontWeight.w200,
  );

  @override
  Widget build(BuildContext context) {
    return (widget.stationData['windDirection'] != null)
        ? CustomPaint(
            foregroundPainter: CompassPainter(angle: _heading), child: Center(child: Text(_readout, style: _style)))
        : Container();
  }
}

class CompassPainter extends CustomPainter {
  CompassPainter({@required this.angle}) : super();

  final double angle;
  double get rotation => ((angle) * pi) / 180;

  Paint get _brush => new Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;

  Paint _paint = Paint()
    ..color = Color(0xFF4FB6F0)
    ..strokeWidth = 3.0
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    Paint circle = _brush..color = Colors.indigo[400].withOpacity(0.6);

    Paint needle = _brush..color = Colors.red[400];

    double radius = min(size.width, size.height);
    Offset center = Offset(size.width / 2, size.height / 2);
    Offset start = Offset.lerp(Offset(center.dx, radius), center, .4);
    Offset end = Offset.lerp(Offset(center.dx, radius), center, 0.1);

    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.translate(-center.dx, -center.dy);

    // canvas.drawLine(start, end, needle);

    var path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(50, size.height / 2);
    path.lineTo(size.height - 50, size.width / 2);
    path.close();
    canvas.drawPath(path, _paint);

    //  canvas.drawCircle(end, 10, needle);
    //canvas.drawCircle(center, radius, circle);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
