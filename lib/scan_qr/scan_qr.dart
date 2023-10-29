import 'package:flutter/material.dart';
import 'package:doctor_app/scan_qr/AES.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanQr extends StatefulWidget {
  const ScanQr({Key? key}) : super(key: key);
  @override
  ScanQrState createState() => ScanQrState();
}

class ScanQrState extends State<ScanQr> {
  String qrData = "No data found!";
  var data;
  bool hasData = false;
  AESEncryption encryption = AESEncryption();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR scanner'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(data)
            ],
          ),
        ),
      )
    );
  }
}