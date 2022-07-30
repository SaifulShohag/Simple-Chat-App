import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:artist_recruit/utils/constants.dart';

class MessageThreadRow extends StatelessWidget {
  final String username;
  final String imgUrl;
  final String userType;
  final String lastMessage;
  final String lastMessageSender;
  final String msDate;
  final bool seen;
  MessageThreadRow({@required this.username, @required this.userType, @required this.lastMessage,
       @required this.msDate, @required this.seen, @required this.imgUrl, @required this.lastMessageSender});
  
  final User user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: lightBlackColor, width: 2.0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: CircleAvatar(
              radius: 30.0,
              backgroundImage: NetworkImage(imgUrl),
              // onBackgroundImageError: (_, __) async {
              //   var userArt = await dataStoreService.getUserArtsDataByUid(context, ua['likedUID']);
              //   dataStoreService.updateLikedUsersPhotoURL(docID: ua['id'], key: 'likedPhotoURL', photoURL: userArt['photoURL']);
              //   setState(() => photoUrl = userArt['photoURL']);
              // },
            ),
          ),
          Expanded(
            flex: 3,
            child: Wrap(
              direction: Axis.vertical,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 17.0),
                  child: Text(username, style: subheadText),
                ),
                // Text(userType, style: smallText),
                SizedBox(height: 3.0,),
                Text(lastMessage, style: seen || user.uid == lastMessageSender ? messageText : messageTextBold,)
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 17.0, right: 10.0),
              child: Text('⌚ $msDate', style: smallText,),
            ),
          ),
        ],
      ),
    );
  }
}