import 'package:flutter/material.dart';

class Others extends StatefulWidget {
  const Others({Key? key}) : super(key: key);
  @override
  OthersState createState() => OthersState();
}

class OthersState extends State<Others> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Others'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              
            ],
          ),
        ),
      )
    );
  }
}