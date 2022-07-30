import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:artist_recruit/utils/constants.dart';

class MessageBuilder extends StatelessWidget {
  final List chatMessages;
  MessageBuilder({@required this.chatMessages});
  final User user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        padding: EdgeInsets.all(10.0),
        reverse: true,
        children: [
          Column(
            children: [
              for(var msg in chatMessages) Align(
                alignment: msg['sender'] ==  user.uid ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  constraints: BoxConstraints(maxWidth: 300.0),
                  margin: EdgeInsets.symmetric(vertical: 10.0),
                  padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                  decoration: BoxDecoration(
                    color: msg['sender'] ==  user.uid ? Colors.grey[400] : Theme.of(context).primaryColorLight,
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  child: Column(
                    crossAxisAlignment: msg['sender'] ==  user.uid ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        msg['message'],
                        style: messageTextBlack,
                      ),
                      SizedBox(width: 20.0,),
                      Padding(
                        padding: EdgeInsets.only(top: 5.0),
                        child: Text(
                          DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(msg['timeStamp'])).inHours > 23 ?
                          DateTime.fromMillisecondsSinceEpoch(msg['timeStamp']).toIso8601String().split('T')[0] :
                          DateTime.fromMillisecondsSinceEpoch(msg['timeStamp']).toIso8601String().split('T')[1]
                          .split('.')[0].substring(0, 5),
                          style: messageDateText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}