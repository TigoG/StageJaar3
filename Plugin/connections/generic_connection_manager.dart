part of connection_managers;

abstract class GenericConnectionManager {
  GenericConnectionManager._internal();

  late StreamController<GenericConnectionEvent> _connectionEventController;

  GenericConnectionInfo createConnectionInfo();

  void onConnectionEvent(GenericConnectionEvent event) {
    _connectionEventController.add(event);
  }
}
