part of connection_managers;

/// IdiLocalConnectionManager manages both connection and device-specific logic
class IdiLocalConnectionManager
    extends GenericLocalConnectionManager<IdiConnectorDevice> {
  IdiLocalConnectionManager._internal(device) : super._internal(device);

  // Assume glucose was calculated onboard until a manual calculation is done
  bool glucoseCalculatedOnBoard = true;

  DataPointSet currentSessionGlucoseSet =
      DataPointSet.empty(IdiDataTypes.continuousGlucose);
  DataPointSet currentSessionCalibrationSet =
      DataPointSet.empty(IdiDataTypes.calibrationPoint);
  DataPointSet currentSessionTemperatureSet =
      DataPointSet.empty(IdiDataTypes.temperature);
  DataPointSet currentSessionRawMeasurementSet =
      DataPointSet.empty(IdiDataTypes.rawVoltage);
  DataPointSet labRawMeasurementSet =
      DataPointSet.empty(IdiDataTypes.labRawMeasurement);

  /// Gets the index of the current raw measurement.
  int getRawMeasurementIndex() {
    return currentSessionRawMeasurementSet.values.length;
  }

  // Disconnect device
  @override
  Future<void> disconnectDevice() async {
    await ConnectorPluginPlatform.instance.disconnectDevice(device);

    if (device.bleConnectionState == BleConnectionState.connecting ||
        device.bleConnectionState == BleConnectionState.error) {
      // To prevent error states, instruct controller to remove this manager
      device.bleConnectionState = BleConnectionState.inactive;
      onConnectionEvent(
          LocalConnectionEvent(ConnectionEventType.deviceState, device));
    }
  }

  // Handle device event restoration
  @override
  void fromRestoredDevice(GenericConnectionEvent event) {
    if (event is LocalConnectionEvent) {
      retrieveSession(
          (event.device as IdiConnectorDevice).deviceState?.sessionId);
      super.fromRestoredDevice(event);
    } else {
      log("Unexcpectedly received non-local connection event in IdiLocalConnectionManager");
    }
  }

  // Start a CGM session
  Future<void> startSession(String sessionId, bool useDebugParams) async {
    await retrieveSession(sessionId);
    return await ConnectorPluginPlatform.instance
        .startCgmSession(device, sessionId, useDebugParams);
  }

  // Stop a CGM session
  Future<void> stopSession() async {
    return await ConnectorPluginPlatform.instance.stopCgmSession(device);
  }

  /// Retrieves the measurement session by session ID.
  Future<Map<String, DataPointSet>> retrieveSession(String? sessionId) async {
    log("Retrieving session: $sessionId");
    sessionId ??= device.deviceState?.sessionId;

    final session =
        await ConnectorPluginPlatform.instance.retrieveSession(sessionId);

    session.forEach((key, value) {
      if (key == IdiDataTypes.continuousGlucose.id) {
        // Convert from mg/dl to mmol/l if needed
        if (value.values.isNotEmpty && value.values.last.number! >= 39.0) {
          DataPointSet convertedSet =
              DataPointSet.empty(IdiDataTypes.continuousGlucose);
          value.values.forEach((element) {
            convertedSet.addDataPoint(DataPoint(
              dataType: IdiDataTypes.continuousGlucose,
              acquisitionTime:
                  value.acquisitionTimes[value.values.indexOf(element)],
              value: DataValue(number: element.number! / 18.018),
            ));
          });
          currentSessionGlucoseSet = convertedSet;
        } else {
          currentSessionGlucoseSet = value;
        }
      } else if (key == IdiDataTypes.calibrationPoint.id) {
        currentSessionCalibrationSet = value;
      } else if (key == IdiDataTypes.temperature.id) {
        currentSessionTemperatureSet = value;
      } else if (key == IdiDataTypes.rawVoltage.id) {
        currentSessionRawMeasurementSet = value;
      } else if (key == IdiDataTypes.labRawMeasurement.id) {
        labRawMeasurementSet = value;
      }
    });
    return session;
  }

  /// Clears the current open session.
  void clearOpenSession() {
    currentSessionGlucoseSet =
        DataPointSet.empty(IdiDataTypes.continuousGlucose);
    currentSessionCalibrationSet =
        DataPointSet.empty(IdiDataTypes.calibrationPoint);
    currentSessionTemperatureSet = DataPointSet.empty(IdiDataTypes.temperature);
    currentSessionRawMeasurementSet =
        DataPointSet.empty(IdiDataTypes.rawVoltage);
  }

  /// Adds a calibration point with the specified value.
  Future<void> addCalibration(double value, bool calibrateAll) async {
    final point = DataPoint(
      dataType: IdiDataTypes.calibrationPoint,
      acquisitionTime: DateTime.now(),
      value: DataValue(number: value),
      chunkName: device.deviceState?.sessionId,
    );

    ConnectorPluginPlatform.instance
        .addCalibration(device, point, calibrateAll);
  }

  /// Sets debug parameters for the device.
  Future<void> setDebugParameters(IdiDebugParameters params) async {
    return ConnectorPluginPlatform.instance.setDebugParameters(device, params);
  }

  /// Sets production parameters for the device.
  Future<void> setProductionParameters(IdiProductionParameters data) async {
    return await ConnectorPluginPlatform.instance
        .setProductionParameters(device, data);
  }

  /// Reads production parameters from the device.
  Future<void> readProductionParameters() async {
    return await ConnectorPluginPlatform.instance
        .readProductionParameters(device);
  }

  /// Adds a data point to the session.
  Future<void> addDataPoint(DataTypeInfo dataType, DataValue value,
      DateTime acquisitionTime, String? sessionId) async {
    final point = DataPoint(
      dataType: dataType,
      chunkName: sessionId ?? device.deviceState?.sessionId,
      acquisitionTime: acquisitionTime,
      transmitterDevice: device.toTransmitterDeviceJson(),
      value: value,
    );

    ConnectorPluginPlatform.instance.addDataPoint(point);
  }

  Future<void> addNote(String title, {String? description, double? carbs}) {
    final value = DataValue(map: {"title": title});
    if (description != null) {
      value.map!["description"] = description;
    }
    if (carbs != null) {
      value.map!["carbs"] = carbs;
    }
    return addDataPoint(IdiDataTypes.userEvent, value, DateTime.now(),
        device.deviceState?.sessionId);
  }

  /// Adds a lab raw measurement to the session.
  Future<void> addLabRawMeasurement(
      DataPoint measurement,
      String name,
      String note,
      String debugParams,
      String sessionId,
      double? temperature) async {
    labRawMeasurementSet.addDataPoint(DataPoint(
      dataType: IdiDataTypes.labRawMeasurement,
      acquisitionTime: measurement.acquisitionTime,
      value: DataValue(map: {
        "name": name,
        "note": note,
        "params": debugParams,
        "value": measurement.value.numbers.toString(),
        "temperature": temperature
      }),
      chunkName: sessionId,
      transmitterDevice: device.toTransmitterDeviceJson(),
    ));

    return await addDataPoint(
      IdiDataTypes.labRawMeasurement,
      DataValue(map: {
        "name": name,
        "note": note,
        "params": debugParams,
        "value": measurement.value.numbers.toString(),
        "temperature": temperature
      }),
      measurement.acquisitionTime,
      sessionId,
    );
  }

  @override
  dynamic onConnectionEvent(GenericConnectionEvent event) {
    if (event.eventType == ConnectionEventType.data) {
      log("Received data event: ${event.dataPoint!.dataType.id}");
      switch (event.dataPoint!.dataType) {
        case IdiDataTypes.continuousGlucose:
          // Convert from mg/dl to mmol/l
          if (event.dataPoint!.value.number! >= 39.0) {
            DataPoint convertedPoint = DataPoint(
              dataType: IdiDataTypes.continuousGlucose,
              acquisitionTime: event.dataPoint!.acquisitionTime,
              value: DataValue(number: event.dataPoint!.value.number! / 18.018),
            );
            currentSessionGlucoseSet.addDataPoint(convertedPoint);
          } else {
            currentSessionGlucoseSet.addDataPoint(event.dataPoint!);
          }
          break; // Add break statement
        case IdiDataTypes.calibrationPoint:
          currentSessionCalibrationSet.addDataPoint(event.dataPoint!);
          break; // Add break statement
        case IdiDataTypes.temperature:
          currentSessionTemperatureSet.addDataPoint(event.dataPoint!);
          break; // Add break statement
        case IdiDataTypes.rawVoltage:
          currentSessionRawMeasurementSet.addDataPoint(event.dataPoint!);
          break; // Add break statement
      }
    }
    super.onConnectionEvent(event);
  }

  @override
  GenericConnectionInfo<GenericConnectionManager> createConnectionInfo() {
    return IdiConnectionInfo(this);
  }
}
