import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:crowdfarm/models/campaignModel.dart';
import 'package:crowdfarm/pages/myCampaignSingle.dart';
import 'package:velocity_x/velocity_x.dart';

class MyCampaigns extends StatefulWidget {
  final String address;
  MyCampaigns({this.address});
  @override
  _MyCampaignsState createState() => _MyCampaignsState();
}

class _MyCampaignsState extends State<MyCampaigns> {
  Future getCampaigns() async {
    final x = await FirebaseFirestore.instance
        .collection('campaigns')
        .where('shownInList', isEqualTo: true)
        .where('publisherAddress', isEqualTo: widget.address)
        .get();
    return x.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Vx.gray200,
      appBar: AppBar(
        backgroundColor: Vx.red500,
        title: "My Campaigns".text.white.make(),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: getCampaigns(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(child: SpinKitWave(color: Colors.red, size: 55));
          } else if (snap.data == null) {
            return Center(
                child: "NO Campaign found"
                    .text
                    .size(20) //TODO  CREATE PAGE FOR NO CAMPIGN
                    .bold
                    .red500
                    .makeCentered());
          } else {
            return ListView.builder(
              itemCount: snap.data.length,
              itemBuilder: (context, index) {
                CampaignModel campaign =
                    CampaignModel.fromDocument(snap.data[index]);
                final x = FirebaseFirestore.instance
                    .collection('users')
                    .doc(campaign.publisherAddress)
                    .get();
                return GestureDetector(
                  onTap: () {
                    /* Navigator.push(context, MaterialPageRoute(builder:(context)=>Campaign(campaignModel: campaign,))); */
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MyCampaignSingle(
                                  campaign: campaign,
                                )));
                  },
                  child: VxBox(
                      child: VStack([
                    CachedNetworkImage(
                      fadeInDuration: Duration(seconds: 1),
                      fit: BoxFit.fitWidth,
                      imageUrl: campaign.image,
                      imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      )),
                      placeholder: (context, url) =>
                          SpinKitWave(color: Colors.red, size: 25).shimmer(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ).h(200),
                    (15).heightBox,
                    Align(
                        alignment: Alignment.centerLeft,
                        child: "${campaign.campaignName}"
                            .text
                            .size(25)
                            .bold
                            .maxLines(2)
                            .make()
                            .px24()),
                    (15).heightBox,
                    Align(
                        alignment: Alignment.centerLeft,
                        child: "${campaign.campaignDescription}"
                            .text
                            .size(18)
                            .normal
                            .maxLines(2)
                            .overflow(TextOverflow.ellipsis)
                            .make()
                            .px24()),
                    (10).heightBox,
                    HStack(
                      [
                        Row(
                          children: [
                            Icon(Icons.monetization_on, color: Vx.red500),
                            (4).widthBox,
                            "${campaign.totalAmount} GEN"
                                .text
                                .red500
                                .size(18)
                                .semiBold
                                .make(),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.people,
                              color: Colors.grey[800],
                            ),
                            (4).widthBox,
                            "${campaign.ownedByInvestorTotal}% donated"
                                .text
                                .black
                                .size(18)
                                .semiBold
                                .make(),
                          ],
                        ),
                      ],
                      alignment: MainAxisAlignment.spaceBetween,
                      axisSize: MainAxisSize.max,
                    ).px24(),
                    (10).heightBox,
                    FutureBuilder(
                      future: x,
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return "Awaiting trust"
                              .text
                              .semiBold
                              .size(20)
                              .gray700
                              .make()
                              .shimmer();
                        } else
                          return "Trust Score:${snap.data.data()['score']}"
                              .text
                              .semiBold
                              .size(22)
                              .green500
                              .make();
                      },
                    ).centered(),
                    (10).heightBox,
                  ])).rounded.white.shadow.make().p8(),
                );
              },
            );
          }
        },
      ),
    );
  }
}
