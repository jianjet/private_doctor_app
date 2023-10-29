import '../useful_widget.dart';
import 'package:flutter/material.dart';

class PastVisit extends StatefulWidget {
  const PastVisit({Key? key}) : super(key: key);
  @override
  PastVisitState createState() => PastVisitState();
}

class PastVisitState extends State<PastVisit> {

  Widget _text2(String words, double size, double marginTop, double marginBottom, bool x){
    return Container(
      margin: EdgeInsets.only(left: 13, top: marginTop, bottom: marginBottom),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          words, style: TextStyle(fontSize: size, fontWeight: x ? FontWeight.bold : FontWeight.normal)
        ),
      )
    );
  }

  Widget _row1(double t, double b1, double b2){
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: const BorderRadius.all(Radius.circular(10))
      ),
      padding: EdgeInsets.only(bottom: b2),
      margin: EdgeInsets.only(top: t, bottom: b1, left: 15, right: 15),
      child: Column(
        children: [
          _text2('2 July 2022', 23, 5, 5, true),
          _text2('UMMC Dialysis Centre', 18, 0, 15, false),
          _text2('Kind: Peritoneal Dialysis', 18, 0, 2, false),
          _text2('Weight: 84 kg', 18, 0, 2, false),
          _text2('Dry Weight: 72 kg', 18, 0, 2, false),
          _text2('Complications: Shortness of Breath', 18, 0, 2, false)
        ]
      )
    );
  }

  Widget _row2(double t, double b1, double b2){
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: const BorderRadius.all(Radius.circular(10))
      ),
      padding: EdgeInsets.only(bottom: b2),
      margin: EdgeInsets.only(top: t, bottom: b1, left: 15, right: 15),
      child: Column(
        children: [
          _text2('2 July 2022', 23, 5, 5, true),
          _text2('NK Dialysis Centre', 18, 0, 15, false),
          _text2('Kind: Hemo-Dialysis', 18, 0, 2, false),
          _text2('Weight: 78 kg', 18, 0, 2, false),
          _text2('Dry Weight: 72 kg', 18, 0, 2, false),
          _text2('Complications: Muscle Cramp over left leg', 18, 0, 2, false)
        ]
      )
    );
  }

  Widget _row3(double t, double b1, double b2){
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: const BorderRadius.all(Radius.circular(10))
      ),
      padding: EdgeInsets.only(bottom: b2),
      margin: EdgeInsets.only(top: t, bottom: b1, left: 15, right: 15),
      child: Column(
        children: [
          _text2('23 July 2022', 23, 5, 5, true),
          _text2('Renal Dialysis Centre', 18, 0, 15, false),
          _text2('Kind: HemoDialysis', 18, 0, 2, false),
          _text2('Weight: 80 kg', 18, 0, 2, false),
          _text2('Dry Weight: 72 kg', 18, 0, 2, false),
          _text2('Complications: None', 18, 0, 2, false)
        ]
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Past Dialysis Visit'),
      ),
      body: Center(
        child: CustomScrollView(
          anchor: 0.0,
          slivers: <Widget>[
            silverListConstant(_row1(20, 10, 25), 1),
            silverListConstant(_row2(5, 10, 25), 1),
            silverListConstant(_row3(5, 30, 25), 1)
          ],
        ),
      )
    );
  }
}