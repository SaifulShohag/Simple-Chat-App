import 'package:artist_recruit/screens/chat/chat-inbox-screen.dart';
import 'package:artist_recruit/screens/chat/message-thread-row.dart';
import 'package:artist_recruit/services/datastore-service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MessageThreadsScreen extends StatelessWidget {
  final User user = FirebaseAuth.instance.currentUser;
  final dataStoreService = DataStoreService();

  Stream<List> getThreadList() async* {
    var threadList = await dataStoreService.getUserMessageThreadList(user);
    yield threadList;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
      child: SingleChildScrollView(
        child: StreamBuilder(
          stream: getThreadList(),
          builder: (context, snapshot) {
            if(snapshot.hasData && !snapshot.hasError ) {
              var thread = snapshot.data ?? [];
              var userThreads = [...thread];    
              userThreads.sort((a, b) => b['lastMessage']['timeStamp'].compareTo(a['lastMessage']['timeStamp']));
              return Column(
                children: [
                  if(userThreads.isEmpty) Center(
                    child: Text(
                      "You haven't added any user yet. Please click on the \"+\" button to start chatting.",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  for(var thread in userThreads) GestureDetector(
                    onTap: () {
                      dataStoreService.messageBeingSeen(context, user, thread);
                      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => 
                      ChatInboxScreen(otherUser: thread['user1']['uid'] == user.uid ? 
                      thread['user2'] : thread['user1'], threadID: thread['id'])));
                    },
                    child: MessageThreadRow(
                      username: thread['user1']['uid'] == user.uid ? thread['user2']['username'] : thread['user1']['username'],
                      userType: 'Regular',
                      imgUrl: thread['user1']['uid'] == user.uid ? thread['user2']['photoURL'] : thread['user1']['photoURL'],
                      lastMessage: thread['lastMessage']['message'],
                      lastMessageSender: thread['lastMessage']['sender'],
                      msDate: DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(thread['lastMessage']['timeStamp'])).inHours > 23 ?
                      DateTime.fromMillisecondsSinceEpoch(thread['lastMessage']['timeStamp']).toIso8601String().split('T')[0] :
                      DateTime.fromMillisecondsSinceEpoch(thread['lastMessage']['timeStamp']).toIso8601String().split('T')[1]
                      .split('.')[0].substring(0, 5),
                      seen: thread['lastMessage']['seen'],
                    ),
                  ),
                  SizedBox(height: 10.0),
                ],
              );
            }
            else if (snapshot.hasError) {
              print(snapshot.error);
              return Center(child: Text('Something went wrong'));
            }
            else {
              return Center(child: Text("Loading..."));
            }
          }
        ),
      ),
    );
  }
}