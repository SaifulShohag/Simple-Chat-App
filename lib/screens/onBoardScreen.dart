import 'package:artist_recruit/Widgets/app-button.dart';
import 'package:artist_recruit/main.dart';
import 'package:artist_recruit/services/localDB-service.dart';
import 'package:artist_recruit/utils/constants.dart';
import 'package:flutter/material.dart';

class OnBoardScreen extends StatelessWidget {
  final localDB = LocalDBService();

  @override
  Widget build(BuildContext context) {
    localDB.initService();
    return Scaffold(
      backgroundColor: onBoardBGColor,
      body: WillPopScope(
        onWillPop: () async => false,
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 60.0, width: double.infinity),
                    CircleAvatar(
                      radius: 60.0,
                      backgroundImage: AssetImage('assets/images/logo.png'),
                      backgroundColor: Colors.transparent,
                    ),
                    SizedBox(height: 20.0,),
                    Text('Welcome To Our\nSimple Chat App', style: headerText, textAlign: TextAlign.center,),
                    SizedBox(height: 40.0,),
                    Row(
                      children: [
                        Expanded(
                          child: Image.asset(
                            'assets/images/1.jpg',
                            fit: BoxFit.contain,
                            height: 150.0,
                          ),
                        ),
                        SizedBox(width: 10.0,),
                        Expanded(
                          child: Image.asset(
                            'assets/images/2.jpg',
                            fit: BoxFit.contain,
                            height: 150.0,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.0,),
                    Row(
                      children: [
                        Expanded(
                          child: Image.asset(
                            'assets/images/3.jpg',
                            fit: BoxFit.contain,
                            height: 150.0,
                          ),
                        ),
                        SizedBox(width: 10.0,),
                        Expanded(
                          child: Image.asset(
                            'assets/images/4.jpg',
                            fit: BoxFit.contain,
                            height: 150.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
                  alignment: Alignment.bottomRight,
                  child: AppButton(
                    horizontalPadding: 40.0,
                    verticalPadding: 10.0,
                    title: "Get Started", 
                    buttonColor: Colors.white,
                    textStyle: titleText,
                    onTap: () async {
                      await localDB.markFirstLaunchOver();
                      Navigator.pushReplacement(context, MaterialPageRoute(
                      builder: (context) => AuthenticationWrapper()));
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}