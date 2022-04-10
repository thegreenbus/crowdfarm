import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:crowdfarm/methods/blockchain.dart';
import 'package:crowdfarm/methods/getUser.dart';
import 'package:crowdfarm/models/UserModel.dart';
import 'package:crowdfarm/models/campaignModel.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:web3dart/web3dart.dart';

class AllLedgers extends StatefulWidget {
  final CampaignModel campaignModel;
  AllLedgers(this.campaignModel);
  @override
  _AllLedgersState createState() => _AllLedgersState();
}

final amountInputForm = GlobalKey<FormState>();

class _AllLedgersState extends State<AllLedgers> {
  Stream getLedgers() {
    final x = FirebaseFirestore.instance
        .collection("campaigns")
        .doc(widget.campaignModel.id.toString())
        .collection('investments')
        .snapshots();
    return x;
  }

  String amount;
  int Amount;
  Future<void> _showMyDialog(
      QueryDocumentSnapshot snap, int amountToBePaid, int daysDiff) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter the Amount'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Form(
                  key: amountInputForm,
                  child: TextFormField(
                    onChanged: (value) {
                      amount = value;
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
                      hintStyle: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                      hintText: "Amount in GEN",
                      labelStyle: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Confirm'),
              onPressed: () async {
                if (amountInputForm.currentState.validate()) {
                  UserModel currentUser = await getCurrentUser();
                  Amount = int.parse(amount);
                  if (Amount >= currentUser.balance) {
                    Fluttertoast.showToast(
                        msg: "Balance too low",
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        gravity: ToastGravity.TOP);
                  } else if (Amount > amountToBePaid) {
                    Fluttertoast.showToast(
                        msg: "Enter Valid Amount",
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        gravity: ToastGravity.TOP);
                  } else {
                    if (Amount == amountToBePaid) {
                      var response = await submit(
                          "newRepay",
                          [
                            BigInt.from(widget.campaignModel.id),
                            EthereumAddress.fromHex(
                                snap.data()['investorAddress']),
                            BigInt.from(daysDiff),
                            BigInt.from(Amount),
                          ],
                          context);
                      print(response);
                      await FirebaseFirestore.instance
                          .collection("users")
                          .doc(currentUser.address)
                          .update({
                        'balance': FieldValue.increment(-amountToBePaid),
                      });

                      await FirebaseFirestore.instance
                          .collection("users")
                          .doc(snap.data()['investorAddress'])
                          .update({
                        'balance': FieldValue.increment(amountToBePaid),
                      });

                      await FirebaseFirestore.instance
                          .collection("campaigns")
                          .doc(widget.campaignModel.id.toString())
                          .update({
                        'ownedByInvestorTotal': FieldValue.increment(
                            -snap.data()['ownershipPercent']),
                      });

                      await FirebaseFirestore.instance
                          .collection("campaigns")
                          .doc(widget.campaignModel.id.toString())
                          .collection("investments")
                          .doc(snap.data()['investorAddress'])
                          .update({
                        'repaid': FieldValue.increment(amountToBePaid),
                        'investAmount': 0,
                        'ownershipPercent': 0,
                        'isPaid': true,
                        'lastDate': DateTime.now()
                      });

                      await FirebaseFirestore.instance
                          .collection("users")
                          .doc(snap.data()['investorAddress'])
                          .collection("investments")
                          .doc(widget.campaignModel.id.toString())
                          .update({
                        'repaid': FieldValue.increment(amountToBePaid),
                        'investAmount': 0,
                        'ownershipPercent': 0,
                        'isPaid': true,
                        'lastDate': DateTime.now()
                      });

                      Fluttertoast.showToast(
                          msg:
                              "Repaid successfully, balance will updated soon!.",
                          backgroundColor: Colors.green,
                          textColor: Colors.white,
                          gravity: ToastGravity.TOP);

                      Navigator.of(context).pop();
                    } else {
                      var response = await submit(
                          "newRepay",
                          [
                            BigInt.from(widget.campaignModel.id),
                            EthereumAddress.fromHex(
                                snap.data()['investorAddress']),
                            BigInt.from(daysDiff),
                            BigInt.from(Amount),
                          ],
                          context);
                      print(response);
                      int ownershipGainedByPaying =
                          ((((Amount * 100) / amountToBePaid) *
                                  (snap.data()['ownershipPercent'])) ~/
                              100);

                      await FirebaseFirestore.instance
                          .collection("users")
                          .doc(currentUser.address)
                          .update({
                        'balance': FieldValue.increment(-Amount),
                      });

                      await FirebaseFirestore.instance
                          .collection("users")
                          .doc(snap.data()['investorAddress'])
                          .update({
                        'balance': FieldValue.increment(Amount),
                      });

                      await FirebaseFirestore.instance
                          .collection("campaigns")
                          .doc(widget.campaignModel.id.toString())
                          .collection("investments")
                          .doc(snap.data()['investorAddress'])
                          .update({
                        'repaid': FieldValue.increment(Amount),
                        'investAmount': amountToBePaid - Amount,
                        'ownershipPercent':
                            FieldValue.increment(-ownershipGainedByPaying),
                        'lastDate': DateTime.now()
                      });

                      await FirebaseFirestore.instance
                          .collection("users")
                          .doc(snap.data()['investorAddress'])
                          .collection("investments")
                          .doc(widget.campaignModel.id.toString())
                          .update({
                        'repaid': FieldValue.increment(Amount),
                        'investAmount': amountToBePaid - Amount,
                        'ownershipPercent':
                            FieldValue.increment(-ownershipGainedByPaying),
                        'lastDate': DateTime.now()
                      });

                      await FirebaseFirestore.instance
                          .collection("campaigns")
                          .doc(widget.campaignModel.id.toString())
                          .update({
                        'ownedByInvestorTotal':
                            FieldValue.increment(-ownershipGainedByPaying),
                      });
                      Fluttertoast.showToast(
                          msg:
                              "Repaid successfully, balance will updated soon !.",
                          backgroundColor: Colors.green,
                          textColor: Colors.white,
                          gravity: ToastGravity.TOP);

                      Navigator.of(context).pop();
                    }
                  }
                }
              },
            ),
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: GradientAppBar(
          centerTitle: true,
          title: Text("All Ledgers"),
          gradient: LinearGradient(
            end: Alignment.bottomCenter,
            begin: Alignment.topCenter,
            colors: [
              const Color(0xFFFFAA85),
              const Color(0XFFB3315F),
            ],
          ),
        ),
        body: StreamBuilder(
            stream: getLedgers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SpinKitWave(color: Colors.red, size: 50).centered();
              }
              if (snapshot.hasData) {
                if (snapshot.data.documents.length == 0) {
                  return "No investments yet :("
                      .text
                      .size(22)
                      .semiBold
                      .red600
                      .makeCentered();
                } else {
                  return ListView.builder(
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (BuildContext context, int index) {
                        int daysDiff = (DateTime.now().difference(snapshot
                                .data.documents[index]
                                .data()['lastDate']
                                .toDate()))
                            .inDays;
                        int amountRemain = (snapshot.data.documents[index]
                                    .data()['investAmount'] +
                                ((daysDiff / 30) *
                                    (snapshot.data.documents[index]
                                            .data()['investAmount'] *
                                        snapshot.data.documents[index]
                                            .data()['interest']) /
                                    100) +
                                ((daysDiff % 30) *
                                    (snapshot.data.documents[index]
                                            .data()['investAmount'] *
                                        snapshot.data.documents[index]
                                            .data()['interest']) /
                                    3000))
                            .toInt();
                        return Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          margin: EdgeInsets.all(15),
                          child: Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Color(0xFFd9ecf2)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Investor: ${snapshot.data.documents[index].data()['investorName']}",
                                  style: TextStyle(
                                      fontSize: 30,
                                      color: Color(0xFFe8505b),
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 2,
                                ),
                                Text(
                                  "Ownership: ${snapshot.data.documents[index].data()['ownershipPercent']} %",
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Color(0xFF03c4a1),
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 2,
                                ),
                                Text(
                                  "Interest: ${snapshot.data.documents[index].data()['interest']}% per month",
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Color(0xFF03c4a1),
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "$amountRemain",
                                      style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      " GEN due",
                                      style: TextStyle(
                                        fontSize: 25,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 6,
                                ),
                                !snapshot.data.documents[index].data()['isPaid']
                                    ? RaisedButton(
                                        onPressed: () {
                                          _showMyDialog(
                                              snapshot.data.documents[index],
                                              amountRemain,
                                              daysDiff);
                                        },
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(80.0)),
                                        padding: const EdgeInsets.all(0.0),
                                        child: Ink(
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF352740),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(15.0)),
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
                                              'Repay',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 25,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ).centered()
                                    : "All Dues Paid !"
                                        .text
                                        .size(25)
                                        .green700
                                        .bold
                                        .makeCentered()
                              ],
                            ),
                          ),
                        );
                      });
                }
              } else {
                return "No investments yet :("
                    .text
                    .size(22)
                    .semiBold
                    .red600
                    .makeCentered();
              }
            }));
  }
}
