import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_app/classes_enums_dicts/roles_enum.dart';
import 'package:doctor_app/scan_qr/encryption.dart';
import 'package:doctor_app/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../errorpage.dart';

class WaitingConfirmation extends StatefulWidget {
  String encryptedPatientId;
  WaitingConfirmation({
    required this.encryptedPatientId,
    Key? key
    }) : super(key: key);

  @override
  WaitingConfirmationState createState() => WaitingConfirmationState();
}

class WaitingConfirmationState extends State<WaitingConfirmation> {

  final user = FirebaseAuth.instance.currentUser;
  final firestore = FirebaseFirestore.instance;
  AESEncryptionForPatientId encryption = AESEncryptionForPatientId(); 

  Future<void> _checkPatientConfirmationStatus() async {
    try {
      QuerySnapshot querySnapshot = await firestore.collection('PatientDataRequestLog')
        .where('UnderRequest', isEqualTo: true)
        .where('PatientId', isEqualTo: encryption.decryptMsg(encryption.getCode(widget.encryptedPatientId)).toString())
        .get();
      if (querySnapshot.docs.isNotEmpty) {
        DocumentReference documentRef = querySnapshot.docs.first.reference;
        QuerySnapshot querySnapshot2 = await firestore.collection('PatientDataRequestLog').doc(documentRef.id).collection('Logs')
          .where('ApprovalStatus', isEqualTo: ApprovalStatus.pending.name)
          .get();
        DocumentSnapshot document = querySnapshot2.docs.first;
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        
      } else {
        Utils.showSnackbar('Patient does not exist.');
      }
    } on FirebaseException catch (e) {
      Utils.showSnackbar(e.message);
    }
  }

  Widget _confirmationDialog(bool confirmationStatus){
    return AlertDialog(
      title: const Text('Waiting for confirmation...'),
      content: confirmationStatus ? const Text("Successful!") : const SizedBox(),
      actions: [
        if (confirmationStatus) ... [
          ElevatedButton(
            onPressed: (){
              Navigator.of(context).pop();
            }, 
            child: const Text("Ok")
          )
        ] else ... [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            }, 
            child: const Text("Close")
          )
        ]
      ],
    );
  }

  Future<Map<String, String>> _loadData() async {
    String patientDataRequestLogId = "";
    String logId = "";
    String patientId = encryption.decryptMsg(encryption.getCode(widget.encryptedPatientId)).toString();
    final DocumentSnapshot doctorDocument = await firestore.collection('doctor_users').doc(user!.uid).get();
    final doctorData = doctorDocument.data() as Map<String, dynamic>;
    String doctorName = doctorData['Name'];
    final QuerySnapshot querySnapshot = await firestore.collection('PatientDataRequestLog').where('PatientId', isEqualTo: patientId).get();
    if (querySnapshot.docs.isNotEmpty) {
      final DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
      final DocumentReference docRef = documentSnapshot.reference;
      patientDataRequestLogId = docRef.id;
      final DocumentReference document = firestore.collection('PatientDataRequestLog').doc(patientDataRequestLogId);
      final CollectionReference collection = firestore.collection('PatientDataRequestLog').doc(patientDataRequestLogId).collection("Logs");
      try {
        await document.update({
          "UnderRequest": true,
        });
        var doc = await collection.add({
          "ApprovalStatus" : ApprovalStatus.pending.name,
          "StartTimeInMSSinceEpoch" : DateTime.now().millisecondsSinceEpoch,
          "DoctorId" : user!.uid,
          "DoctorName" : doctorName,
        });
        logId = doc.id;
        //Utils.showSnackbar('Success!');
      } on FirebaseException catch (e) {
        Utils.showSnackbar(e.message);
      }
    }
    return {
      'LogId': logId,
      'PatientDataRequestLogId': patientDataRequestLogId,
    };
  }

  //create 2 futurebuilder, get the 2 ids, then use it for streambuilders to find when it is approved or rejected, if rejected
  //then go back to previous screen with util, if approved, then show the patient record
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _loadData(),
        builder: (context, AsyncSnapshot<Map<String, String>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator(),);
          } else if (snapshot.hasError){
            return const ErrorPage();
          } else {
            Map<String, String> data = snapshot.data!;
            return StreamBuilder(
              stream: firestore.collection('PatientDataRequestLog').doc(data['PatientDataRequestLogId']).collection("Logs").doc(data['LogId']).snapshots(),
              builder: (context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
                if (snapshot.hasError) {
                  return const ErrorPage();
                }
                else if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                else if (snapshot.hasData) {
                  final documentData = snapshot.data!.data();
                  var approvalStatus = documentData!['ApprovalStatus'];
                  if (approvalStatus == ApprovalStatus.approved.name) {
                    return SafeArea(
                      child: Center(
                        child: _confirmationDialog(true)
                      ),
                    );
                  } 
                  else if (approvalStatus == ApprovalStatus.pending.name){
                    return SafeArea(
                      child: Center(
                        child: _confirmationDialog(false)
                      ),
                    );
                  }
                  else if (approvalStatus == ApprovalStatus.failed.name) {
                    return SafeArea(
                      child: Center(
                        child: Column(
                          children: [
                            const Text("Fail to approve"),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              }, 
                              child: const Text("Close")
                            )
                          ],
                        )
                      ),
                    );
                  } else {
                    return SafeArea(
                      child: Center(
                        child: Column(
                          children: [
                            const Text("Rejected"),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              }, 
                              child: const Text("Close")
                            )
                          ],
                        )
                      ),
                    );
                  }
                } else {
                  return const ErrorPage();
                }
              }
            );
          }
        },
      )
    );
  }
}