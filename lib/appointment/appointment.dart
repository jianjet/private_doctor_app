import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../errorpage.dart';
import 'appointment_list.dart';

class Appointment extends StatefulWidget {
  String doc;
  Appointment({
    required this.doc,
    Key? key
  }) : super(key: key);

  @override
  State<Appointment> createState() => AppointmentState();
}

class AppointmentState extends State<Appointment> with TickerProviderStateMixin {

  late TabController _tabController;
  final user = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  Widget _appointmentList(bool status){
    return Container(
      margin: const EdgeInsets.all(0),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
          .collection('appointment_server')
          .where('doctor_uid', isEqualTo: user.uid)
          .where('booking_status', isEqualTo: status)
          .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          else if (snapshot.hasError){
            return const ErrorPage();
          }
          else if (!snapshot.hasData){
            return Container();
          }
          else {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.only(top: 0),
              itemBuilder: (context, index) {
                DocumentSnapshot document = snapshot.data!.docs[index];
                return AppointmentList(
                  patient_name: document['patient_name'],
                  service: document['service'],
                  appointment_date: document['appointment_date'],
                  appointment_time: document['appointment_time'],
                  booking_status: document['booking_status'],
                  document_id: document.id,
                  doctor_name: widget.doc,
                );
              },
            );
          }
        },
      )
    );
  }

  Widget _appointmentUnconfirmedList(){
    return Container(
      margin: const EdgeInsets.all(0),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
          .collection('appointment_server')
          //.orderBy('booking_datetime')
          .where('doctor_uid', isEqualTo: 'Unconfirmed')
          .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          else if (snapshot.hasError){
            print(snapshot.error);
            return const ErrorPage();
          }
          else if (!snapshot.hasData){
            return Container();
          }
          else {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.only(top: 0),
              itemBuilder: (context, index) {
                DocumentSnapshot document = snapshot.data!.docs[index];
                return AppointmentList(
                  patient_name: document['patient_name'],
                  service: document['service'],
                  appointment_date: document['appointment_date'],
                  appointment_time: document['appointment_time'],
                  booking_status: document['booking_status'],
                  document_id: document.id,
                  doctor_name: widget.doc,
                );
              },
            );
          }
        },
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(text: "Unconfirmed",),
            Tab(text: "Pending",),
            Tab(text: "Confirmed",)
          ]
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _appointmentUnconfirmedList(),
          _appointmentList(false),
          _appointmentList(true)
        ],
      )
    );
  }
}