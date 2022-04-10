import 'package:dialog_context/dialog_context.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crowdfarm/pages/dashboard.dart';
import 'package:crowdfarm/pages/login.dart';
import 'package:velocity_x/velocity_x.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences pref = await SharedPreferences.getInstance();
  bool login = pref.getBool('login');
  runApp(login == null || login == false ? MyApp() : MyApp1());
}

class MyApp extends StatelessWidget {
  // Create the initialization Future outside of `build`:
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
                backgroundColor: Vx.gray800,
                body: Center(
                  child: Text(
                    'Error',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                    ),
                  ),
                )),
          );
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            builder: DialogContext().builder,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
                primaryColor: Vx.gray800,
                primaryColorBrightness: Brightness.dark),
            home: Login(),
            routes: {'dashboard': (context) => DashBoardPage()},
          );
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return MaterialApp(
          home: Scaffold(
              backgroundColor: Vx.gray800,
              body: Center(
                child: CircularProgressIndicator(),
              )),
        );
      },
    );
  }
}

class MyApp1 extends StatelessWidget {
  // Create the initialization Future outside of `build`:
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
                backgroundColor: Vx.gray800,
                body: Center(
                  child: Text(
                    'Error',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                    ),
                  ),
                )),
          );
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            builder: DialogContext().builder,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
                primaryColor: Vx.gray800,
                primaryColorBrightness: Brightness.dark),
            home: DashBoardPage(),
            routes: {'dashboard': (context) => DashBoardPage()},
          );
        }
        // Otherwise, show something whilst waiting for initialization to complete
        return MaterialApp(
          home: Scaffold(
              backgroundColor: Vx.gray800,
              body: Center(
                child: CircularProgressIndicator(),
              )),
        );
      },
    );
  }
}
