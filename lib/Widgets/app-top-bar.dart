import 'package:artist_recruit/listeners/fileNotifier.dart';
import 'package:artist_recruit/listeners/threadNotifier.dart';
import 'package:artist_recruit/listeners/userListNotifier.dart';
import 'package:artist_recruit/screens/home-page.dart';
import 'package:artist_recruit/screens/user-profile-screen.dart';
import 'package:artist_recruit/services/datastore-service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:artist_recruit/services/authencation-service.dart';
import 'package:artist_recruit/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:artist_recruit/main.dart';
import 'package:provider/provider.dart';

class AppTopBar extends StatelessWidget {
  final User user;
  AppTopBar({this.user});
  final authService = AuthenticationService(FirebaseAuth.instance);
  final dataStoreService = DataStoreService();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 55.0,
      titleSpacing: 7.0,
      title: Padding(
        padding: const EdgeInsets.only(top: 5.0),
        child: Text(user.displayName.toUpperCase().split(' ')[0], style: subtitleBoldWhiteText,),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 5.0, bottom: 1.0,),
        child: CircleAvatar(
          backgroundColor: lightBlackColor,
          child: CircleAvatar(
            radius: 24.0,
            backgroundImage: NetworkImage(user.photoURL),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.refresh,
          ), 
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
          },
        ),
        IconButton(
          icon: Icon(
            Icons.person_sharp,
          ), 
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfileScreen()));
          },
        ),
        IconButton(
          icon: Icon(
            Icons.login_outlined,
          ), 
          onPressed: () async {
            await authService.signOut();
            context.read<ThreadNotifier>().setValue = [];
            context.read<ImageFileNotifier>().setValue = null;
            context.read<UserListNotifier>().setValue = [];
            Navigator.popUntil(context, (route) => route.isFirst);
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AuthenticationWrapper()));
          },
        ),
      ],
    );
  }
}