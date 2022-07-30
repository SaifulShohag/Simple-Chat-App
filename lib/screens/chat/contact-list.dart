import 'package:artist_recruit/Widgets/image-card.dart';
import 'package:artist_recruit/screens/chat/message-input-field.dart';
import 'package:artist_recruit/screens/home-page.dart';
import 'package:artist_recruit/services/datastore-service.dart';
import 'package:artist_recruit/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ContactList extends StatefulWidget {
  final List allUsers;
  ContactList({@required this.allUsers});
  @override
  State<ContactList> createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  final msgController = TextEditingController();
  final searchController = new TextEditingController();
  final dataStoreService = DataStoreService();
  final User currentUser = FirebaseAuth.instance.currentUser;
  List allUsers = [];
  List filteredUsers = [];

  @override
  void initState() {
    super.initState();
    allUsers = widget.allUsers;
    searchController.addListener(() => filterContacts());
    searchController.clear();
  }

  sendMessage(context, User user, otherUser) async {
    preventDoubleTap(context);
    List existingThread = await dataStoreService.getMessageThreadByIDs(user.uid, otherUser['uid']) ?? [];
    Navigator.pop(context);

    showDialog(context: context, builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: EdgeInsets.all(0.0),
        insetPadding: EdgeInsets.all(0.0),
        content: SizedBox(
          width: double.infinity,
          height: 50.0,
          child: MessageInputField(
            msgController: msgController,
            onPressed: () async {
              preventDoubleTap(context);
              if(existingThread.length > 0) {
                await dataStoreService.sendInboxMessage(user.uid, existingThread[0]['id'], rUid: otherUser['uid'],
                message: msgController.text.trim());
              } else if(existingThread.length < 1) {
                await dataStoreService.createMessageThread(context, user, rUid: otherUser['uid'],
                message: msgController.text.trim(), rUsername: otherUser['fullName'], rPhotoURL: otherUser['photoURL']);
              }
              Navigator.popUntil(context, (route) => route.isFirst);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
            },
          ),
        ),
      );
    });
  }

  filterContacts() {
    List _users = [];
    _users.addAll(allUsers);
    if (searchController.text.isNotEmpty) {
      _users.retainWhere((usr) {
        String searchTerm = searchController.text.trim().toLowerCase();
        String contactName = usr['fullName'].toLowerCase();
        return contactName.contains(searchTerm);  
      });

      setState(() {
        filteredUsers = _users;
      });
    } else {
      setState(() {
        filteredUsers = allUsers;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
         SizedBox(height: 20.0, width: double.infinity,),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          height: 40.0,
          child: TextFormField(
            controller: searchController,
            decoration: getInputDecoration(hintText: 'Search', color: Colors.grey[300], borderRadius: 30.0),
          ),
        ),
        SizedBox(height: 30.0,),
        for (var user in filteredUsers) ImageCard(
          bottomMargin: 10.0,
          horizontalPadding: 3.0,
          verticalPadding: 2.0,
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: lightBlackColor,
                radius: 21.0,
                child: CircleAvatar(
                  radius: 20.0,
                  backgroundImage: NetworkImage(user['photoURL']),
                ),
              ), 
              SizedBox(width: 13.0,),
              Text(user['fullName'], style: subheadText,),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(Icons.send, color: primaryColor,),
                    onPressed: () => sendMessage(context, currentUser, user),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}