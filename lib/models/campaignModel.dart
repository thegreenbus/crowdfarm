import 'package:cloud_firestore/cloud_firestore.dart';

class CampaignModel {
  final String campaignName; //firebase
  final String image; //firebase
  final String campaignDescription; //firebase
  final String publisherAddress;
  final int totalAmount;
  final int id;
  final bool finished;
  final bool showInList;
  final int ownedByInvestorTotal;
  Map<String, Investment> ownership;

  CampaignModel(
      {this.campaignName,
      this.finished,
      this.id,
      this.ownedByInvestorTotal,
      this.ownership,
      this.publisherAddress,
      this.totalAmount,
      this.campaignDescription,
      this.image,
      this.showInList});

  factory CampaignModel.fromDocument(DocumentSnapshot doc) {
    return CampaignModel(
        campaignName: doc['campaignName'],
        publisherAddress: doc['publisherAddress'],
        totalAmount: doc['totalAmount'].toInt(),
        id: doc['CampaignId'],
        finished: doc['finished'],
        ownedByInvestorTotal: doc['ownedByInvestorTotal'].toInt(),
        ownership: doc['ownership'],
        campaignDescription: doc['campaignDescription'],
        image: doc['image'],
        showInList: doc['shownInList']);
  }

  Map<String, dynamic> toMap() {
    return {
      'campaignName': campaignName,
      'publisherAddress': publisherAddress,
      'totalAmount': totalAmount,
      'CampaignId': id,
      'finished': finished,
      'ownedByInvestorTotal': ownedByInvestorTotal,
      'ownership': ownership,
      'image': image,
      'campaignDescription': campaignDescription,
      'shownInList': showInList
    };
  }
}

class Investment {
  String investor;
  int investAmount;
  int ownershipPercent;
  int intrest;
  bool isPaid;
  DateTime startDate; // dont know what blockchain will return
}
