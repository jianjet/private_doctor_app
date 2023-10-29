import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_app/errorpage.dart';
import 'package:doctor_app/feedback/doctor_feedback_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DoctorFeedback extends StatefulWidget {
  const DoctorFeedback({Key? key}) : super(key: key);
  @override
  DoctorFeedbackState createState() => DoctorFeedbackState();
}

class DoctorFeedbackState extends State<DoctorFeedback> {

  final user = FirebaseAuth.instance.currentUser!;

  Widget _feedbackList(){
    return Container(
      margin: const EdgeInsets.all(0),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
          .collection('doctor_users')
          .doc(user.uid)
          .collection('Rating')
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
                return DoctorFeedbackList(
                  patient_uid: document['patient_uid'],
                  feedback: document['feedback'],
                  service_rating: document['service_rating'],
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
        title: const Text('Feedback List'),
      ),
      body: SafeArea(
        child: _feedbackList()
      )
    );
  }
}