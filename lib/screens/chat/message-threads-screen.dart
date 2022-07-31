import 'package:artist_recruit/listeners/threadNotifier.dart';
import 'package:artist_recruit/screens/chat/chat-inbox-screen.dart';
import 'package:artist_recruit/screens/chat/message-thread-row.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:artist_recruit/services/datastore-service.dart';

class MessageThreadsScreen extends StatefulWidget {
  @override
  _MessageThreadsScreenState createState() => _MessageThreadsScreenState();
}

class _MessageThreadsScreenState extends State<MessageThreadsScreen> {
  final dataStoreService = DataStoreService();
  final User user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    getThreadList();
    super.initState();
  }

  getThreadList() async {
    List list = await dataStoreService.getUserMessageThreadList(user) ?? [];
    list.sort((a, b) => b['lastMessage']['timeStamp'].compareTo(a['lastMessage']['timeStamp']));
    context.read<ThreadNotifier>().updateValue(list);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            if(context.watch<ThreadNotifier>().threadList.isEmpty) Center(
              child: Text(
                "You haven't added any user yet. Please click on the \"+\" button to start chatting.",
                textAlign: TextAlign.center,
              ),
            ),
            for(var thread in context.watch<ThreadNotifier>().threadList ?? []) GestureDetector(
              onTap: () {
                dataStoreService.messageBeingSeen(context, user, thread);
                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => 
                ChatInboxScreen(otherUser: thread['user1']['uid'] == user.uid ? 
                thread['user2'] : thread['user1'], threadID: thread['id'])))
                .then((_) {
                  getThreadList();
                  FocusScope.of(context).requestFocus(new FocusNode());
                });
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
        ),
      ),
    );
  }
}