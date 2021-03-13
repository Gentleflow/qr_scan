import 'package:flutter/material.dart';
import 'qr_scan_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(title:Text('Scan')),
          body: QrScanWidget(
            onScan: (String str) {
              print('Scan data : $str');
            },
          )),
    );
  }
}
