List<Widget> _buildDebugParameterList() {
  List<Widget> result = [];

  result.add(CupertinoListTile(
    title: Text(LocalizationService.getString("debug_parameters", "battery_level")),
    trailing: Text("${widget.info.deviceManager.device.deviceState?.batteryLevel.toString() ?? "-"} %"),
    backgroundColor: CupertinoColors.systemGroupedBackground,
  ));

  result.add(CupertinoListTile(
    title: Text(LocalizationService.getString("debug_parameters", "temperature")),
    trailing: Text("${widget.info.deviceManager.currentSessionTemperatureSet.values.isNotEmpty ? widget.info.deviceManager.currentSessionTemperatureSet.values.last.number?.toStringAsFixed(2) : "-"} °C"),
    backgroundColor: CupertinoColors.systemGroupedBackground,
  ));

  final biasSetting = widget.info.deviceManager.device.deviceState?.debugParameters?.biasSetting;
  final biasText = IdiDebugParameters.biasOptions.containsKey(biasSetting)
      ? IdiDebugParameters.biasOptions[biasSetting] ?? 'Unknown'
      : 'Unknown';

  result.add(CupertinoListTile(
    title: Text(LocalizationService.getString("debug_parameters", "bias_setting")),
    trailing: Text(biasText),
    backgroundColor: CupertinoColors.systemGroupedBackground,
  ));

  result.add(CupertinoListTile(
    title: Text(LocalizationService.getString("debug_parameters", "sampling_frequency")),
    trailing: Text(widget.info.deviceManager.device.deviceState?.debugParameters?.samplingFrequency.toString() ?? "Unknown"),
    backgroundColor: CupertinoColors.systemGroupedBackground,
  ));

  result.add(CupertinoListTile(
    title: Text(LocalizationService.getString("debug_parameters", "n_samples")),
    trailing: Text(widget.info.deviceManager.device.deviceState?.debugParameters?.nSamples.toString() ?? "Unknown"),
    backgroundColor: CupertinoColors.systemGroupedBackground,
  ));

  result.add(CupertinoListTile(
    title: Text(LocalizationService.getString("debug_parameters", "measurement_interval")),
    trailing: Text(widget.info.deviceManager.device.deviceState?.debugParameters?.measurementInterval.toString() ?? "Unknown"),
    backgroundColor: CupertinoColors.systemGroupedBackground,
  ));

  result.add(CupertinoListTile(
    title: Text(LocalizationService.getString("debug_parameters", "continuous_mode")),
    trailing: Text(widget.info.deviceManager.device.deviceState?.debugParameters?.continuousModeEnabled.toString() ?? "Unknown"),
    backgroundColor: CupertinoColors.systemGroupedBackground,
  ));
  return result;
}