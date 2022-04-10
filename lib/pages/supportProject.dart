import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:crowdfarm/methods/fireBaseAdd.dart';
import 'package:crowdfarm/methods/getUser.dart';
import 'package:crowdfarm/models/UserModel.dart';
import 'package:crowdfarm/models/campaignModel.dart';
import 'package:crowdfarm/pages/dashboard.dart';
import 'package:velocity_x/velocity_x.dart';

class SupportProject extends StatefulWidget {
  final CampaignModel campaignModel;
  SupportProject({this.campaignModel});
  @override
  _SupportProjectState createState() => _SupportProjectState();
}

final supportPageForm = GlobalKey<FormState>();

class _SupportProjectState extends State<SupportProject> {
  final svg = SvgPicture.asset(
    "assets/invest.svg",
    height: 300,
  );
  String amountToBeInvested;
  String interest;
  bool loading = false;
  int AmountToBeInvested;
  int Interest;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: GradientAppBar(
          centerTitle: true,
          title: Text("Support Project"),
          gradient: LinearGradient(
            end: Alignment.bottomCenter,
            begin: Alignment.topCenter,
            colors: [
              const Color(0xFFFFAA85),
              const Color(0XFFB3315F),
            ],
          ),
        ),
        body: !loading
            ? Form(
                key: supportPageForm,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 50,
                        ),
                        svg,
                        SizedBox(
                          height: 30,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0XFFfcdada),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              amountToBeInvested = value;
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
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              decoration: TextDecoration.none,
                            ),
                            decoration: InputDecoration(
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              prefixIcon: Icon(
                                Icons.attach_money,
                                size: 30,
                              ),
                              labelStyle: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                              labelText: "Amount to be invested in GEN",
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        "X".text.size(20).bold.makeCentered(),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0XFFfcdada),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              interest = value;
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
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              decoration: TextDecoration.none,
                            ),
                            decoration: InputDecoration(
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              prefixIcon: Icon(
                                Icons.trending_up,
                                size: 30,
                              ),
                              labelStyle: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                              labelText: "Interest per month",
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        RaisedButton(
                          onPressed: () async {
                            if (supportPageForm.currentState.validate()) {
                              UserModel currentUser = await getCurrentUser();
                              AmountToBeInvested =
                                  int.parse(amountToBeInvested);
                              Interest = int.parse(interest);
                              final x = await FirebaseFirestore.instance
                                  .collection("campaigns")
                                  .doc(widget.campaignModel.id.toString())
                                  .collection("notApproved")
                                  .doc(currentUser.address)
                                  .get();
                              final y = await FirebaseFirestore.instance
                                  .collection("campaigns")
                                  .doc(widget.campaignModel.id.toString())
                                  .collection("investments")
                                  .doc(currentUser.address)
                                  .get();
                              if (widget.campaignModel.ownedByInvestorTotal +
                                      (AmountToBeInvested /
                                              widget
                                                  .campaignModel.totalAmount) *
                                          100 >
                                  100) {
                                Fluttertoast.showToast(
                                    msg:
                                        "You investment amount exceed the requirements of fundRaiser.",
                                    backgroundColor: Colors.red[800],
                                    textColor: Colors.white,
                                    gravity: ToastGravity.CENTER);
                              } else if (currentUser.address ==
                                  widget.campaignModel.publisherAddress) {
                                Fluttertoast.showToast(
                                    msg: "You cant invest in your own campaign",
                                    backgroundColor: Colors.red[800],
                                    textColor: Colors.white,
                                    gravity: ToastGravity.CENTER);
                              } else if (currentUser.balance <
                                  AmountToBeInvested) {
                                Fluttertoast.showToast(
                                    msg: "Balance too low",
                                    backgroundColor: Colors.red[800],
                                    textColor: Colors.white,
                                    gravity: ToastGravity.CENTER);
                              } else if (x.exists || y.exists) {
                                Fluttertoast.showToast(
                                    msg: "You cant invest again",
                                    backgroundColor: Colors.red[800],
                                    textColor: Colors.white,
                                    gravity: ToastGravity.CENTER);
                              } else {
                                setState(() {
                                  loading = true;
                                });
                                await FirebaseAdd()
                                    .addInterestApproval(
                                        investor: currentUser,
                                        interest: Interest,
                                        investAmount: AmountToBeInvested,
                                        campaign: widget.campaignModel)
                                    .then((value) {
                                  setState(() {
                                    loading = false;
                                  });
                                  Fluttertoast.showToast(
                                      msg: "Request for investment sent.",
                                      backgroundColor: Colors.green,
                                      textColor: Colors.white,
                                      gravity: ToastGravity.CENTER);

                                  Navigator.popUntil(context,
                                      ModalRoute.withName('/dashboard'));
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              DashBoardPage()));
                                });
                              }
                            }
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(80.0)),
                          padding: const EdgeInsets.all(0.0),
                          child: Ink(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  const Color(0XFFFCCF31),
                                  const Color(0XFFF55555),
                                ],
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(80.0)),
                            ),
                            child: Container(
                              padding: EdgeInsets.all(10),
                              width: 300,
                              constraints: const BoxConstraints(
                                  minWidth: 88.0,
                                  minHeight:
                                      36.0), // min sizes for Material buttons
                              alignment: Alignment.center,
                              child: const Text(
                                'INVEST',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )
            : Center(child: SpinKitWave(color: Colors.red, size: 45)),
      ),
    );
  }
}
