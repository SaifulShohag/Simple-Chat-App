import 'package:artist_recruit/listeners/fileNotifier.dart';
import 'package:artist_recruit/listeners/threadNotifier.dart';
import 'package:artist_recruit/listeners/userListNotifier.dart';
import 'package:artist_recruit/screens/onBoardScreen.dart';
import 'package:artist_recruit/services/localDB-service.dart';
import 'package:flutter/material.dart';
import 'package:artist_recruit/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:artist_recruit/screens/home-page.dart';
import 'package:artist_recruit/screens/auth/signIn-page.dart';
import 'package:provider/provider.dart';

final localDB = LocalDBService();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await localDB.initService();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThreadNotifier()),
        ChangeNotifierProvider(create: (_) => ImageFileNotifier()),
        ChangeNotifierProvider(create: (_) => UserListNotifier()),
      ],
      child: MyApp()
    )
  );
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Chat App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          titleSpacing: 0,
          backgroundColor: primaryColor,
          iconTheme: IconThemeData(
            color: iconBtnColorWhite,
          )
        ),
        primaryColor: primaryColor,
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: primaryColor,
        ),
      ),
      home: AuthenticationWrapper(),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if(snapshot.hasData && snapshot.data != null) {
          return HomePage();
        }
        return Visibility(
          visible: localDB.isFirstLaunch() != null,
          child: SignInPage(),
          replacement: OnBoardScreen(),
        );
      },
    );
  }
}