import 'dart:io';
import 'package:flutter/foundation.dart';

class ImageFileNotifier with ChangeNotifier {
  File _image;
  File get images => _image;

  void updateValue(File value) {
    _image = value;
    notifyListeners();
  }

  set setValue(value) {
    _image = null;
  }
}