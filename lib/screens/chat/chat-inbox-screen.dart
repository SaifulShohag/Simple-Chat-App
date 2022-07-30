import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:artist_recruit/screens/chat/message-builder.dart';
import 'package:artist_recruit/screens/chat/message-input-field.dart';
import 'package:artist_recruit/screens/chat/msg-app-bar.dart';
import 'package:artist_recruit/services/datastore-service.dart';

class ChatInboxScreen extends StatelessWidget {
  final otherUser;
  final String threadID;
  ChatInboxScreen({@required this.otherUser, @required this.threadID});

  final msgController = TextEditingController();
  final dataStoreService = DataStoreService();
  final User user = FirebaseAuth.instance.currentUser;
  final CollectionReference inboxMessageCollection = FirebaseFirestore.instance.collection('inboxMessages');


  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(148.0), 
        child: MsgAppBar(
          uid: otherUser['uid'], username: otherUser['username'], 
          imgUrl: otherUser['photoURL'] ?? 'https://qph.fs.quoracdn.net/main-qimg-2b21b9dd05c757fe30231fac65b504dd',
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          StreamBuilder(
            stream: inboxMessageCollection.where('threadID', isEqualTo: threadID).orderBy('timeStamp').snapshots(),
            builder: (context, snapshot) {
              if(snapshot.hasData && !snapshot.hasError ) {
                var data = snapshot.data.docs ?? [];
                return MessageBuilder(chatMessages: data);
              }
              else if (snapshot.hasError) {
                print(snapshot.error);
                return Center(child: Text('Something went wrong'));
              }
              else if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: Text("Loading..."));
              }
              return Center();
            }
          ),
          Container(
            padding: const EdgeInsets.only(left: 5.0, bottom: 5.0, top: 5.0),
            color: Colors.grey[300],
            child: MessageInputField(
              msgController: msgController,
              onPressed: () async {
                if(msgController.text.trim().isNotEmpty) {
                  await dataStoreService.sendInboxMessage(user, threadID, message: msgController.text.trim(), rUid: otherUser['uid']);
                  msgController.clear();
                  FocusScope.of(context).requestFocus(new FocusNode());
                }
              },
            ),
          ), 
        ],
      ),
    );
  }
}