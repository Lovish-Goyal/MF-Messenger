import 'dart:developer';

import 'package:chat_app/Models/ChatRoomModel.dart';
import 'package:chat_app/Models/UserModel.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/pages/ChatRoomPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  final UserModel usermodel;
  final User firebaseuser;
  const SearchPage(
      {Key? key, required this.usermodel, required this.firebaseuser})
      : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();

  Future<ChatRoomModel?> getChatroomModel(UserModel targetuser) async {
    ChatRoomModel? chatroom;
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .where("participants.${widget.usermodel.uid}", isEqualTo: true)
        .where("participants.${targetuser.uid}", isEqualTo: true)
        .get();

    if (snapshot.docs.length > 0) {
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingChatroom =
          ChatRoomModel.fromMap(docData as Map<String, dynamic>);
      chatroom = existingChatroom;
      log("already");
    } else {
      ChatRoomModel newChatroom = ChatRoomModel(
        chatroomid: uuid.v1(),
        lastMessage: "",
        participants: {
          widget.usermodel.uid.toString(): true,
          targetuser.uid.toString(): true,
        },
      );
      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(newChatroom.chatroomid)
          .set(newChatroom.toMap());
      log("New chatroom created");
      chatroom = newChatroom;
    }
    return chatroom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Search")),
      body: SafeArea(
          child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        child: Column(children: [
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Email address',
            ),
          ),
          SizedBox(
            height: 20,
          ),
          CupertinoButton(
              color: Colors.blue,
              child: Text("Search"),
              onPressed: () {
                setState(() {});
              }),
          SizedBox(
            height: 10,
          ),
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("users")
                .where("email", isEqualTo: searchController.text)
                .where("email", isNotEqualTo: widget.firebaseuser.email)
                .snapshots(),
            builder: ((context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;

                  if (dataSnapshot.docs.length > 0) {
                    Map<String, dynamic> userMap =
                        dataSnapshot.docs[0].data() as Map<String, dynamic>;

                    UserModel searchedUser = UserModel.fromMap(userMap);
                    return ListTile(
                      onTap: (() async {
                        ChatRoomModel? chatroomModel =
                            await getChatroomModel(searchedUser);
                        if (chatroomModel != null) {
                          Navigator.pop(context);
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return ChatRoomPage(
                              chatroom: chatroomModel,
                              firebaseuser: widget.firebaseuser,
                              targetuser: searchedUser,
                              usermodel: widget.usermodel,
                            );
                          }));
                        }
                      }),
                      leading: CircleAvatar(
                       backgroundImage: NetworkImage(searchedUser.profilepic!),
                        backgroundColor: Colors.grey[500],
                      ),
                      title: Text(searchedUser.fullname!),
                      subtitle: Text(searchedUser.email!),
                      trailing: Icon(Icons.keyboard_arrow_right),
                    );
                  } else {
                    return Text("No result found!");
                  }
                } else if (snapshot.hasError) {
                  return Text("An error occured");
                } else {
                  return Text("No results Found");
                }
              } else {
                return CircularProgressIndicator();
              }
            }),
          ),
        ]),
      )),
    );
  }
}
