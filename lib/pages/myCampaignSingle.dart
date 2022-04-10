import 'package:flutter/material.dart';
import 'package:crowdfarm/models/campaignModel.dart';
import 'package:crowdfarm/pages/allLedgers.dart';
import 'package:crowdfarm/pages/approvalPage.dart';

class MyCampaignSingle extends StatefulWidget {
  final CampaignModel campaign;
  MyCampaignSingle({this.campaign});
  @override
  _MyCampaignSingleState createState() => _MyCampaignSingleState();
}

class _MyCampaignSingleState extends State<MyCampaignSingle> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: index,
          backgroundColor: Color(0xFF352740),
          selectedItemColor: Colors.purpleAccent,
          unselectedItemColor: Colors.white,
          onTap: (val) {
            setState(() {
              index = val;
            });
          },
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt),
              label: 'Ledgers',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.approval),
              label: 'Approvals',
            ),
          ]),
      body: index == 0
          ? AllLedgers(widget.campaign)
          : ApprovalPage(
              campaign: widget.campaign,
            ),
    );
  }
}
