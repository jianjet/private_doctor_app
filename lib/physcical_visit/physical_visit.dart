import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_app/physcical_visit/physical_visit_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../errorpage.dart';

class PhysicalVisit extends StatefulWidget {
  const PhysicalVisit({
    Key? key
  }) : super(key: key);

  @override
  State<PhysicalVisit> createState() => PhysicalVisitState();
}

class PhysicalVisitState extends State<PhysicalVisit> with TickerProviderStateMixin {

  late TabController _tabController;
  final user = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  Widget _appointmentList(bool status){
    return Container(
      margin: const EdgeInsets.all(0),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
          .collection('physical_visit_server')
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
                return PhysicalVisitList(
                  patient_name: document['patient_name'],
                  service: document['service'],
                  appointment_date: document['appointment_date'],
                  appointment_time: document['appointment_time'],
                  booking_status: document['booking_status'],
                  document_id: document.id,
                  address: document['address'],
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
        title: const Text('Physical Visit'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(text: "Pending",),
            Tab(text: "Confirmed",)
          ]
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _appointmentList(false),
          _appointmentList(true)
        ],
      )
    );
  }
}