import 'package:sen_gs_1_ca_connector_plugin/connection_manager_controller.dart';
import 'package:sen_gs_1_ca_connector_plugin/models/device/generic_connector_device.dart';
import 'package:sen_gs_1_ca_connector_plugin/models/device/generic_connector_device_state.dart';
import 'package:sen_gs_1_ca_connector_plugin/models/trendi_tile_info.dart';
import 'package:sen_gs_1_ca_connector_plugin/trendi_tiles/idi/consent_controls/consent_control.dart';

class ConsentTileInfo extends TrendiTileInfo {
  ConsentTileInfo() : super();

  bool _isActive = true;

  @override
  bool get isActive => _isActive;

  @override
  set isActive(bool value) {
    _isActive = value;
    saveState();
  }

  @override
  final bool isLocked = false;

  @override
  bool requiredConnectionsActive() => true;

  @override
  String tileName = "Consent Management";

  @override
  ConsentTile buildContent() {
    return ConsentTile(this, userId: '',);
  }
  
  @override
  GenericLocalConnectionManager<GenericConnectorDevice<GenericConnectorDeviceState>> get deviceManager => throw UnimplementedError();
}
