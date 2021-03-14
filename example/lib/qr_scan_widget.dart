import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_scan/qr_scan.dart';

class QrScanWidget extends StatefulWidget {
  final Function(String) onScan;
  final double scanBoxRatio;
  final Color boxLineColor;

  QrScanWidget({
    Key key,
    @required this.onScan,
    this.boxLineColor = Colors.blueAccent,
    this.scanBoxRatio = 0.7,
  }) : super(key: key);

  @override
  QrScanWidgetState createState() => new QrScanWidgetState();
}

class QrScanWidgetState extends State<QrScanWidget>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  QrReaderViewController _controller;
  AnimationController _animationController;
  bool openFlashlight;
  Timer _timer;
  bool _isCameraPermission = false;
  String _scanStr = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    openFlashlight = false;
    _permissionStatus();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.resumed:
        _permissionStatus();
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  _permissionStatus() async {
    Permission.camera.request().then((status) {
      _isCameraPermission = status.isGranted;
      if (status.isGranted) {
        startScan();
      }
      setState(() {});
    });
  }

  void _initAnimation() {
    if (_animationController == null) {
      _animationController = AnimationController(
          vsync: this, duration: Duration(milliseconds: 1000));
      _animationController
        ..addListener(_upState)
        ..addStatusListener((state) {
          if (state == AnimationStatus.completed) {
            _timer = Timer(Duration(seconds: 1), () {
              _animationController?.reverse(from: 1.0);
            });
          } else if (state == AnimationStatus.dismissed) {
            _timer = Timer(Duration(seconds: 1), () {
              _animationController?.forward(from: 0.0);
            });
          }
        });
      _animationController.forward(from: 0.0);
    }
  }

  void _clearAnimation() {
    _timer?.cancel();
    if (_animationController != null) {
      _animationController?.dispose();
      _animationController = null;
    }
  }

  void _upState() {
    setState(() {});
  }

  void _onCreateController(QrReaderViewController controller) async {
    _controller = controller;
  }

  bool isScan = false;

  Future _onQrBack(data, _) async {
    if (isScan == true) return;
    isScan = true;
    stopScan();
    await widget.onScan(data);
    _scanStr = data;
    setState(() {});
  }

  void startScan() {
    isScan = false;
    _controller?.startScan(_onQrBack);
    _initAnimation();
  }

  void stopScan() {
    _clearAnimation();
    _controller?.stopScan();
  }

  Future _scanImage() async {
    try {
      PermissionStatus photosStatus = await Permission.photos.request();
      if (photosStatus.isGranted) {
        stopScan();
        var image = await ImagePicker.pickImage(source: ImageSource.gallery);
        if (image == null) {
          startScan();
          return;
        }
        final rest = await QrScan.imgScan(image);
        await widget.onScan(rest);
        _scanStr = rest;
        setState(() {});
        startScan();
      } else {
        // Open photo album permissions
        openAppSettings();
      }
    } catch (e) {
      if (Platform.isAndroid && e is PlatformException) {
        if (e.code == "photo_access_denied") {
          openAppSettings();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final qrScanSize = constraints.maxWidth * widget.scanBoxRatio;
      return Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: _isCameraPermission ? QrReaderView(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              callback: _onCreateController,
            ) : Container(
              child: QrReaderView(
                width: 300,
                height: 300,
                callback: (controller){
                  controller.startScan((data,_){
                    // scan success
                  });
                  controller.stopScan();
                  controller.setFlashlight();
                },
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: qrScanSize,
                height: qrScanSize,
                margin: EdgeInsets.only(bottom: 20),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    CustomPaint(
                      painter: QrScanBoxPainter(
                        boxLineColor: widget.boxLineColor,
                        animationValue: _animationController?.value ?? 0,
                        isForward: _animationController?.status ==
                            AnimationStatus.forward,
                      ),
                      child: SizedBox(
                        width: qrScanSize,
                        height: qrScanSize,
                      ),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () async {
                        openFlashlight = !openFlashlight;
                        _controller.setFlashlight();
                        setState(() {});
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 10),
                        child: Icon(
                          Icons.highlight_rounded,
                          size: 35,
                          color: openFlashlight
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Text(
                "Please place the QR code in the box",
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _scanImage,
                child: Container(
                  width: 45,
                  height: 45,
                  alignment: Alignment.center,
                  child: Icon(Icons.photo, size: 35, color: Colors.white54),
                ),
              ),
            ],
          ),
          Positioned(
            top: 80,
            child: !_isCameraPermission
                ? GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      openAppSettings();
                    },
                    child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.all(
                              Radius.circular(24), // 也可控件一边圆角大小
                            )),
                        child: Text(
                          'To allow camera permissions, click Settings',
                          style: TextStyle(color: Colors.white),
                        )))
                : Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(_scanStr,
                        style:
                            TextStyle(color: Theme.of(context).primaryColor))),
          ),
        ],
      );
    });
  }

  @override
  void dispose() {
    stopScan();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

class QrScanBoxPainter extends CustomPainter {
  final double animationValue;
  final bool isForward;
  final Color boxLineColor;

  QrScanBoxPainter(
      {@required this.animationValue,
      @required this.isForward,
      this.boxLineColor})
      : assert(animationValue != null),
        assert(isForward != null);

  @override
  void paint(Canvas canvas, Size size) {
    final borderRadius = BorderRadius.all(Radius.circular(12)).toRRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
    );
    canvas.drawRRect(
      borderRadius,
      Paint()
        ..color = Colors.white54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final path = new Path();
    // leftTop
    path.moveTo(0, 50);
    path.lineTo(0, 12);
    path.quadraticBezierTo(0, 0, 12, 0);
    path.lineTo(50, 0);
    // rightTop
    path.moveTo(size.width - 50, 0);
    path.lineTo(size.width - 12, 0);
    path.quadraticBezierTo(size.width, 0, size.width, 12);
    path.lineTo(size.width, 50);
    // rightBottom
    path.moveTo(size.width, size.height - 50);
    path.lineTo(size.width, size.height - 12);
    path.quadraticBezierTo(
        size.width, size.height, size.width - 12, size.height);
    path.lineTo(size.width - 50, size.height);
    // leftBottom
    path.moveTo(50, size.height);
    path.lineTo(12, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - 12);
    path.lineTo(0, size.height - 50);

    canvas.drawPath(path, borderPaint);

    canvas.clipRRect(
        BorderRadius.all(Radius.circular(12)).toRRect(Offset.zero & size));

    // 绘制横向网格
    final linePaint = Paint();
    final lineSize = size.height * 0.45;
    final leftPress = (size.height + lineSize) * animationValue - lineSize;
    linePaint.style = PaintingStyle.stroke;
    linePaint.shader = LinearGradient(
      colors: [Colors.transparent, boxLineColor],
      begin: isForward ? Alignment.topCenter : Alignment(0.0, 2.0),
      end: isForward ? Alignment(0.0, 0.5) : Alignment.topCenter,
    ).createShader(Rect.fromLTWH(0, leftPress, size.width, lineSize));
    for (int i = 0; i < size.height / 5; i++) {
      canvas.drawLine(
        Offset(
          i * 5.0,
          leftPress,
        ),
        Offset(i * 5.0, leftPress + lineSize),
        linePaint,
      );
    }
    for (int i = 0; i < lineSize / 5; i++) {
      canvas.drawLine(
        Offset(0, leftPress + i * 5.0),
        Offset(
          size.width,
          leftPress + i * 5.0,
        ),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(QrScanBoxPainter oldDelegate) =>
      animationValue != oldDelegate.animationValue;

  @override
  bool shouldRebuildSemantics(QrScanBoxPainter oldDelegate) =>
      animationValue != oldDelegate.animationValue;
}
