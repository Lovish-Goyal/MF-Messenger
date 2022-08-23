import 'package:chat_app/Models/ChatRoomModel.dart';
import 'package:chat_app/Models/UIHelper.dart';
import 'package:chat_app/Models/UserModel.dart';
import 'package:chat_app/Models/firebasehelper.dart';
import 'package:chat_app/pages/ChatRoomPage.dart';
import 'package:chat_app/pages/LoginPage.dart';
import 'package:chat_app/pages/SearchPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final UserModel usermodel;
  final User firebaseuser;
  const HomePage(
      {Key? key, required this.usermodel, required this.firebaseuser})
      : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MF Messenger"),
        actions: [
          IconButton(
              onPressed: ()  {},
              icon: Icon(Icons.notifications)),
               IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) {
                  return LoginPage();
                }));
              },
              icon: Icon(Icons.exit_to_app))
        ],
      ),
      body: SafeArea(
        child: Container(
            child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("chatrooms")
                    .where("participants.${widget.usermodel.uid}",
                        isEqualTo: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      QuerySnapshot chatRoomSnapshot =
                          snapshot.data as QuerySnapshot;

                      return ListView.builder(
                          itemCount: chatRoomSnapshot.docs.length,
                          itemBuilder: (context, index) {
                            ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                                chatRoomSnapshot.docs[index].data()
                                    as Map<String, dynamic>);

                            Map<String, dynamic> participants =
                                chatRoomModel.participants!;

                            List<String> participantkeys =
                                participants.keys.toList();
                            participantkeys.remove(widget.usermodel.uid);

                            return FutureBuilder(
                                future: FirebaseHelper.getUserModelById(
                                    participantkeys[0]),
                                builder: (context, userData) {
                                  if (userData.connectionState ==
                                      ConnectionState.done) {
                                    if (userData.data != null) {
                                      UserModel targetUser =
                                          userData.data as UserModel;
                                      return ListTile(
                                        onTap: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return ChatRoomPage(
                                                targetuser: targetUser,
                                                chatroom: chatRoomModel,
                                                usermodel: widget.usermodel,
                                                firebaseuser:
                                                    widget.firebaseuser);
                                          }));
                                        },
                                        leading: CircleAvatar(
                                             backgroundImage: NetworkImage(
                                                 targetUser.profilepic
                                                     .toString())
                                            ),
                                        title: Text(
                                            targetUser.fullname.toString()),
                                        subtitle: (chatRoomModel.lastMessage
                                                    .toString() !=
                                                "")
                                            ? Text(chatRoomModel.lastMessage
                                                .toString())
                                            : Text(
                                                "Say hi to your new friend",
                                                style: TextStyle(
                                                  color: Colors.blue,
                                                ),
                                              ),
                                      );
                                    } else {
                                      return Container();
                                    }
                                  } else {
                                    return Container();
                                  }
                                });
                          });
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(snapshot.error.toString()),
                      );
                    } else {
                      return Center(
                        child: Text("No chats"),
                      );
                    }
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                })),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return SearchPage(
                usermodel: widget.usermodel, firebaseuser: widget.firebaseuser);
          }));
        },
        child: Icon(Icons.search),
      ),
    );
  }
}

