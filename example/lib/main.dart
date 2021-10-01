import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pointmobile_scanner/pointmobile_scanner.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _decodeResult = "Unknown";

  @override
  void initState() {
    super.initState();

    PointmobileScanner.channel.setMethodCallHandler(_onBarcodeScannerHandler);
    PointmobileScanner.initScanner();
    PointmobileScanner.enableScanner();
    PointmobileScanner.enableBeep();
    PointmobileScanner.enableSymbology(PointmobileScanner.SYM_CODE128);
    PointmobileScanner.enableSymbology(PointmobileScanner.SYM_EAN13);
    PointmobileScanner.enableSymbology(PointmobileScanner.SYM_QR);
    PointmobileScanner.enableSymbology(PointmobileScanner.SYM_UPCA);

    setState(() {
      _decodeResult = "Ready to decode";
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Scanner plugin example app'),
          actions: <Widget> [
            PopupMenuButton(
              icon: Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 1) _onExit();
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                const PopupMenuItem(child: Text('Exit'), value: 1),
              ],
            ),
          ],
        ),
        body: Center(
          child: Text('$_decodeResult\n'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            PointmobileScanner.triggerOn();
          },
          child: Icon(Icons.view_week_rounded),
        ),
      ),
    );
  }

  Future<void> _onBarcodeScannerHandler(MethodCall call) async {
    try {
      if (call.method == PointmobileScanner.ON_DECODE) {
        _onDecode(call);
      } else if (call.method == PointmobileScanner.ON_ERROR) {
        _onError(call.arguments);
      } else {
        print(call.arguments);
      }
    } catch(e) {
      print(e);
    }
  }

  void _onDecode(MethodCall call) {
    setState(() {
      final List lDecodeResult = call.arguments;
      _decodeResult = "Symbology: ${lDecodeResult[0]}\nValue: ${lDecodeResult[1]}";
    });
  }

  void _onExit() {
    PointmobileScanner.disableScanner();
    SystemNavigator.pop();
  }

  void _onError(Exception error) {
    setState(() {
      _decodeResult = error.toString();
    });
  }
}
