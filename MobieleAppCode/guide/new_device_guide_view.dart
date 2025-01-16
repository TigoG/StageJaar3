import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sen_gs_1_ca_companion_application/cubit/connections_cubit.dart';
import 'package:sen_gs_1_ca_companion_application/views/guide/guide_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sen_gs_1_ca_connector_plugin/constant/sensible_colors.dart';

class NewDeviceGuideView extends StatefulWidget {
  const NewDeviceGuideView({Key? key}) : super(key: key);

  static Route nativeRoute(ConnectionsCubit connectionsCubit) {
    return MaterialPageRoute(
      builder: (context) => BlocProvider.value(
        value: connectionsCubit,
        child: const NewDeviceGuideView(),
      ),
    );
  }

  @override
  State<StatefulWidget> createState() => _NewDeviceGuideViewState();
}

class _NewDeviceGuideViewState extends State<NewDeviceGuideView> {
  final GlobalKey<GuideWidgetState> _guideKey = GlobalKey<GuideWidgetState>();
  late Future<List<Map<String, dynamic>>> _jsonPagesFuture;

  @override
  void initState() {
    super.initState();
    _jsonPagesFuture = _loadJsonData();
  }

  Future<List<Map<String, dynamic>>> _loadJsonData() async {
    try {
      final jsonString = await rootBundle.loadString('assets/guide_pages_data.json');
      final List<dynamic> jsonResponse = json.decode(jsonString);
      return jsonResponse.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        foregroundColor: CupertinoColors.systemGrey,
        title: const Text("Connect New Sensor"),
        backgroundColor: CupertinoColors.systemGroupedBackground,
        leading: IconButton(
          color: SensibleColors.sensibleDeepBlue,
          icon: const Icon(Icons.arrow_back_ios_new_sharp),
          onPressed: () {
            if (_guideKey.currentState?.currentPage == 0) {
              Navigator.of(context).pop();
            } else {
              _guideKey.currentState?.previousPage();
            }
          },
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _jsonPagesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data?.isEmpty == true) {
            // Show an error message and provide a way to go back
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Error loading data or no data available',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CupertinoButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    color: SensibleColors.sensibleDeepBlue,
                    child: const Text(
                      'Go Back',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData) {
            final jsonPages = snapshot.data!;
            return GuideWidget(
              key: _guideKey,
              physics: const NeverScrollableScrollPhysics(),
              jsonGuidePages: jsonPages,
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
