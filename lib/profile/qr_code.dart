import '../useful_widget.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QR extends StatefulWidget {
  const QR({Key? key}) : super(key: key);
  @override
  QRState createState() => QRState();
}

class QRState extends State<QR> {

  String rn='31651320';

  Widget _girlIconImage(){
    return Container(
      margin: const EdgeInsets.only(top: 30),
      height: 130,
      width: 130,
      child: Image.asset(
        "./image/girl_icon.png", 
        fit: BoxFit.cover),
    );
  }

  Widget _text2(String words, double size, double marginTop, double marginBottom, bool x, Color y){
    return Container(
      margin: EdgeInsets.only(left: 10, top: marginTop, bottom: marginBottom),
      child: Align(
        alignment: Alignment.center,
        child: Text(
          words, style: TextStyle(fontSize: size, color: y,fontWeight: x ? FontWeight.bold : FontWeight.normal)
        ),
      )
    );
  }

  Widget _details(){
    return Column(
      children: [
        _text2('Zulianah Binti Mohd. Rosli', 20, 10, 0, true, Colors.black),
        _text2('40 years, Female', 15, 5, 0, false, (Colors.grey[600])!),
        _text2('IC: 820419-10-xxxx', 15, 5, 5, false, (Colors.grey[600])!),
      ],
    );
  } 

  Widget _qrgen(){
    return Column(
      children: [
        _text2('- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -', 20, 10, 0, true, (Colors.grey[400])!),
        Container(
          margin: const EdgeInsets.only(top: 20, bottom: 25),
          child: QrImage(
            data: rn,
            version: QrVersions.auto,
            size: 250.0,
          ),
        ),
        _text2('RN number: $rn', 15, 5, 30, false, (Colors.grey[600])!),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Data'),
      ),
      body: Center(
        child: CustomScrollView(
          anchor: 0.0,
          slivers: <Widget>[
            silverListConstant(_girlIconImage(), 1),
            silverListConstant(_details(), 1),
            silverListConstant(_qrgen(), 1),
          ],
        ),
      )
    );
  }
}