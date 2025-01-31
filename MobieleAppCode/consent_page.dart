import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sen_gs_1_ca_connector_plugin/constant/sensible_colors.dart';
import 'package:sen_gs_1_ca_connector_plugin/constant/sensible_defaults.dart';
import 'package:sen_gs_1_ca_connector_plugin/trendi_tiles/idi/consent_controls/consent_control.dart';
import 'package:sen_gs_1_ca_connector_plugin/trendi_tiles/idi/consent_controls/consent_control_info.dart';

class ConsentPage extends StatelessWidget {
  final ConsentTileInfo tileInfo;
  final String userId;

  const ConsentPage({Key? key, required this.tileInfo, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(130.0),
        child: Container(
          decoration: const BoxDecoration(
            color: CupertinoColors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 3.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: CupertinoColors.white,
            leading: IconButton(
              color: SensibleColors.sensibleDeepBlue,
              icon: const Icon(Icons.arrow_back_ios_new_sharp),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            title: Column(
              children: [
                SizedBox(
                  height: 47,
                  child: Image.asset("assets/img/trendi_logo.png"),
                ),
                SizedBox(height: SensibleDefaults.getVerticalSpacing(context)),
                const Text(
                  "Trendi External Link",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                ),
              ],
            ),
            toolbarHeight: 130,
            centerTitle: true,
            elevation: 0,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Expanded Trendi Tile Content
            Expanded(
              child: ConsentTile(tileInfo, userId: userId,),
            ),
          ],
        ),
      ),
    );
  }
}
