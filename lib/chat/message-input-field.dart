import 'package:flutter/material.dart';
import 'package:artist_recruit/utils/constants.dart';

class MessageInputField extends StatelessWidget {
  final TextEditingController msgController;
  final Function onPressed;
  MessageInputField({@required this.msgController, @required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 0.0),
      color: Colors.grey[300],
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 45.0,
              child: TextFormField(
                controller: msgController,
                decoration: getInputDecoration(hintText: 'Type a Message', color: Colors.white, borderRadius: 30.0),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(3.0),
            child: GestureDetector(
              child: Icon(Icons.send, color: secondarButtonTextColor, size: 25.0,), 
              onTap: onPressed,
            ),
          ),
        ],
      ),
    );
  }
}