import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../user_authentication/utils.dart';

class AppointmentList extends StatefulWidget {
  String patient_name;
  String service;
  String appointment_date;
  String appointment_time;
  bool booking_status;
  String document_id;
  String doctor_name;
  AppointmentList({
    required this.patient_name,
    required this.service,
    required this.appointment_date,
    required this.appointment_time,
    required this.booking_status,
    required this.document_id,
    required this.doctor_name,
    Key? key
    }) : super(key: key);

  @override
  State<AppointmentList> createState() => AppointmentListState();
}

class AppointmentListState extends State<AppointmentList> {

  final firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;

  Future _appointmentConfirmed() async {
    try {
      await firestore.collection('appointment_server').doc(widget.document_id).update({
        'rated': false,
        'booking_status': true,
        'doctor_name': widget.doctor_name, 
        'doctor_uid': user!.uid
      });
    } on FirebaseException catch (e){
      Utils.showSnackbar(e.message);
    }
  }

  Future _appointmentCompleted() async {
    try {
      await firestore.collection('appointment_server').doc(widget.document_id).update({
        'booking_status': FieldValue.delete(),
        'complete_status': true
      });
    } on FirebaseException catch (e){
      Utils.showSnackbar(e.message);
    }
  }

  // Future _appointmentCancel() async {
  //   try {
  //     QuerySnapshot snapshot = await firestore.collection('goals_server')
  //       .doc(user!.uid)
  //       .collection('ongoing')
  //       .where('goal_set_time', isEqualTo: widget.goalSetTime)
  //       .get();
  //     List<DocumentSnapshot> docs = snapshot.docs;
  //     for (DocumentSnapshot doc in docs) {
  //       await doc.reference.delete();
  //     }
  //   } on FirebaseException catch (e){
  //     Utils.showSnackbar(e.message);
  //   }
  // }

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
          
        },
        child: Container(
          padding: const EdgeInsets.only(left: 5,right: 16,top: 10,bottom: 10),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Row(
                  children: <Widget>[
                    const CircleAvatar(
                      backgroundImage: AssetImage('./image/girl_icon.png'),
                      maxRadius: 30,
                    ),
                    const SizedBox(width: 16,),
                    Expanded(
                      child: Container(
                        color: Colors.transparent,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(widget.patient_name, style: const TextStyle(fontSize: 16),),
                            const SizedBox(height: 4),
                            Text(widget.service,style: TextStyle(fontSize: 13,color: Colors.grey.shade600, fontWeight: FontWeight.normal),),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(widget.appointment_date,style: TextStyle(fontSize: 13,color: Colors.grey.shade600, fontWeight: FontWeight.normal),),
                                const SizedBox(width: 10),
                                Text(widget.appointment_time,style: TextStyle(fontSize: 13,color: Colors.grey.shade600, fontWeight: FontWeight.normal),),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    if (widget.booking_status==true) ... [
                      TextButton(
                        style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.blue)),
                        onPressed: (){
                          _appointmentCompleted();
                        }, 
                        child: const Text('Done', style: TextStyle(fontSize: 15, color: Colors.white))
                      ),
                    ]
                    else ... [
                      TextButton(
                        onPressed: (){
                          _appointmentConfirmed();
                        }, 
                        child: const Icon(Icons.check, size: 50, color: Colors.green,)
                      ),
                      // const SizedBox(width: 10),
                      // TextButton(
                      //   onPressed: (){
                      //     // _appointmentCancel();
                      //   }, 
                      //   child: const Icon(Icons.close_rounded, size: 50, color: Colors.red,)
                      // )
                    ]
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