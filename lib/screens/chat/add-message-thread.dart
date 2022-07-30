import 'package:artist_recruit/Widgets/user-list.dart';
import 'package:artist_recruit/services/datastore-service.dart';
import 'package:artist_recruit/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddMessageThread extends StatelessWidget {
  final dataStoreService = DataStoreService();
  final User user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: Text('Add Thread', style: titleTextWhite),
        ),
      ),
      body: FutureBuilder(
        future: dataStoreService.getAllUsers(),
        builder: (context, snapshot) {
          if(snapshot.hasData && snapshot.data != null) {
            List allUsers = snapshot.data;
            allUsers = allUsers.where((el) => el['uid'] != user.uid).toList();
            return SingleChildScrollView(
              child: Center(
                child: UserList(allUsers: allUsers)
              ),
            );
          }
          return Center(child: CircularProgressIndicator());
        }
      ),
    );
  }
}