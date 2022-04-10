import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:crowdfarm/methods/googleauth.dart';
import 'package:velocity_x/velocity_x.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Colors.white, Colors.white10])),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'CrowdFarm',
                style: GoogleFonts.orbitron(
                    textStyle: TextStyle(
                        foreground: Paint()
                          ..shader = LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [Color(0xFFFFAA85), Color(0xFFB3315F)],
                          ).createShader(Rect.fromLTWH(100, 0, 200, 0)),
                        fontSize: 40,
                        fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: EdgeInsets.all(30),
                child: SvgPicture.asset(
                  'assets/selectRole.svg',
                  height: 350,
                  width: 350,
                ),
              ),
              RaisedButton(
                onPressed: () {
                  signInWithGoogle(context);
                },
                padding: EdgeInsets.all(0.0),
                shape: StadiumBorder(),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25.0),
                      color: Colors.black),
                  child: HStack(
                    [
                      Image.asset('assets/google.png'),
                      "Continue With Google"
                          .text
                          .bold
                          .size(18)
                          .white
                          .make()
                          .centered()
                    ],
                    alignment: MainAxisAlignment.spaceAround,
                  ),
                  padding:
                      EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0),
                ).w(context.screenWidth).h(50),
              ).centered().p32(),
            ]),
      ),
    );
  }
}
