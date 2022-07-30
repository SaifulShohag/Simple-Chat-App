import 'dart:io';
import 'package:artist_recruit/Widgets/bottom-modal.dart';
import 'package:artist_recruit/screens/home-page.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:artist_recruit/Widgets/text-input-field.dart';
import 'package:artist_recruit/services/datastore-service.dart';
import 'package:artist_recruit/Widgets/app-button.dart';
import 'package:artist_recruit/services/image-service.dart';
import 'package:artist_recruit/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewUsersNameImage extends StatefulWidget {
  @override
  _NewUsersNameImageState createState() => _NewUsersNameImageState();
}

class _NewUsersNameImageState extends State<NewUsersNameImage> {
  final _formKey = GlobalKey<FormState>();
  final imageService = ImageService();
  final nameController = TextEditingController();
  final User user = FirebaseAuth.instance.currentUser;
  final dataStore = DataStoreService();
  final String imageUrl = 'assets/images/cameraIcon.png';
  File _image;

  selectImage(BuildContext context) {
    bottomModal(context: context, children: [
      ListTile(
        leading: Icon(Icons.photo_library),
        title: Text('Photo Library'),
        onTap: () async {
          var value = await imageService.pickImageFromGallery();
          if(value != null) {
            cropProfileImage(value);
          }
          Navigator.of(context).pop();
        }
      ),
      ListTile(
        leading: Icon(Icons.photo_camera),
        title: Text('Camera'),
        onTap: () async {
          var value = await imageService.pickImageFromCamera();
          if(value != null) {
            cropProfileImage(value);
          }
          Navigator.of(context).pop();
        },
      ),
    ]);
  }

  Future cropProfileImage(File file) async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: file.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Theme.of(context).primaryColor,
            toolbarWidgetColor: secondaryBtnColor,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));
    if (croppedFile != null) {
      setState(() => _image = croppedFile);
    }
  }

  submitUserData() {
      if(_image == null) {
        showAlertDialougue(context, title: 'Error Found', content: 'Select an Image Please.');
      } else {
        imageService.uploadImages(context, _image).then((value) async {
          preventDoubleTap(context);
          await user.updatePhotoURL(value);
          await user.updateDisplayName(nameController.text.trim());
          await dataStore.createNewUser(user, photoURL: value, fullName: nameController.text.trim());
          Navigator.popUntil(context, (route) => route.isFirst);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => HomePage()));
        });
      }
    }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 100.0,),
                  GestureDetector(
                    onTap: () => selectImage(context),
                    child: CircleAvatar(
                      radius: 105.0,
                      backgroundColor: primaryColor,
                      child: CircleAvatar(
                        radius: 100.0,
                        backgroundImage: _image == null ? AssetImage(imageUrl) : FileImage(_image),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      selectImage(context);
                    }, 
                    child: Text(
                      'Select Profile Picture',
                      style: TextStyle(
                        color: blackTextColor,
                        fontSize: 15.0,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0,),
                  TextInputField(
                    label: 'Full Name',
                    controller: nameController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Enter your name';
                      } else if(value.length < 3) {
                        return 'Enter at least 3 characters';
                      } else {
                        return null;
                      }
                    },
                  ),
                  SizedBox(height: 10.0,),
                  SizedBox(height: 10.0,),
                  SizedBox(height: 20.0,),
                  AppButton(
                    title: 'Confirm', 
                    onTap: () {
                      if (_formKey.currentState.validate()) {
                        submitUserData();
                      }
                    }
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}