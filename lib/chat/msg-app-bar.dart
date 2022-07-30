import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:artist_recruit/screens/user-profile-screen/user-arts-profile-screen.dart';
import 'package:artist_recruit/services/datastore-service.dart';
import 'package:artist_recruit/utils/constants.dart';

class MsgAppBar extends StatelessWidget {
  final String uid;
  final String username;
  final String imgUrl;
  final bool isBlocked;
  MsgAppBar({@required this.uid, @required this.username, @required this.imgUrl, @required this.isBlocked});

  final User user = FirebaseAuth.instance.currentUser;
  final dataStoreService = DataStoreService();
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.only(top: 38.0, bottom: 10.0, left: 10.0, right: 10.0),
            color: Colors.grey[300],
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios,),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Align(
                    alignment: Alignment.center,
                    child: Wrap(
                      direction: Axis.vertical,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            if(!isBlocked) {
                                preventDoubleTap(context);
                              var userArt = await dataStoreService.getUserArtsDataByUid(uid);
                              List existingThread = await dataStoreService.getMessageThreadByIDs(user.uid, uid) ?? [];
                              Navigator.pop(context);
                              Navigator.push(context, MaterialPageRoute(builder: (context) => UserArtProfileScreen(userArt: userArt, existingThread: existingThread,)));
                            }
                          },
                          child: CircleAvatar(
                            radius: 25.0,
                            backgroundImage: NetworkImage(imgUrl),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Text(username, style: subheadTextBlack,),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}