import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../errorpage.dart';
import 'message.dart';

class PatientList extends StatefulWidget{
  String patient_uid;
  PatientList({Key? key, 
    required this.patient_uid,
  }) : super(key: key);
  @override
  PatientListState createState() => PatientListState();
}

class PatientListState extends State<PatientList> {

  late String _patientName;
  final user = FirebaseAuth.instance.currentUser!;
  final firestore = FirebaseFirestore.instance;
  late String combiID;

  Future<void> _checkIfGroupExists(String groupChatId) async {
    final DocumentReference grpRef = FirebaseFirestore.instance.collection('message_server').doc(groupChatId);
    final DocumentSnapshot snapshot = await grpRef.get();
    if (snapshot.exists==false){
      await firestore.collection('message_server').doc(groupChatId).set({
        'doctor': user.uid,
        'patient': widget.patient_uid
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(border: Border(
        bottom: BorderSide(
          color: Colors.grey,
          width: 0.5
        )
      )),
      child: GestureDetector(
        onTap: (){
          combiID=user.uid+widget.patient_uid;
          _checkIfGroupExists(combiID);
          Navigator.push(context, MaterialPageRoute(builder: ((context) => Message(ChatId: combiID, patient_name: _patientName, ))));
        },
        child: Container(
          padding: const EdgeInsets.only(left: 16,right: 16,top: 10,bottom: 10),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Row(
                  children: <Widget>[
                    const CircleAvatar(
                      backgroundImage: AssetImage('./image/girl_icon.png'),
                      maxRadius: 20,
                    ),
                    const SizedBox(width: 16,),
                    Expanded(
                      child: StreamBuilder<DocumentSnapshot?>(
                        stream: FirebaseFirestore.instance.collection('patient_users').doc(widget.patient_uid).snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          else if (snapshot.hasError){
                            return const ErrorPage();
                          }
                          else {
                            final DocumentSnapshot<Object?>? documentSnapshot = snapshot.data;
                            _patientName = documentSnapshot!['Name'];
                            return Text(_patientName, style: const TextStyle(fontSize: 18));
                          }
                        },
                      )
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}