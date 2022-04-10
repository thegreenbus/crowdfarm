import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crowdfarm/config/config.dart';
import 'package:crowdfarm/methods/blockchain.dart';
import 'package:crowdfarm/methods/getUser.dart';
import 'package:crowdfarm/methods/googleauth.dart';
import 'package:crowdfarm/models/UserModel.dart';
import 'package:crowdfarm/pages/MyInvestments.dart';
import 'package:crowdfarm/pages/campignslist.dart';
import 'package:crowdfarm/pages/createCampaign.dart';
import 'package:crowdfarm/pages/login.dart';
import 'package:crowdfarm/pages/myCampaign.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:web3dart/credentials.dart';

class DashBoardPage extends StatefulWidget {
  @override
  _DashBoardPageState createState() => _DashBoardPageState();
}

class _DashBoardPageState extends State<DashBoardPage> {
  UserModel user;
  bool loading = true;
  @override
  void initState() {
    super.initState();
    getUser();
  }

  void getUser() async {
    setState(() {
      loading = true;
    });
    user = await getCurrentUser();
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [AppColors.primary, AppColors.secondary])),
          child: loading == true
              ? Center(
                  child: SpinKitWave(
                    color: AppColors.primary,
                    size: 60,
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    SizedBox(
                      height: 20.0,
                    ),
                    Image.asset('assets/logo.jpeg',
                        fit: BoxFit.contain, height: 170),
                    (10).heightBox,
                    Column(
                      children: <Widget>[
                        Text(
                          'Hello',
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                        Text(
                          '${user.name}',
                          style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        '${user.getEthaddress(user.address)}'
                            .text
                            .normal
                            .size(14)
                            .gray800
                            .maxLines(1)
                            .make()
                            .px32()
                            .py8(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.copy,
                                color: Colors.white,
                                size: 25,
                              ),
                              splashColor: Colors.green,
                              iconSize: 25,
                              onPressed: () {},
                            ),
                            (20).widthBox,
                            IconButton(
                              icon: Icon(
                                Icons.logout,
                                color: Colors.white,
                                size: 25,
                              ),
                              splashColor: Colors.green,
                              iconSize: 25,
                              onPressed: () async {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                prefs.clear();
                                signOut();
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Login()));
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: Color(0xFF352740),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15))),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                height: 100,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      FutureBuilder(
                                          future: query("balanceOf", [
                                            EthereumAddress.fromHex(
                                                user.address)
                                          ]),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return "Loading balance"
                                                  .text
                                                  .size(30)
                                                  .make()
                                                  .shimmer();
                                            } else
                                              return Text(
                                                '${snapshot.data[0]} GEN',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.redAccent,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 30),
                                              );
                                          }),
                                      (5).heightBox,
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          "1 GEN Coin = 50 KES"
                                              .text
                                              .size(14)
                                              .white
                                              .makeCentered(),
                                          (5).widthBox,
                                          IconButton(
                                            icon: Icon(Icons.refresh,
                                                color: Colors.white),
                                            onPressed: () => setState(() {}),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Divider(
                                height: 0.5,
                                color: Colors.grey,
                              ),
                              Table(
                                border: TableBorder.symmetric(
                                  inside: BorderSide(
                                      color: Colors.grey,
                                      style: BorderStyle.solid,
                                      width: 0.5),
                                ),
                                children: [
                                  TableRow(children: [
                                    _actionList(
                                        Icons.call_made_outlined, 'Send Money',
                                        () async {
                                      var result = await query(
                                          "campaigns", [BigInt.from(0)]);
                                      print(result);
                                      //TODO Show dialog mai address fir blockchain mai tranferFrom
                                    }),
                                    _actionList(
                                        Icons.call_received_outlined, 'Request',
                                        () async {
/*                                  var response = await submit("_mint",[EthereumAddress.fromHex(user.address), BigInt.from(1000)]);
                                    print(response); */
                                      //TODO Show dialog with qr code of eth address of user
                                    }),
                                  ]),
                                  TableRow(children: [
                                    _actionList(Icons.money, 'Create Campaign',
                                        () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return CreateCampaign(user: user);
                                      }));
                                    }),
                                    _actionList(
                                        Icons.assignment_returned_outlined,
                                        'Invest in Campaigns', () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  CampaignList()));
                                    }),
                                  ]),
                                  TableRow(children: [
                                    _actionList(Icons.my_library_books_outlined,
                                        'My Campaigns', () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return MyCampaigns(
                                          address: user.address,
                                        );
                                      }));
                                    }),
                                    _actionList(
                                        Icons.add_business, 'My Investments',
                                        () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return MyInvestments(
                                          address: user.address,
                                        );
                                      }));
                                    }),
                                  ])
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).pLTRB(5, 5, 5, 0)
                  ],
                ),
        ),
      ),
    );
  }

// custom action widget
  Widget _actionList(IconData icon, String desc, Function tapFunction) {
    return GestureDetector(
      onTap: tapFunction,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, color: Colors.white, size: 40),
            SizedBox(
              height: 8,
            ),
            Text(
              desc,
              style: TextStyle(color: Colors.white),
            )
          ],
        ),
      ),
    );
  }
}
