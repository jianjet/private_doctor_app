import 'dart:developer';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_app/chat/call/pages/call.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'message_tile.dart';

class Message extends StatefulWidget {
  String ChatId;
  String patient_name;
  Message({
    required this.ChatId,
    required this.patient_name,
    Key? key
  }) : super(key: key);
  @override
  MessageState createState() => MessageState();
}

class MessageState extends State<Message> {

  Stream<QuerySnapshot>? _chats;
  TextEditingController _messageController = TextEditingController();
  final CollectionReference messageServerCollection = FirebaseFirestore.instance.collection("message_server");
  final user = FirebaseAuth.instance.currentUser!;
  late String name;

  @override
  void initState(){
    _getChat();
    super.initState();
  }

  _getChatsForDoctor(String groupId) async {
    return messageServerCollection
      .doc(groupId)
      .collection("messages")
      .orderBy("time", descending: true)
      .snapshots();
  }

  void _getChat(){
    _getChatsForDoctor(widget.ChatId).then((val){
      setState(() {
        _chats=val;
      });
    });
  }

  Future<void> _onJoin(String combiID) async {
    await _handleCameraAndMic(Permission.camera);
    await _handleCameraAndMic(Permission.microphone);
    await Navigator.push(context, MaterialPageRoute(builder: ((context) => Call(channelName: combiID, role: ClientRole.Broadcaster))));
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    log(status.toString()); //see whether the request is allowed or not
  }

  PreferredSizeWidget _customAppBar(){
    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.blue[100],
      actions: [
        IconButton(
          onPressed: (){
            _onJoin('telemed');
          }, 
          icon: const Icon(Icons.call)
        )
      ],
      flexibleSpace: SafeArea(
        child: Container(
          padding: const EdgeInsets.only(right: 16),
          child: Row(
            children: <Widget>[
              IconButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back,color: Colors.black,),
              ),
              const SizedBox(width: 2,),
              const CircleAvatar(
                backgroundImage: AssetImage("./image/girl_icon.png"),
                maxRadius: 20,
              ),
              const SizedBox(width: 12,),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(widget.patient_name,style: const TextStyle( fontSize: 16 ,fontWeight: FontWeight.w600),),
                    const SizedBox(height: 6,),
                    //Text("Online",style: TextStyle(color: Colors.grey.shade600, fontSize: 13),),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _type(){
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.grey[100]
        ),
        padding: const EdgeInsets.only(left: 10,bottom: 10,top: 10),
        height: 60,
        width: double.infinity,
        child: Row(
          children: <Widget>[
            // GestureDetector(
            //   onTap: (){
            //     Navigator.push(context, MaterialPageRoute(builder: ((context) => const Others())));
            //   },
            //   child: Container(
            //     height: 30,
            //     width: 30,
            //     decoration: BoxDecoration(
            //       color: Colors.lightBlue,
            //       borderRadius: BorderRadius.circular(30),
            //     ),
            //     child: const Icon(Icons.add, color: Colors.white, size: 20, ),
            //   ),
            // ),
            const SizedBox(width: 15,),
            Expanded(
              child: TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: "Write message...",
                  hintStyle: TextStyle(color: Colors.black54),
                  border: InputBorder.none
                ),
              ),
            ),
            const SizedBox(width: 15,),
            FloatingActionButton(
              onPressed: (){
                _sendMessage();
              },
              backgroundColor: Colors.blue,
              elevation: 0,
              child: const Icon(Icons.send,color: Colors.white,size: 18,),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chatList(){
    //add smtg here
    // String cdate;
    // String pdate='dd/MM/yyyy';
    // bool dateChangedHere;
    return Column(
      children: [
        Expanded(
          child: StreamBuilder(
            stream:  _chats,
            builder: (context, AsyncSnapshot snapshot){
              return snapshot.hasData 
              ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                reverse: true,
                itemBuilder: (context, index) {
                  // cdate = DateFormat('dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(snapshot.data.docs[index]['time']));
                  // if (pdate==cdate) {
                  //   dateChangedHere=false;
                  // }
                  // else {
                  //   dateChangedHere=true;
                  //   pdate=cdate;
                  // }
                  return MessageTile(
                    message: snapshot.data.docs[index]['message'], 
                    sender_uid: snapshot.data.docs[index]['sender'],
                    sentByMe: user.uid==snapshot.data.docs[index]['sender'],
                    ChatId: widget.ChatId,
                    time: snapshot.data.docs[index]['time'],
                    //dateChanged: dateChangedHere,
                  );
                },
              )
              : Container();
            }
          )
        ),
        const SizedBox(
          height: 80,
        )
      ],
    );
  }

  _sendMessageToServer(String groupId, Map<String, dynamic> chatMessageData) async {
    messageServerCollection.doc(groupId).collection("messages").add(chatMessageData);
  }

  _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": _messageController.text,
        "sender": user.uid,
        "time": DateTime.now().millisecondsSinceEpoch,
      };

      _sendMessageToServer(widget.ChatId, chatMessageMap);
      setState(() {
        _messageController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _customAppBar(),
      body: Stack(
        children: [
          _chatList(),
          _type()
        ],
      )
    );
  }
}