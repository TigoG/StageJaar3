import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sen_gs_1_ca_companion_application/cubit/connections_cubit.dart';
import 'package:sen_gs_1_ca_connector_plugin/connection_manager_controller.dart';
import 'package:sen_gs_1_ca_connector_plugin/models/device/generic_connector_device.dart';
import 'package:sen_gs_1_ca_connector_plugin/constant/sensible_colors.dart';

class GuidePagePairing {
  final GenericNfcManager nfcManager;
  final ConnectionsCubit connectionsCubit;
  final PageController pageController;
  final BuildContext context;

  bool isPopupVisible = false;
  ValueNotifier<bool> deviceConnectionFound = ValueNotifier(false);
  ValueNotifier<bool> isConnecting = ValueNotifier(false);
  ValueNotifier<String?> pin = ValueNotifier(null);
  ValueNotifier<bool> skipGuidePressed = ValueNotifier(false);
  ValueNotifier<bool> connectionFound = ValueNotifier(false);

  GenericLocalConnectionManager? newDeviceManager;
  StreamSubscription? deviceConnectionSubscription;
  StreamSubscription? connectionSubscription;

  GuidePagePairing({
    required this.nfcManager,
    required this.connectionsCubit,
    required this.pageController,
    required this.context,
  });

  Future<void> startNfcPairing() async {
    if (isConnecting.value) {

      return;
    }
    isConnecting.value = true;
    try {
      nfcManager.startNfcPairing();
      _listenToDeviceConnections();
    } catch (e) {
      isConnecting.value = false;
      _showSnackBar('NFC pairing failed: $e');
    }
  }

  void stopNfcPairing() {
    if (!isConnecting.value) {
      return;
    }
    try {
      nfcManager.stopNfcPairing();
      isConnecting.value = false;
    } catch (e) {
      _showSnackBar('Failed to stop NFC pairing: $e');
    }
  }

  void _listenToDeviceConnections() {
    deviceConnectionSubscription = connectionsCubit.connectionManagerController.deviceConnectionsStream.listen(
      (deviceManagers) {
        if (deviceManagers.isNotEmpty) {
          newDeviceManager = deviceManagers.values.last;

          if (newDeviceManager != null) {
            connectionSubscription = newDeviceManager!.deviceEventStream?.listen(
              (event) {
                switch (event.device.bleConnectionState) {
                  case BleConnectionState.connecting:
                    _handleConnectingState(event.device);
                    connectionFound.value = true;
                    break;
                  case BleConnectionState.connected:
                    _handleConnectedState();
                    break;
                  case BleConnectionState.error:
                    _handleErrorState(event.device);
                    connectionFound.value = false;
                    break;
                  default:
                    connectionFound.value = false;
                    break;
                }
              },
            );
          }
        }
      },
    );
  }

  void _handleConnectingState(GenericConnectorDevice device) {
    deviceConnectionFound.value = true;
    isConnecting.value = true;
    if (isPopupVisible) {
      isPopupVisible = false;
      Navigator.of(context).pop();
    }
    if (Platform.isIOS) {
      final serial = device.name.length > 9
          ? int.tryParse(device.name.substring(9))
          : null;
      if (serial != null) {
        var code = (130000 + serial) % 1000000;
        pin.value = code.toString();
      }
    }
  }

  void _handleConnectedState() {
    isConnecting.value = false;
    if(skipGuidePressed.value) {
      Navigator.of(context).pop();
      skipGuidePressed.value = false;
    }
    pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  void _handleErrorState(GenericConnectorDevice device) {
    isConnecting.value = false;
    deviceConnectionFound.value = false;
    isPopupVisible = true;
    _showErrorDialog(device.errorMessage ?? "An error occurred while connecting to the device.");
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Error Occurred",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: double.infinity,
            child: Text(
              error,
              style: const TextStyle(fontSize: 18),
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: SensibleColors.sensibleDeepBlue,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      isPopupVisible = false;
                    },
                    child: const Text(
                      "Try Again",
                      style: TextStyle(
                        fontSize: 18,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }


  void dispose() {
    if (isConnecting.value) {
      stopNfcPairing();
    }

    if (newDeviceManager?.device.bleConnectionState !=
        BleConnectionState.connected) {
      newDeviceManager?.disconnectDevice();
    }

    deviceConnectionSubscription?.cancel();
    connectionSubscription?.cancel();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
