import 'dart:developer';
import 'package:chat_app/Models/ChatRoomModel.dart';
import 'package:chat_app/Models/MessageModel.dart';
import 'package:chat_app/Models/UserModel.dart';
import 'package:chat_app/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatRoomPage extends StatefulWidget {
  final UserModel targetuser;
  final ChatRoomModel chatroom;
  final UserModel usermodel;
  final User firebaseuser;
  const ChatRoomPage(
      {Key? key,
      required this.targetuser,
      required this.chatroom,
      required this.usermodel,
      required this.firebaseuser})
      : super(key: key);

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  TextEditingController messageController = TextEditingController();

  void sendMessage() async {
    String msg = messageController.text.trim();
    messageController.clear();

    if (msg != "") {
      MessageModel newMessage = MessageModel(
        messageid: uuid.v1(),
        sender: widget.usermodel.uid,
        createdon: DateTime.now(),
        text: msg,
        seen: false,
      );

      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .collection("messages")
          .doc(newMessage.messageid)
          .set(newMessage.toMap());
     widget.chatroom.lastMessage = msg;
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .set(widget.chatroom.toMap());
      log("Message sent!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey,
               backgroundImage:
                  NetworkImage(widget.targetuser.profilepic.toString()),
            ),
            SizedBox(
              height: 20,
            ),
            Text(widget.targetuser.fullname.toString())
          ],
        ),
      ),
      body: SafeArea(
          child: Container(
        child: Column(
          children: [
            //this is the area where chats will go
            Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10
                  ),
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("chatrooms")
                    .doc(widget.chatroom.chatroomid)
                    .collection("messages")
                    .orderBy("createdon",descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      log("7");
                      QuerySnapshot dataSnapshot =
                          snapshot.data as QuerySnapshot;

                      return ListView.builder(
                        reverse: true,
                        itemCount: dataSnapshot.docs.length,
                        itemBuilder: (context, index) {
                          MessageModel currentMessage = MessageModel.fromMap(
                              dataSnapshot.docs[index].data()
                                  as Map<String, dynamic>);
                          return Row(
                            mainAxisAlignment: (currentMessage.sender == widget.usermodel.uid) ? MainAxisAlignment.end : MainAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 10,
                                ),
                                margin: EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color:  (currentMessage.sender == widget.usermodel.uid) ? Colors.grey : Colors.blueAccent,
                                  borderRadius: BorderRadius.circular(10)
                                ),
                                child: Text(
                                  currentMessage.text.toString(),
                                  style: TextStyle(
                                    color: Colors.white ),)),
                            ],
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                            "An error occured please check your internet connection"),
                      );
                    } else {
                      return Center(
                        child: Text("Say hi to your friend"),
                      );
                    }
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            )),

            Container(
                color: Colors.grey[200],
                padding: EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 5,
                ),
                child: Row(children: [
                  Flexible(
                      child: TextField(
                    maxLines: null,
                    controller: messageController,
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: 'Enter Message'),
                  )),
                  IconButton(
                    onPressed: () {
                      sendMessage();
                    },
                    icon: Icon(Icons.send),
                    color: Colors.blue,
                  )
                ]))
          ],
        ),
      )),
    );
  }
}
