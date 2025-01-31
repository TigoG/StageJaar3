part of connection_managers;

class GenericDeviceScanner {
  GenericDeviceScanner._();

  late Stream<List<GenericConnectorDevice>> _scanningStream;

  /// Returns a [Stream] that, when listened to, instructs the system to start
  /// scanning for devices of type [connectionId].
  /// By default scans for SEN-GS-1 (idi one) devices
  Future<Stream<List<GenericConnectorDevice>>> startScan(
      {String connectionId = "SEN-GS-1"}) async {
    await _ensurePermissions();

    final StreamController<List<GenericConnectorDevice>> streamController =
        StreamController.broadcast(
            onListen: () async => await ConnectorPluginPlatform.instance
                .startScanning(connectionId),
            onCancel: () => stopScan());

    _scanningStream = const EventChannel("connectorPlugin/scanningEvents")
        .receiveBroadcastStream()
        .map((rawList) => ConnectorDeviceFactory.fromJsonArray(rawList))
        .handleError((error) => throw error);

    streamController
        .addStream(_scanningStream)
        .then((value) => streamController.close());

    return streamController.stream;
  }

  /// Closes the scanning stream and instructs the system to stop all scanning
  /// (including any other scans that may be ongoing)
  Future<void> stopScan() async {
    await ConnectorPluginPlatform.instance.stopScanning();
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
