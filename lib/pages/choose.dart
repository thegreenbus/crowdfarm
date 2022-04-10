import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crowdfarm/methods/googleauth.dart';
import 'package:crowdfarm/pages/login.dart';

class SelectRole extends StatefulWidget {
  @override
  _SelectRoleState createState() => _SelectRoleState();
}

class _SelectRoleState extends State<SelectRole> {
  final Widget svg = SvgPicture.asset(
    "assets/selectRole.svg",
    height: 350,
    width: 350,
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: GradientAppBar(
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.clear();
                signOut();
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => Login()));
              },
            )
          ],
          centerTitle: true,
          title: Text("Select Your Role"),
          gradient: LinearGradient(
            end: Alignment.bottomCenter,
            begin: Alignment.topCenter,
            colors: [
              const Color(0xFFFFAA85),
              const Color(0xFFB3315F),
            ],
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            svg,
            SizedBox(
              height: 30,
            ),
            Text(
              "You Are An :",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1d2d50),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            GestureDetector(
              //onTap: TODO - add Function to navigate to create a campaign ,
              child: Container(
                margin:
                    EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
                padding: EdgeInsets.all(15),
                child: Center(
                  child: Text(
                    "INVESTOR",
                    style: TextStyle(
                      color: Color(0xFF1d2d50),
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                decoration: BoxDecoration(
                    color: Color(0xFFade498),
                    borderRadius: BorderRadius.circular(40)),
              ),
            ),
            GestureDetector(
              //onTap: TODO - add Function to navigate to vertical list of campaigns,
              child: Container(
                margin:
                    EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
                padding: EdgeInsets.all(15),
                child: Center(
                  child: Text(
                    "FUND RAISER",
                    style: TextStyle(
                      color: Color(0xFF1d2d50),
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                decoration: BoxDecoration(
                    color: Color(0xFFade498),
                    borderRadius: BorderRadius.circular(40)),
              ),
            ),
          ],
        ));
  }
}
