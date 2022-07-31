import 'package:flutter/foundation.dart';

class ThreadNotifier with ChangeNotifier {
  List _threads = [];
  List get threadList => _threads;

  void updateValue(List value) {
    _threads = value;
    notifyListeners();
  }

  set setValue(value) {
    _threads = null;
  }
}