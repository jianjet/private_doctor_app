import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_app/navbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminVerify extends StatefulWidget {
  const AdminVerify({Key? key}) : super(key: key);
  @override
  AdminVerifyState createState() => AdminVerifyState();
}

class AdminVerifyState extends State<AdminVerify> {

  final User? user = FirebaseAuth.instance.currentUser;
  late bool verified;

  @override
  void initState() {
    super.initState();
  }

  Future <void> adminVerify() async {

  }
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('doctor_users').doc(user!.uid).snapshots(),
      builder: (context, snapshot) {
        
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        // else if (!snapshot.hasData) {
        //   return const Text('No user found, ask admins for help.');
        // }
        else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        else {
          final DocumentSnapshot<Object?>? documentSnapshot = snapshot.data;
          final bool value = documentSnapshot!['verified_status'];
          if (value==false){
            return Scaffold(
              appBar: AppBar(
                title: const Text('Admin Verification'),
              ),
              body: const SafeArea(
                child: Text(
                  'Please wait for admin to verify you.'
                ),
              )
            );
          }
          else {
            return const NavBar();
          }
        }
      }
    );
  }
}