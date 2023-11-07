import 'package:doctor_app/scan_qr/waiting_confirmation.dart';
import 'package:flutter/material.dart';
import 'package:doctor_app/scan_qr/encryption.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:io';

class ScanQr extends StatefulWidget {
  const ScanQr({Key? key}) : super(key: key);
  @override
  ScanQrState createState() => ScanQrState();
}

class ScanQrState extends State<ScanQr> {
  String qrData = "No data found!";
  var data;
  bool hasData = false;
  AESEncryptionForPatientId encryption = AESEncryptionForPatientId();
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? barcode;
  bool _loadingQr = false;

  Widget _buildQrView(BuildContext context) {
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        cutOutSize: MediaQuery.of(context).size.width * 0.8,
        borderWidth: 10,
        borderLength: 20,
        borderColor: Colors.green
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((barcode) {
      setState(() {
        this.barcode = barcode;
        controller.pauseCamera();
        _loadingQr = true;
        _pushScanQr(this.barcode!.code);
      });
    });
  }

  void _pushScanQr(String? encryptedPatientId) {
    if (encryptedPatientId != null) {
      showDialog(
        context: context,
        builder: (context) {
          return Dialog.fullscreen(
            child: WaitingConfirmation(encryptedPatientId: encryptedPatientId),
          );
        },
      )
      .then((res) {
        setState(() {
          _loadingQr = false;
          controller!.resumeCamera();
        });
      }).catchError((err) {
        print(err);
      });
    }
  }

  Widget buildResult(){
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Text(
        barcode != null ? "${barcode!.code}" :
        "Scan a code!", //change here
        maxLines: 3
      ),
    );
  }

  Widget buildControlButtons(){
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () async {
              await controller?.toggleFlash();
              setState(() {
                
              });
            }, 
            icon: FutureBuilder<bool?>(
              future: controller?.getFlashStatus(),
              builder: (context, snapshot) {
                if (snapshot.data != null){
                  return snapshot.data! ? const Icon(Icons.flash_on) : const Icon(Icons.flash_off);
                }
                else{
                  return Container();
                }
              },
            )
          ),
          IconButton(
            onPressed: () async {
              await controller?.flipCamera();
              setState(() {
                
              });
            }, 
            icon: FutureBuilder(
              future: controller?.getCameraInfo(),
              builder: (context, snapshot) {
                if (snapshot.data != null){
                  return const Icon(Icons.switch_camera);
                }
                else{
                  return Container();
                }
              },
            )
          ),
        ],
      )
    );
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR scanner'),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          _buildQrView(context),
          if (_loadingQr) ... [
            const CircularProgressIndicator()
          ],
          Positioned(bottom: 20, child: buildResult()),
          Positioned(top: 10, child: buildControlButtons())
        ],
      )
    );
  }
}