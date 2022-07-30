import 'package:artist_recruit/screens/chat/chat-inbox-screen.dart';
import 'package:artist_recruit/screens/chat/message-thread-row.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:artist_recruit/services/datastore-service.dart';
import 'package:artist_recruit/utils/constants.dart';

class MessageThreadsScreen extends StatefulWidget {
  @override
  _MessageThreadsScreenState createState() => _MessageThreadsScreenState();
}

class _MessageThreadsScreenState extends State<MessageThreadsScreen> {
  final TextEditingController searchController = new TextEditingController();
  final dataStoreService = DataStoreService();
  final User user = FirebaseAuth.instance.currentUser;
  List threadList = [];
  List threadsFiltered = [];

  @override
  void initState() {
    getThreadList();
    searchController.addListener(() => filterContacts());
    super.initState();
  }


  getThreadList() async {
    searchController.clear();
    List list = await dataStoreService.getUserMessageThreadList(context, user) ?? [];
    list.sort((a, b) => b['lastMessage']['timeStamp'].compareTo(a['lastMessage']['timeStamp']));
    setState(() {
      threadList = list;
      threadsFiltered = list;
    });
  }
  
  filterContacts() {
    List _threads = [];
    _threads.addAll(threadList);
    if (searchController.text.isNotEmpty) {
      _threads.retainWhere((thread) {
        String searchTerm = searchController.text.trim().toLowerCase();
        String contactName = thread['user1']['uid'] == user.uid ? thread['user2']['username'].toLowerCase() : thread['user1']['username'].toLowerCase();
        return contactName.contains(searchTerm);  
      });

      setState(() {
        threadsFiltered = _threads;
      });
    } else {
      setState(() {
        threadsFiltered = threadList;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, threadList);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Messages', style: titleText,),
        ),
        body: Padding(
          padding: EdgeInsets.only(top: 10.0, bottom: 20.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20.0,),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  height: 40.0,
                  child: TextFormField(
                    controller: searchController,
                    decoration: getInputDecoration(hintText: 'Search', color: Colors.grey[300], borderRadius: 30.0),
                  ),
                ),
                SizedBox(height: 20.0,),
                for(var thread in threadsFiltered) GestureDetector(
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
        ),
      ),
    );
  }
}