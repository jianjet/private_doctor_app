import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:doctor_app/user_authentication/login.dart';
import 'package:email_validator/email_validator.dart';
import 'package:doctor_app/utils.dart';
import '../main.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);
  @override
  SignUpState createState() => SignUpState();
}

class SignUpState extends State<SignUp> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final aboutController = TextEditingController();
  final icController = TextEditingController();
  final medIDController = TextEditingController();
  final passwordController = TextEditingController();
  final cpasswordController = TextEditingController();
  final db = FirebaseFirestore.instance;

  void _pushSignIn(){
    Navigator.push(context, MaterialPageRoute(builder: ((context) => const SignIn())));
  }

  @override
  void dispose(){
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    aboutController.dispose();
    icController.dispose();
    medIDController.dispose();
    cpasswordController.dispose();
    super.dispose();
  }

  Widget _email() {
    return TextFormField(
      controller: emailController,
      decoration: const InputDecoration(labelText: 'Email'),
      validator: (String? value) {
        if (value!.isEmpty) {
          return 'Please write your email';
        }
        if (EmailValidator.validate(value)==false){
          return "Please write a valid email";
        }
        return null;
      },
    );
  }

  Widget _name() {
    return TextFormField(
      controller: nameController,
      decoration: const InputDecoration(labelText: 'Name'),
      validator: (String? value) {
        if (value!.isEmpty) {
          return 'Please write your name.';
        }
        return null;
      },
    );
  }

  Widget _about() {
    return TextFormField(
      controller: aboutController,
      decoration: const InputDecoration(labelText: 'Specialisations'),
      validator: (String? value) {
        if (value!.isEmpty) {
          return 'Please write your specialisations.';
        }
        return null;
      },
    );
  }

  Widget _ic() {
    return TextFormField(
      controller: icController,
      decoration: const InputDecoration(labelText: 'IC'),
      validator: (String? value) {
        if (value!.isEmpty) {
          return 'Please write your ic.';
        }
        RegExp numeric = RegExp(r'^[0-9]'); 
        if (numeric.hasMatch(value)==false || value.length<12){
          return "Please enter a valid IC. No dash, no spaces.";
        }
        return null;
      },
    );
  }

  Widget _medID() {
    return TextFormField(
      controller: medIDController,
      decoration: const InputDecoration(labelText: 'Medical ID'),
      validator: (String? value) {
        if (value!.isEmpty) {
          return 'Please write your medical ID.';
        }
        RegExp numeric = RegExp(r'^[0-9]'); 
        if (numeric.hasMatch(value)==false || value.length<5){
          return "Please enter a valid medical ID.";
        }
        return null;
      },
    );
  }

  Widget _password() {
    return TextFormField(
      obscureText: true,
      controller: passwordController,
      decoration: const InputDecoration(labelText: 'Password', errorMaxLines: 2),
      validator: (String? value) {
        RegExp regex = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#$%^&*(),.?":{}|<>_-]).{5,}$');
        if (value!.isEmpty) {
          return 'Please write your password.';
        }
        // if (value.length<6){
        //   return "Please write password more than 6 characters.";
        // }
        if (!regex.hasMatch(value)){
          return "Enter valid password. Password requires minimun 1 uppercase, lowercase, numeric number, special character and minimum of 12 characters in total.";
        }
        return null;
      },
    );
  }

  Widget _cpassword() {
    return TextFormField(
      obscureText: true,
      controller: cpasswordController,
      decoration: const InputDecoration(labelText: 'Confirm Password'),
      validator: (String? value) {
        if (value!.isEmpty) {
          return 'Please rewrite your password. ';
        }
        if (value!=passwordController.text.trim()){
          return "Not match.";
        }
        return null;
      },
    );
  }

  Future _signUp() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    showDialog(
      context: context, 
      builder: (context) => const Center(child: CircularProgressIndicator())
    );
    String about = aboutController.text.trim().toLowerCase();
    List<String> caseSearchList = [];
    String temp = "";
    for (int i = 0; i < about.length; i++) {
      temp = temp + about[i];
      caseSearchList.add(temp);
    }
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(), 
        password: passwordController.text.trim()
      );
      final User? user = FirebaseAuth.instance.currentUser;
      final uid = user!.uid;
      await db.collection('doctor_users').doc(uid).set({
        'Name': nameController.text.trim(),
        'IC': icController.text.trim(),
        'Email': emailController.text.trim(),
        'About': aboutController.text.trim(),
        'doctorSearch': caseSearchList,
        'uid': uid,
        'medID': medIDController.text.trim(),
        'verified_status': false
      });
    } on FirebaseAuthException catch (e){
      Utils.showSnackbar(e.message);
    }
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }

  Widget _signUpButton(){
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.arrow_right_alt, size: 32),
        onPressed: () {
          _signUp();
        },
        label: const Text('Sign Up', style: TextStyle(fontSize: 24))),
      );
  }

  Widget _signin(){
    return TextButton(
      onPressed: () {
        _pushSignIn();
      }, 
      child: const Text("Sign in", style: TextStyle(decoration: TextDecoration.underline),)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Form(
        key: _formKey,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _email(),
              _name(),
              _about(),
              _ic(),
              _medID(),
              _password(),
              _cpassword(),
              _signUpButton(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have account?"),
                  _signin()
                ],
              )
            ],
          ),
        ),
      )
    );
  }
}