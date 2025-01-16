import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sen_gs_1_ca_companion_application/cubit/connections_cubit.dart';
import 'package:sen_gs_1_ca_companion_application/views/guide/guide_page_model.dart';
import 'package:sen_gs_1_ca_companion_application/views/guide/guide_page_pairing.dart';
import 'package:sen_gs_1_ca_companion_application/views/guide/guide_page_template.dart';
import 'package:sen_gs_1_ca_companion_application/views/connection/ble_device_addition_view.dart';
import 'package:sen_gs_1_ca_connector_plugin/constant/sensible_colors.dart';
import 'package:sen_gs_1_ca_connector_plugin/connection_manager_controller.dart';


class GuideWidget extends StatefulWidget {
  final ScrollPhysics physics;
  final List<Map<String, dynamic>> jsonGuidePages;

  GuideWidget({
    Key? key,
    this.physics = const AlwaysScrollableScrollPhysics(),
    required this.jsonGuidePages,
  }) : super(key: key);

  final nfcManager = ConnectionManagerController.createNfcManager();
  final bluetoothManager = ConnectionManagerController.createDeviceScanner();

  @override
  GuideWidgetState createState() => GuideWidgetState();
}

class GuideWidgetState extends State<GuideWidget> {
  final PageController _pageController = PageController();
  int currentPage = 0;
  late List<GuidePageModel> guidePages;
  GuidePagePairing? pairingManager;
  bool skipGuide = false;

  @override
  void initState() {
    super.initState();
    guidePages = widget.jsonGuidePages
        .map((json) => GuidePageModel.fromJson(json))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // Access the ConnectionsCubit using context.read
    final connectionsCubit = context.read<ConnectionsCubit>();

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            physics: widget.physics,
            onPageChanged: (index) {
              setState(() {
                currentPage = index;
                _handlePageChange(index);
              });
            },
            itemCount: guidePages.length,
            itemBuilder: (context, index) {
              final page = guidePages[index];

              // Check if it's the "ConnectToApp" page and use ValueListenableBuilder for description
              if (page.page == "ConnectToApp" && pairingManager != null) {
                return ValueListenableBuilder<bool>(
                  valueListenable: pairingManager!.connectionFound,
                  builder: (context, connectionFound, _) {
                    return ValueListenableBuilder<String?>(
                      valueListenable: pairingManager!.pin,
                      builder: (context, pinValue, _) {
                        if (connectionFound) {
                          return Center(
                            child: Container(
                              color: CupertinoColors.systemGroupedBackground,
                              width: double.infinity,
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Connecting...",
                                  ),
                                  const SizedBox(height: 16.0),
                                  const CircularProgressIndicator(),
                                  const SizedBox(height: 16.0),
                                  if (pinValue != null)
                                    Text("Pin: $pinValue",
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          );
                        }

                        return GuidePageTemplate(
                          imageAsset: page.image?.assetPath ?? '',
                          title: page.content.title,
                          description: page.content.description,
                          pageNumber: page.pageIndicator ?? 0,
                        );
                      },
                    );
                  },
                );
              } else {
                // For all other pages, use the regular description
                return GuidePageTemplate(
                  imageAsset: page.image?.assetPath ?? '',
                  title: page.content.title,
                  description: page.content.description,
                  pageNumber: page.pageIndicator ?? 0,
                );
              }
            },
          ),
        ),
        _buildBottomButtons(connectionsCubit),
      ],
    );
  }

  void _handlePageChange(int index) {
    final targetPageName = guidePages[index].page;
    final connectionsCubit = context.read<ConnectionsCubit>();

    if (targetPageName == "ConnectToApp") {
      if (pairingManager == null) {
        pairingManager = GuidePagePairing(
          nfcManager: widget.nfcManager,
          connectionsCubit: connectionsCubit,
          pageController: _pageController,
          context: context,
        );

        pairingManager!.startNfcPairing();
      }
    } else {
      if (pairingManager != null) {
        pairingManager!.stopNfcPairing();
        pairingManager!.dispose();
        pairingManager = null;
      }
    }
  }

  Widget _buildBottomButtons(ConnectionsCubit connectionsCubit) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 24.0),
      width: double.infinity,
      color: CupertinoColors.systemGroupedBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (guidePages[currentPage].page == "StartOfGuide") ...[
            _buildSkipGuideButton(),
            const SizedBox(height: 6),
            _buildBluetoothButton(connectionsCubit),
            const SizedBox(height: 6),
          ],
          if (guidePages[currentPage].page == "ConnectToApp") ...[
            const SizedBox(
              child: Center(
                child: Text(
                  "Scan Sensor to Continue",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ] else ...[
            SizedBox(
              child: CupertinoButton(
                onPressed: _nextPage,
                color: SensibleColors.sensibleDeepBlue,
                borderRadius: BorderRadius.circular(8),
                child: Center(
                  child: Text(
                    currentPage == 0
                        ? "Guided Application"
                        : (currentPage == guidePages.length - 1
                            ? "Finish"
                            : "Next"),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBluetoothButton(ConnectionsCubit connectionsCubit) {
    return BlocBuilder<ConnectionsCubit, ConnectionsState>(
      bloc: connectionsCubit,
      builder: (context, state) {
        String buttonText = "Bluetooth Device Setup";

        return Container(
          decoration: BoxDecoration(
              border: Border.all(color: CupertinoColors.systemGrey, width: 2),
              borderRadius: BorderRadius.circular(8)),
          child: CupertinoButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                BleDeviceAdditionView.nativeRoute(connectionsCubit),
              );
            },
            color: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              buttonText,
              style: const TextStyle(
                color: CupertinoColors.systemGrey,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkipGuideButton() {
    const targetPageName = "ConnectToApp";
    final connectToAppIndex =
        guidePages.indexWhere((page) => page.page == targetPageName);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: CupertinoColors.systemGrey, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CupertinoButton(
        onPressed: () {
          if (connectToAppIndex != -1) {
            _pageController.jumpToPage(connectToAppIndex);
            pairingManager?.skipGuidePressed.value = true;
            skipGuide = true;
          } else {
            _showPageNotFoundDialog(targetPageName);
          }
        },
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: const Text(
          "NFC Device Setup",
          style: TextStyle(
            color: CupertinoColors.systemGrey,
          ),
        ),
      ),
    );
  }

  void _nextPage() {
    if (pairingManager != null) {
      pairingManager!.dispose();
      pairingManager = null;
    }

    if (currentPage < guidePages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  void previousPage() {
    if (pairingManager != null) {
      pairingManager!.dispose();
      pairingManager = null;
    }

    if (skipGuide) {
      skipGuide = false;
      _pageController.jumpToPage(0);
    }

    if (currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  void _showPageNotFoundDialog(String targetPageName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Page Not Found"),
          content: Text(
              "The page '$targetPageName' does not exist. Please check the guide or proceed with the steps."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    if (pairingManager != null) {
      pairingManager!.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }
}

// Wrap the GuideWidget with BlocProvider
class GuideWidgetWrapper extends StatelessWidget {
  final List<Map<String, dynamic>> jsonGuidePages;

  const GuideWidgetWrapper({super.key, required this.jsonGuidePages});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ConnectionsCubit>(
      create: (context) => ConnectionsCubit(),
      child: GuideWidget(jsonGuidePages: jsonGuidePages),
    );
  }
}
