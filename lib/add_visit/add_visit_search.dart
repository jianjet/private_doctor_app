import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_app/add_visit/add_visit_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../errorpage.dart';

class AddVisitSearch extends StatefulWidget {
  const AddVisitSearch({super.key});

  @override
  State<AddVisitSearch> createState() => _AddVisitSearchState();
}

class _AddVisitSearchState extends State<AddVisitSearch> {

  final user = FirebaseAuth.instance.currentUser!;

  Widget _patientList(){
    return Container(
      margin: const EdgeInsets.all(0),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
          .collection('message_server')
          .where('doctor', isEqualTo: user.uid)
          .snapshots(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          else if (snapshot.hasError){
            return const ErrorPage();
          }
          else {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(top: 0),
              itemBuilder: ((context, index) {
                DocumentSnapshot document = snapshot.data!.docs[index];
                return AddVisitList(
                  patient_uid: document['patient'],
                );
              })
            );
          }
        }
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patients'),
      ),
      body: SafeArea(
        child: _patientList()
      ),
    );
  }
}