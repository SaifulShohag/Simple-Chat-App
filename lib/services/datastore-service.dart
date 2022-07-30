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
  
  Future getUserDataErrorHandler(context, {User user}) async {
    Map data = {};
    String id = '';
    var res = await dataStore.collection('users').where('uid', isEqualTo: user.uid).get();
    if(res.docs.length < 1) {
      await user.updateDisplayName('');
      await user.updatePhotoURL(null);
      Navigator.popUntil(context, (route) => route.isFirst);
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
    } else {
      res.docs.forEach((element) {
        id = element.id;
        data = element.data();
      });
      return {'id': id, ...data};
    }
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

  Future updateDisplayName({String docID, String fullName}) async {
    await dataStore.collection('users').doc(docID).update({
      'fullName': fullName,
    });
    return 'done';
  }

  Future updateProfilePicture({String docID, String photoURL}) async {
    await dataStore.collection('users').doc(docID).update({
      'photoURL': photoURL,
    });
    return 'done';
  }

  Future deleteImagefromStorage(String url) async {
    if(Uri.tryParse(url ?? '')?.hasAbsolutePath ?? false) FirebaseStorage.instance.refFromURL(url)
      .delete().catchError((_) => '');
    return 'done';
  }
}