import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_app/add_visit/add_visit_search.dart';
import 'package:doctor_app/appointment/appointment.dart';
import 'package:doctor_app/chat/search_patient.dart';
import 'package:doctor_app/feedback/doctor_feedback.dart';
import 'package:doctor_app/physcical_visit/physical_visit.dart';
import 'package:doctor_app/scan_qr/scan_qr.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {

  final user = FirebaseAuth.instance.currentUser!;
  final firestore = FirebaseFirestore.instance;

  Widget _image(String image) {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 5),
      height: 150,
      width: 150,
      child: Image.asset(
        image, 
        fit: BoxFit.fill
      ),
    ); 
  }

  Widget _button(String image, String words, Function() f){
    return Container(
      margin: const EdgeInsets.all(10),
      child: SizedBox(
        width: 230,
        height: 240,
        child: ElevatedButton(
          onPressed: f, 
          child: Column(
            children: [
              _image(image),
              Container(
                margin: const EdgeInsets.only(top: 5, bottom: 5),
                child: Text(words, textAlign: TextAlign.center, style: const TextStyle(fontSize: 25),),
              )
            ],
          )
        ),
      ),
    );
  }

  void _pushAppointment() async {
    DocumentSnapshot snapshot = await firestore.collection('doctor_users').doc(user.uid).get();
    final doctor_name = snapshot.get('Name');
    Navigator.push(context, MaterialPageRoute(builder: ((context) => Appointment(doc: doctor_name))));
  }

  void _pushChat(){
    Navigator.push(context, MaterialPageRoute(builder: ((context) => const SearchPatient())));
  }

  void _pushAddVisit(){
    Navigator.push(context, MaterialPageRoute(builder: ((context) => const AddVisitSearch())));
  }

  void _pushFeedback(){
    Navigator.push(context, MaterialPageRoute(builder: ((context) => const DoctorFeedback())));
  }

  void _pushPhysicalVisit(){
    Navigator.push(context, MaterialPageRoute(builder: ((context) => const PhysicalVisit())));
  }

  void _pushScanQr(){
    Navigator.push(context, MaterialPageRoute(builder: ((context) => const ScanQr())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Homepage'),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Center(
          child: Wrap(
            children: [
              _button('./image/moving.png', 'Check Physical Visit', _pushPhysicalVisit),
              _button('./image/doc_appointment.png', 'Check Online Appointments', _pushAppointment),
              _button('./image/chat_icon.png', 'Chat with Patients', _pushChat),
              _button('./image/add_visit.png', 'Add Visit\nDetails', _pushAddVisit),
              _button('./image/feedback.png', 'Review Feedbacks', _pushFeedback),
              _button('./image/scan_qr_code.png', 'Scan\nQR code', _pushScanQr),
            ],
          ),
        ),
      )
    );
  }
}