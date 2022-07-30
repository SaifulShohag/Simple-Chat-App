import 'package:artist_recruit/Widgets/app-top-bar.dart';
import 'package:artist_recruit/screens/chat/add-message-thread.dart';
import 'package:artist_recruit/screens/chat/message-threads-screen.dart';
import 'package:artist_recruit/screens/newUsersNameImage.dart';
import 'package:artist_recruit/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final User user = FirebaseAuth.instance.currentUser;
  
  @override
  Widget build(BuildContext context) {
    if(user.photoURL == null || user.displayName == '') {
      return NewUsersNameImage();
    }
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(55.0),
        child: AppTopBar(user: user), 
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddMessageThread())),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: MessageThreadsScreen(),
      ),
    );
  }
}