part of connection_managers;

class GenericNfcManager {
  GenericNfcManager._();

  void startNfcPairing() async {
    await _ensurePermissions();
    await ConnectorPluginPlatform.instance.startNfcPairing();
    return;
  }

  void stopNfcPairing() async {
    await ConnectorPluginPlatform.instance.stopNfcPairing();
  }

  Future<void> _ensurePermissions() async {
    // Check Bluetooth permissions (for Android 12 and above)
    var bluetoothStatus = await Permission.bluetooth.status;
    if (!bluetoothStatus.isGranted) {
      await Permission.bluetooth.request();
    }

    // Check Bluetooth scan permissions (for Android 12 and above)
    var bluetoothScanStatus = await Permission.bluetoothScan.status;
    if (!bluetoothScanStatus.isGranted) {
      await Permission.bluetoothScan.request();
    }

    // Check Bluetooth connect permissions (for Android 12 and above)
    var bluetoothConnectStatus = await Permission.bluetoothConnect.status;
    if (!bluetoothConnectStatus.isGranted) {
      await Permission.bluetoothConnect.request();
    }

    // Check location permissions (necessary for Bluetooth scanning on Android versions below 12)
    var locationStatus = await Permission.location.status;
    if (!locationStatus.isGranted) {
      await Permission.location.request();
    }
  }
}
