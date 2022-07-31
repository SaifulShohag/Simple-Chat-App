import 'package:shared_preferences/shared_preferences.dart';

class LocalDBService {
  SharedPreferences prefs;
  
  initService() async {
    prefs = await SharedPreferences.getInstance();
  }
  
  isFirstLaunch() {
    return prefs.get('thisIsNotTheFirstLaunch');
  }

  markFirstLaunchOver() async {
    await prefs.setBool('thisIsNotTheFirstLaunch', true);
  }
}