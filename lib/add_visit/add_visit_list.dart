import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../errorpage.dart';
import 'add_visit.dart';

class AddVisitList extends StatefulWidget{
  String patient_uid;
  AddVisitList({Key? key, 
    required this.patient_uid,
  }) : super(key: key);
  @override
  AddVisitListState createState() => AddVisitListState();
}

class AddVisitListState extends State<AddVisitList> {

  late String _patientName;
  final user = FirebaseAuth.instance.currentUser!;
  final firestore = FirebaseFirestore.instance;

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
          //change here
          Navigator.push(context, MaterialPageRoute(builder: ((context) => AddVisit(patient_uid: widget.patient_uid,))));
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