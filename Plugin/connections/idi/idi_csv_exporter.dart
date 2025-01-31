import 'dart:developer';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sen_gs_1_ca_connector_plugin/connection_manager_controller.dart';

extension IdiCsvExporter on IdiLocalConnectionManager {
  Future<void> exportDebugSession(String sessionId) async {
    // Measurements
    List<List<dynamic>> expandedMeasurements = [];

    expandedMeasurements.add(<String>["measurementName"]); // Names
    expandedMeasurements.add(<String>["note"]); // Notes
    expandedMeasurements.add(<String>["params"]); // Parameters
    expandedMeasurements.add(<String>["time"]); // AcquisitionTimes
    expandedMeasurements.add(<dynamic>["T (°C)"]); // Temperatures

    log("Exporting ${labRawMeasurementSet.values.length} measurements");

    // For each lab measurement
    for(var (index, measurement) in labRawMeasurementSet.values.indexed) {
      // Create a new column
      expandedMeasurements[0].add(measurement.map?["name"].toString());
      expandedMeasurements[1].add(measurement.map?["note"].toString());
      expandedMeasurements[2].add(measurement.map?["params"].toString());
      expandedMeasurements[3].add(labRawMeasurementSet.acquisitionTimes[index].toIso8601String());
      expandedMeasurements[4].add(measurement.map?["temperature"] ?? "");

      if (measurement.map?["value"] is String) {
        // Convert to double list, we get this when we have retrieved the session from datastore
        String valueString = measurement.map?["value"] as String;
        valueString = valueString.replaceAll('[', '').replaceAll(']', ''); // Remove square brackets
        measurement.map?["value"] = valueString.split(",").map((e) => double.parse(e)).toList();
      }
      for (final (j, sample) in (measurement.map?["value"] as List<double>).indexed) {
        if (expandedMeasurements.length > j+5) {
          log("Adding to existing row with length ${expandedMeasurements[j+4].length} at index $index");
          // Add new sample with correct null padding
          expandedMeasurements[j+5] += List<dynamic>.filled(index + 1 - expandedMeasurements[j+5].length, null) + [sample];
        } else {
          log("Making new row with left padding ${index + 1}");
          // Add new sample# row with correct sample number
          expandedMeasurements.add([j, ...List<dynamic>.filled(index, ""), sample]);
        }
      }
    }

    String measCsv = const ListToCsvConverter(fieldDelimiter: ";").convert(
        expandedMeasurements);
    final measFile =
    await _localFile(namePrefix: sessionId);
    measFile.writeAsString(measCsv);

    // Send email
    final Email email = Email(
      body:
      "Good luck with the analysis and have a good day! \n\nBest regards, \nidi",
      subject: 'Session CSV | $sessionId',
      recipients: [''],
      attachmentPaths: [measFile.absolute.path],
      isHTML: false,
    );

    await FlutterEmailSender.send(email);
  }

  Future<String> get _localPath async {
    final directory = await getTemporaryDirectory();
    return directory.absolute.path;
  }

  Future<File> _localFile({String namePrefix = "data"}) async {
    final path = await _localPath;
    return File('$path/$namePrefix.csv');
  }
}