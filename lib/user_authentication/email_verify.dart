import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_app/user_authentication/admin_verify.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:doctor_app/navbar.dart';
import 'package:doctor_app/user_authentication/utils.dart';

class EmailVerify extends StatefulWidget {
  const EmailVerify({Key? key}) : super(key: key);
  @override
  EmailVerifyState createState() => EmailVerifyState();
}

class EmailVerifyState extends State<EmailVerify> {

  bool isEmailVerified = false;
  Timer? timer;
  bool canResendEmail = false;
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState(){
    super.initState();
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    if (isEmailVerified==false){
      sendVerificationEmail();
    }
    timer=Timer.periodic(const Duration(seconds: 3),
    (_) {
      checkEmailVerified();
    });
  }

  @override
  void dispose(){
    timer?.cancel();
    super.dispose();
  }

  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });
    if (isEmailVerified==true){
      timer?.cancel();
    }
  }

  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      setState(() {
        canResendEmail=false;
      });
      await Future.delayed(const Duration(minutes: 1));
      setState(() {
        canResendEmail=true;
      });
    } catch (e) {
      Utils.showSnackbar(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isEmailVerified==false) {
      return Scaffold(
          appBar: AppBar(
          title: const Text('Email Verification'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text("A verification email has been sent to this email.", textAlign: TextAlign.center, style: TextStyle(fontSize: 18),),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.email, size: 32), 
                label: const Text("Resend Email", style: TextStyle(fontSize: 24)),
                onPressed: canResendEmail ? () async {sendVerificationEmail();} : null
              ),
              TextButton(
                onPressed: (){
                  FirebaseAuth.instance.signOut();
                }, 
                child: const Text("Cancel", style: TextStyle(fontSize: 24))
              )
            ],
          ),
        )
      );
    } 
    else {
      return const AdminVerify();
    }
  }
}