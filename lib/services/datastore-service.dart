import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class DataStoreService {
  final dataStore =  FirebaseFirestore.instance;

  Future createNewUser(User user, {@required String fullName, @required String photoURL}) async {
    var newUser = await dataStore.collection('users').add({
      'uid': user.uid,
      'fullName': fullName ?? user.displayName,
      'photoURL': photoURL ?? user.photoURL,
      'email': user.email,
    });
    return newUser;
  }

  Future getAllUsers() async {
    List data = [];
    var res = await dataStore.collection('users').get();
    res.docs.forEach((element) {
      data.add({'id': element.id, ...element.data()});
    });
    return data;
  }

  Future getUserDataByUid(String uid) async {
    Map data = {};
    var res = await dataStore.collection('users').where('uid', isEqualTo: uid).get();
    res.docs.forEach((element) {
      data = {'id': element.id, ...element.data()};
    });
    return data;
  }

  Future updateStudentData({String docID, String fullName, String userID}) async {
    await dataStore.collection('users').doc(docID).update({
      'fullName': fullName,
      'userID': userID,
    });
    return 'done';
  }

  Future updateUserProfile({String docID, String fullName, String photoURL}) async {
    await dataStore.collection('users').doc(docID).update({
      'fullName': fullName,
      'photoURL': photoURL
    });
    return 'done';
  }

  Future deleteImagefromStorage(String url) async {
    if(Uri.tryParse(url ?? '')?.hasAbsolutePath ?? false) FirebaseStorage.instance.refFromURL(url)
      .delete().catchError((_) => '');
    return 'done';
  }

  Future createMessageThread(context, User user, {String rUid, String rUsername, String rPhotoURL, String message}) async {
    var msgData = {
      'sender': user.uid,
      'recipient': rUid,
      'message': message,
      'timeStamp': DateTime.now().millisecondsSinceEpoch,
      'seen': false,
      'seenAt': 0,
    };

    var res = await dataStore.collection('messageThreads').add({
      'user1': {
        'uid': user.uid,
        'username': user.displayName,
        'photoURL': user.photoURL,
      },
      'user2': {
        'uid': rUid,
        'username': rUsername,
        'photoURL': rPhotoURL,
      },
      'lastMessage': msgData
    });

    dataStore.collection('inboxMessages').add({
      'threadID': res.id,
      ...msgData
    });
    return 'done';
  }

  Future getUserMessageThreadList(context, User user) async {
    List data = [];
    List data2 = [];

    var res = await dataStore.collection('messageThreads').where('user1.uid', isEqualTo: user.uid).get();
    var res2 = await dataStore.collection('messageThreads').where('user2.uid', isEqualTo: user.uid).get();

    res.docs.forEach((element) {
      data.add({...element.data(), 'id': element.id});
    });
    res2.docs.forEach((element) {
      data2.add({...element.data(), 'id': element.id});
    });
    return [...data, ...data2] ?? [];
  }

  Future getMessageThreadByIDs(String userUID, String rUID) async {
    List data = [];
    List data2 = [];

    var res = await dataStore.collection('messageThreads').where('user1.uid', isEqualTo: userUID).where('user2.uid', isEqualTo: rUID).get();
    var res2 = await dataStore.collection('messageThreads').where('user1.uid', isEqualTo: rUID).where('user2.uid', isEqualTo: userUID).get();

    res.docs.forEach((element) {
      data.add({...element.data(), 'id': element.id});
    });
    res2.docs.forEach((element) {
      data2.add({...element.data(), 'id': element.id});
    });
    return [...data, ...data2] ?? [];
  }

  Future sendInboxMessage(User user, String threadID, {String rUid, String message}) async {
    var msgData = {
      'sender': user.uid,
      'recipient': rUid,
      'message': message,
      'timeStamp': DateTime.now().millisecondsSinceEpoch,
      'seen': false,
      'seenAt': 0,
    };
    var newMsg = {
      'threadID': threadID,
      ...msgData
    };
    dataStore.collection('inboxMessages').add({
      ...newMsg
    });
    dataStore.collection('messageThreads').doc(threadID).update({
      'lastMessage': msgData,
    });
    return 'done';
  }

  Future messageBeingSeen(context, User user, Map thread) async {
    var msgData = {
      'sender': thread['lastMessage']['sender'],
      'recipient': thread['lastMessage']['recipient'],
      'message': thread['lastMessage']['message'],
      'timeStamp': thread['lastMessage']['timeStamp'],
      'seen': true,
      'seenAt': DateTime.now().millisecondsSinceEpoch,
    };
    String keyName = thread['user1']['uid'] == user.uid ? 'user1' : 'user2';
    dataStore.collection('messageThreads').doc(thread['id']).update({
      keyName: {
        'uid': user.uid,
        'username': user.displayName,
        'photoURL': user.photoURL,
      },
      'lastMessage': msgData,
    });
    return 'done';
  }
}