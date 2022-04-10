import 'package:crowdfarm/methods/fireBaseAdd.dart';
import 'package:crowdfarm/pages/onboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

class DetailsForm extends StatefulWidget {
  final String name;
  final String email;
  final String phoneNumber;
  final String uid;
  final String image;
  DetailsForm({this.name, this.email, this.phoneNumber, this.uid, this.image});

  _DetailsFormState createState() => _DetailsFormState();
}

class _DetailsFormState extends State<DetailsForm> {
  final _formKey = GlobalKey<FormState>();
  String NoOfFamilyMembers;
  String LoanAmount;
  String Assets;
  String AnnualFamilyIncome;
  int noOfFamilyMembers;
  int loanAmount;
  int assets;
  int annualFamilyIncome;
  int calculateScore() {
    int score = 0;
    double avgIncome = annualFamilyIncome / noOfFamilyMembers;
    if (avgIncome <= 100000)
      score += 100;
    else if (avgIncome <= 250000)
      score += 250;
    else if (avgIncome <= 350000)
      score += 400;
    else
      score += 500;

    if (loanAmount <= 50000)
      score -= 20;
    else if (loanAmount <= 100000)
      score -= 50;
    else if (loanAmount <= 500000) score -= 100;

    if (assets <= 50000)
      score += 20;
    else if (assets <= 100000)
      score += 50;
    else if (assets <= 250000)
      score += 100;
    else
      score += 150;
    print(score);
    return score;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "CrowdFarm",
          style: TextStyle(fontSize: 25.0),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [Color(0xFFFFAA85), Color(0xFFB3315F)])),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(20, 60, 20, 20),
                child: TextFormField(
                  onChanged: (value) {
                    NoOfFamilyMembers = value;
                  },
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    Pattern pattern = r'^[1-9]\d*$';
                    RegExp regex = new RegExp(pattern);
                    if (value.trim().length == 0) {
                      return "Cannot be Empty";
                    } else if (!regex.hasMatch(value)) {
                      return "Enter A Valid Value (Integer)";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.person,
                      color: Colors.black,
                    ),
                    labelText: 'No. of Family Members',
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide:
                            BorderSide(color: Colors.redAccent, width: 4.0)),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: TextFormField(
                  onChanged: (value) {
                    Assets = value;
                  },
                  validator: (value) {
                    Pattern pattern = r'^[1-9]\d*$';
                    RegExp regex = new RegExp(pattern);
                    if (value.trim().length == 0) {
                      return "Cannot be Empty";
                    } else if (!regex.hasMatch(value)) {
                      return "Enter A Valid Value (Integer)";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.web_asset,
                        color: Colors.black,
                      ),
                      labelText: 'Assets',
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide:
                              BorderSide(color: Colors.redAccent, width: 4.0))),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: TextFormField(
                  onChanged: (value) {
                    LoanAmount = value;
                  },
                  validator: (value) {
                    Pattern pattern = r'^[1-9]\d*$';
                    RegExp regex = new RegExp(pattern);
                    if (value.trim().length == 0) {
                      return "Cannot be Empty";
                    } else if (!regex.hasMatch(value)) {
                      return "Enter A Valid Value (Integer)";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: Colors.black,
                      ),
                      labelText: 'Loan Amount',
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide:
                              BorderSide(color: Colors.redAccent, width: 4.0))),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: TextFormField(
                  onChanged: (value) {
                    AnnualFamilyIncome = value;
                  },
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    Pattern pattern = r'^[1-9]\d*$';
                    RegExp regex = new RegExp(pattern);
                    if (value.trim().length == 0) {
                      return "Cannot be Empty";
                    } else if (!regex.hasMatch(value)) {
                      return "Enter A Valid Value (Integer)";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      prefixIcon: SvgPicture.asset(
                        "assets/kes.svg",
                        width: 18.0,
                        height: 18.0,
                      ),
                      labelStyle: TextStyle(),
                      labelText: 'Annual Family Income',
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide:
                              BorderSide(color: Colors.redAccent, width: 4.0))),
                ),
              ),
              SizedBox(
                height: 50.0,
              ),
              RaisedButton(
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    noOfFamilyMembers = int.parse(NoOfFamilyMembers);
                    annualFamilyIncome = int.parse(AnnualFamilyIncome);
                    loanAmount = int.parse(LoanAmount);
                    assets = int.parse(Assets);
                    int tempScore = calculateScore();
                    FirebaseAdd().addUser(
                        widget.name,
                        widget.email,
                        widget.phoneNumber,
                        widget.uid,
                        widget.image,
                        tempScore,
                        context);
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) {
                      return IntroScreen();
                    }));
                  }
                },
                child: Text("Next"),
                padding: EdgeInsets.all(20),
                textColor: Colors.white,
                color: Color(0xFFB3315F),
                splashColor: Color(0xFFFFAA85),
              )
            ],
          ),
        ),
      ),
    );
  }
}
