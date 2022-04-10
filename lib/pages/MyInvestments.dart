import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:velocity_x/velocity_x.dart';

class MyInvestments extends StatefulWidget {
  final String address;
  MyInvestments({this.address});
  @override
  _MyInvestmentsState createState() => _MyInvestmentsState();
}

class _MyInvestmentsState extends State<MyInvestments> {
  Future getInvestments() async {
    final x = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.address)
        .collection("investments")
        .get();
    return x.docs;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: GradientAppBar(
          centerTitle: true,
          title: Text("My Investments"),
          gradient: LinearGradient(
            end: Alignment.bottomCenter,
            begin: Alignment.topCenter,
            colors: [
              const Color(0xFFFFAA85),
              const Color(0XFFB3315F),
            ],
          ),
        ),
        body: FutureBuilder(
            future: getInvestments(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SpinKitWave(color: Colors.red, size: 50).centered();
              } else if (snapshot.hasData) {
                if (snapshot.data.length == 0) {
                  return "No investments made"
                      .text
                      .bold
                      .size(22)
                      .makeCentered();
                } else {
                  return ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        int daysDiff = (DateTime.now().difference(snapshot
                                .data[index]
                                .data()['lastDate']
                                .toDate()))
                            .inDays;
                        int amountRemain =
                            (snapshot.data[index].data()['investAmount'] +
                                    ((daysDiff / 30) *
                                        (snapshot.data[index]
                                                .data()['investAmount'] *
                                            snapshot.data[index]
                                                .data()['interest']) /
                                        100) +
                                    ((daysDiff % 30) *
                                        (snapshot.data[index]
                                                .data()['investAmount'] *
                                            snapshot.data[index]
                                                .data()['interest']) /
                                        3000))
                                .toInt();

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Card(
                            margin: EdgeInsets.all(15),
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                //color: Color(0xFFd9ecf2),
                                color: !snapshot.data[index].data()['isPaid']
                                    ? Color(0xFFff7171)
                                    : Colors.green[600],
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Invested on ${snapshot.data[index].data()['investorName']}",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFcffffe),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    "${snapshot.data[index].data()['ownershipPercent']}% ownership",
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFcffffe),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  "Amount Repaid: ${snapshot.data[index].data()['repaid']} GEN"
                                      .text
                                      .purple700
                                      .bold
                                      .size(24)
                                      .make(),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  "Amount Due:$amountRemain GEN"
                                      .text
                                      .indigo700
                                      .bold
                                      .size(24)
                                      .make(),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    "at 15% per month",
                                    style: TextStyle(
                                        fontSize: 25,
                                        color: Color(0xFFfddb3a),
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      });
                }
              } else {
                return "No investments made".text.bold.size(22).makeCentered();
              }
            }),
      ),
    );
  }
}
