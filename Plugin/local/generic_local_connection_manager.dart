part of connection_managers;

/// Contains scanning, connection, and control functions for a single peripheral
/// of non-specified device type, as well as streams to receive device and data
/// updates.
abstract class GenericLocalConnectionManager<T extends GenericConnectorDevice>
    extends GenericConnectionManager {
  GenericLocalConnectionManager._internal(this.device) : super._internal();

  factory GenericLocalConnectionManager._(T device) {
    if (device is IdiConnectorDevice) {
      // Return an instance of the specific subclass `IdiConnectionManager`
      return IdiLocalConnectionManager._internal(device)
          as GenericLocalConnectionManager<T>;
    } else {
      // Throw an error or guide towards creating an appropriate concrete subclass
      throw UnsupportedError('Cannot instantiate an abstract class directly.');
    }
  }

  T device;

  @override
  StreamController<LocalConnectionEvent> get _connectionEventController =>
      StreamController<LocalConnectionEvent>.broadcast(onListen: () async {
        if (device.bleConnectionState == BleConnectionState.inactive) {
          await ConnectorPluginPlatform.instance.connectToDevice(device);
        }
      });

  Future<void> disconnectDevice();

  Future<Stream<LocalConnectionEvent>> connectToDevice() async {
    return _connectionEventController.stream;
  }

  Stream<LocalConnectionEvent>? get deviceEventStream =>
      _connectionEventController.stream;

  void fromRestoredDevice(LocalConnectionEvent event) {
    _connectionEventController = StreamController.broadcast();
    device = event.device as T;
    _connectionEventController.add(event);
  }

  @override
  void onConnectionEvent(GenericConnectionEvent event) {
    if (event is LocalConnectionEvent<T>) {
      device = event.device;
    }
    super.onConnectionEvent(event);
  }
}
