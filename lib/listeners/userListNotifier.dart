import 'package:flutter/foundation.dart';

class UserListNotifier with ChangeNotifier {
  List _userList = [];
  List get userList => _userList;

  void updateValue(List value) {
    _userList = value;
    notifyListeners();
  }

  set setValue(value) {
    _userList = null;
  }
}