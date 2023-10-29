import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_app/user_authentication/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddVisit extends StatefulWidget {
  String patient_uid;

  AddVisit({
    required this.patient_uid,
    Key? key
    }) : super(key: key);
  @override
  AddVisitState createState() => AddVisitState();
}

class AddVisitState extends State<AddVisit> {

  final TextEditingController _illnessController = TextEditingController();
  final TextEditingController _medicationsController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final User? user = FirebaseAuth.instance.currentUser;

  Widget _illness() {
    return TextFormField(
      controller: _illnessController,
      decoration: const InputDecoration(labelText: 'Illness'),
      validator: (String? value) {
        if (value!.isEmpty) {
          return 'Please write the patient\'s illness.';
        }
        return null;
      },
    );
  }

  Widget _medication() {
    return TextFormField(
      controller: _medicationsController,
      decoration: const InputDecoration(labelText: 'Medications'),
      validator: (String? value) {
        if (value!.isEmpty) {
          return 'Please write the patient\'s medications.';
        }
        return null;
      },
    );
  }

  Widget _place() {
    return TextFormField(
      controller: _placeController,
      decoration: const InputDecoration(labelText: 'Place of Visit'),
      validator: (String? value) {
        if (value!.isEmpty) {
          return 'Please write the place of visit.';
        }
        return null;
      },
    );
  }

  Future _submit() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    showDialog(
      context: context, 
      builder: (context) => const Center(child: CircularProgressIndicator())
    );
    try {
      DocumentReference newDocRef = await firestore.collection('doctor_visit_server').add({
        'doctor_uid': user!.uid,
        'illness': _illnessController.text.trim(),
        'medications': _medicationsController.text.trim(),
        'visit_place': _placeController.text.trim(),
        'visit_time': DateTime.now().millisecondsSinceEpoch,
      });
      final dsnapshot = await firestore.collection('doctor_users').where('uid', isEqualTo: user!.uid).get();
      if (dsnapshot.docs.isNotEmpty) {
        final data = dsnapshot.docs.first.data();
        final doctor_name = data['Name'];
        await firestore.collection('doctor_visit_server').doc(newDocRef.id).update({
          'doctor_name': doctor_name
        });
      }
      final psnapshot = await firestore.collection('patient_users').doc(widget.patient_uid).get();
      if (psnapshot.exists){
        final data = psnapshot.data();
        final patient_name = data!['Name'];
        final patient_uid = data['uid'];
        await firestore.collection('doctor_visit_server').doc(newDocRef.id).update({
          'patient_name':patient_name,
          'patient_uid':patient_uid,
        });
      }
    } on FirebaseAuthException catch (e){
      Utils.showSnackbar(e.message);
    }
    Navigator.of(context).pop();
  }

  Widget _submitButton(){
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: ElevatedButton(
        onPressed: () {
          _submit();
        },
        child: const Text('Submit', style: TextStyle(fontSize: 24))),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Visit Details'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                _illness(),
                _medication(),
                _place(),
                _submitButton()
              ],
            ),
          ),
        ),
      )
    );
  }
}