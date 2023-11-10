import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_app/classes_enums_dicts/patient_health_record.dart';
import 'package:doctor_app/classes_enums_dicts/roles_enum.dart';
import 'package:doctor_app/scan_qr/encryption.dart';
import 'package:doctor_app/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simple_rsa3/simple_rsa3.dart';

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
  AESEncryptionForPatientId encryptionPatientId = AESEncryptionForPatientId();
  SimpleRsa3 simpleRsa3 = SimpleRsa3();

  void _confirmationDialog(String patientDataRequestLogId, String logId){
    WidgetsBinding.instance.addPostFrameCallback((_){
      showDialog(barrierDismissible: false, context: context, builder: (context) {
        return StreamBuilder(
          stream: firestore.collection('PatientDataRequestLog').doc(patientDataRequestLogId).collection("Logs").doc(logId).snapshots(),
          builder: (context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
            String approvalStatus = ApprovalStatus.pending.name;
            if (snapshot.hasError) {
              return const ErrorPage();
            }
            else if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            else if (snapshot.hasData) {
              final documentData = snapshot.data!.data();
              approvalStatus = documentData!['ApprovalStatus'];
            }
            String textForContent = "";
            if (approvalStatus == ApprovalStatus.approved.name) {
              textForContent = 'Approved!';
            } else if (approvalStatus == ApprovalStatus.pending.name) {
              textForContent = '';
            } else if (approvalStatus == ApprovalStatus.rejected.name) {
              textForContent = 'Rejected!';
            } else {
              textForContent = 'Failed!';
            }
            return AlertDialog(
              title: const Text('Waiting for approval...'),
              content: Text(textForContent),
              actions: [
                if (approvalStatus == ApprovalStatus.approved.name) ... [
                  Center(
                    child: ElevatedButton(
                      onPressed: (){
                        Navigator.of(context).pop();
                      }, 
                      child: const Text("Ok")
                    ),
                  )
                ] else if (approvalStatus == ApprovalStatus.pending.name) ... [
                  const Center(child: CircularProgressIndicator(),)
                ] else ... [
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      }, 
                      child: const Text("Close")
                    ),
                  )
                ]
              ],
            );
          }
        );
      });
    });
  }

  Future<Map<String, String>> _loadData(String patientId) async {
    String patientDataRequestLogId = "";
    String logId = "";
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

  Future<String> _loadPatientHealthRecord(String patientDataRequestLogId) async {
    final DocumentSnapshot document = await firestore.collection('PatientDataRequestLog').doc(patientDataRequestLogId).get();
    final data = document.data() as Map<String, dynamic>;
    String encryptedSymmetricKey = data['EncryptedSymmetricKey'];
    final DocumentSnapshot doctorDocument = await firestore.collection('doctor_users').doc(user!.uid).get();
    final doctorData = doctorDocument.data() as Map<String, dynamic>;
    String doctorPrivateKey = doctorData['PrivateKey'];
    final decryptedText = await simpleRsa3.decryptString(encryptedSymmetricKey, doctorPrivateKey) ?? '';
    AESEncryptionForPatientHealthRecords decryptionPatientHealthRecords = AESEncryptionForPatientHealthRecords(decryptedText);
    decryptionPatientHealthRecords.initializeEncrypter();
    final DocumentSnapshot healthRecordDoc = await firestore.collection('PatientsHealthRecord').doc(data['PatientId']).get();
    final healthRecordData = healthRecordDoc.data() as Map<String, dynamic>;
    String encryptedHealthRecord = healthRecordData['EncryptedJsonData'];
    String healthRecord = decryptionPatientHealthRecords.decryptMsg(decryptionPatientHealthRecords.getCode(encryptedHealthRecord)).toString();
    return healthRecord;
  }

  Widget _patientHealthRecordDecrypted(String patientDataRequestLogId) {
    return FutureBuilder(
      future: _loadPatientHealthRecord(patientDataRequestLogId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting){
          return const Center(child: CircularProgressIndicator(),);
        } else if (snapshot.hasError){
          return const ErrorPage();
        } else {
          String healthRecord = snapshot.data as String;
          Map<String, dynamic> jsonData = json.decode(healthRecord);
          BasicInfo basicInfo = BasicInfo.fromJson(jsonData);
          return SingleChildScrollView(
            child: Column(
              children: [
                Text('Name: ${basicInfo.name}'),
                Text('Age: ${basicInfo.age.toString()}'),
                Text('Gender: ${basicInfo.gender}'),
                Text('Height: ${basicInfo.height.toString()}'),
                Text('Weight: ${basicInfo.weight.toString()}'),
                Text('BMI: ${basicInfo.bmi.toString()}'),
                Text('Ethnicity: ${basicInfo.ethnic}'),
                Text('IC Number: ${basicInfo.icNo}'),
              ],
            ),
          );
        }
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    String patientId = encryptionPatientId.decryptMsg(encryptionPatientId.getCode(widget.encryptedPatientId)).toString();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient\'s Data'),
        leading: BackButton(
          onPressed: () async {
            final QuerySnapshot querySnapshot = await firestore.collection('PatientDataRequestLog').where('PatientId', isEqualTo: patientId).get();
            if (querySnapshot.docs.isNotEmpty) {
              final DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
              final DocumentReference docRef = documentSnapshot.reference;
              String patientDataRequestLogId = docRef.id;
              final DocumentReference document = firestore.collection('PatientDataRequestLog').doc(patientDataRequestLogId);
              try {
                await document.update({
                  "EncryptedSymmetricKey": FieldValue.delete(),
                });
                //Utils.showSnackbar('Success!');
              } on FirebaseException catch (e) {
                Utils.showSnackbar(e.message);
              }
            }
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder(
        future: _loadData(patientId),
        builder: (context, AsyncSnapshot<Map<String, String>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator(),);
          } else if (snapshot.hasError){
            return const ErrorPage();
          } else {
            Map<String, String> data = snapshot.data!;
            _confirmationDialog(data['PatientDataRequestLogId']!, data['LogId']!);
            return StreamBuilder(
              stream: firestore.collection('PatientDataRequestLog').doc(data['PatientDataRequestLogId']).collection("Logs").doc(data['LogId']).snapshots(),
              builder: (context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
                String approvalStatus = ApprovalStatus.pending.name;
                if (snapshot.hasError) {
                  return const ErrorPage();
                }
                else if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                else if (snapshot.hasData) {
                  final documentData = snapshot.data!.data();
                  approvalStatus = documentData!['ApprovalStatus'];
                }
                if (approvalStatus == ApprovalStatus.rejected.name || approvalStatus == ApprovalStatus.failed.name){
                  return const SafeArea(
                    child: Center(
                      child: Text("Request rejected or failed, please press the back button to go back to the previous screen.")
                    ),
                  );
                } else if (approvalStatus == ApprovalStatus.pending.name){
                  return SafeArea(
                    child: Center(
                      child: Container()
                    ),
                  );
                } else {
                  //put a futurebuilder here
                  return _patientHealthRecordDecrypted(data['PatientDataRequestLogId']!);
                }
              }
            );
          }
        },
      )
    );
  }
}