import 'dart:math';
import 'dart:developer' as dev;

import 'package:sen_gs_1_ca_connector_plugin/connection_manager_controller.dart';
import 'package:sen_gs_1_ca_connector_plugin/models/data/data_point.dart';
import 'package:sen_gs_1_ca_connector_plugin/models/data/data_value.dart';
import 'package:tuple/tuple.dart';
import 'package:sen_gs_1_ca_connector_plugin/models/device/idi/idi_data_types.dart';

extension IdiLocalCalibrator on IdiLocalConnectionManager {
  List<DataPoint> getCurrentSessionCalibratedGlucose() {
    return currentSessionGlucoseSet.toList();
  }

  DataPoint? getLatestRawMeasurement() {
    if (currentSessionRawMeasurementSet.values.isEmpty) {
      return null;
    }
    return DataPoint(
        dataType: IdiDataTypes.rawVoltage,
        value: DataValue(
            numbers: currentSessionRawMeasurementSet.values.last.numbers),
        acquisitionTime: currentSessionRawMeasurementSet.acquisitionTimes.last);
  }

  List<DataPoint> getLatestRawMeasurements(int amount) {
    if (currentSessionRawMeasurementSet.values.isEmpty) {
      return [];
    }

    int startIndex = currentSessionRawMeasurementSet.values.length - amount;
    if (startIndex < 0) {
      startIndex = 0;
    }

    return List.generate(
      currentSessionRawMeasurementSet.values.length - startIndex,
      (index) => DataPoint(
        dataType: IdiDataTypes.rawVoltage,
        value: DataValue(
          numbers: currentSessionRawMeasurementSet
              .values[startIndex + index].numbers,
        ),
        acquisitionTime: currentSessionRawMeasurementSet
            .acquisitionTimes[startIndex + index],
      ),
    );
  }

  /// === Raw Measurement Processing Logic
  List<ProcessedCurrent> getProcessedCurrents() {
    final List<ProcessedCurrent> processedCurrents = [];
    for (final (index, value)
        in currentSessionRawMeasurementSet.values.indexed) {
      final cleanedMeasurement = _cleanPeaks(value.numbers!);
      processedCurrents.add(ProcessedCurrent(
          currentSessionRawMeasurementSet.acquisitionTimes[index],
          _getAvgCurrent(cleanedMeasurement)));
    }
    return processedCurrents;
  }

  ProcessedCurrent? getLatestProcessedCurrent() {
    if (currentSessionRawMeasurementSet.values.isNotEmpty) {
      final latestRawMeasurement = getLatestRawMeasurement();
      final cleanedMeasurement =
          _cleanPeaks(latestRawMeasurement!.value.numbers!);
      return ProcessedCurrent(latestRawMeasurement.acquisitionTime,
          _getAvgCurrent(cleanedMeasurement));
    }
    return null;
  }

  List<double> _cleanPeaks(List<double> rawValues,
      {PeakCleaningMethod method = PeakCleaningMethod.absoluteDiff,
      int ignoreFirst = 10,
      thresholdFactor = 0.4}) {
    int amountOfPeaks = 0;
    List<double> sampleSlice = rawValues.sublist(ignoreFirst);
    int i = 0;

    switch (method) {
      case PeakCleaningMethod.absoluteDiff:
        double sampleAvg = _avgDoubles(sampleSlice);
        double threshold = thresholdFactor * sampleAvg;

        for (i = 0; i < sampleSlice.length; i++) {
          List<double> neighbours = _getNeighbouringSamples(sampleSlice, i, 1);
          double avgDiffForSample;
          if (neighbours.length > 1) {
            avgDiffForSample = neighbours
                    .map((n) => (n - sampleSlice[i]).abs())
                    .reduce((a, b) => a + b) /
                neighbours.length;
          } else {
            continue; // Skip if no neighbors
          }

          if (avgDiffForSample > threshold) {
            if (i > 0) {
              // Prevent index out of bounds
              sampleSlice[i] = sampleSlice[i - 1];
              amountOfPeaks++;
            }
          }
        }
        break;
      case PeakCleaningMethod.median:
        for (i = 0; i < sampleSlice.length; i++) {
          List<double> neighbours = _getNeighbouringSamples(sampleSlice, i, 1);
          if (neighbours.isNotEmpty) {
            double medianValue =
                _median(neighbours.map((e) => e.toInt()).toList());
            if (sampleSlice[i] != medianValue) {
              sampleSlice[i] = medianValue;
              amountOfPeaks++;
            }
          }
        }

        dev.log("Cleaned $amountOfPeaks peaks from measurement");
        break;
    }
    // Replace the original list elements modified in the slice
    rawValues.setRange(ignoreFirst, rawValues.length, sampleSlice);
    return rawValues;
  }

  double _median(List<int> items) {
    items.sort();
    int middle = items.length ~/ 2;
    if (items.length % 2 == 1) {
      return items[middle].toDouble();
    } else {
      return (items[middle - 1] + items[middle]) / 2.0;
    }
  }

  /// === Calibration Logic ===
  Map<double, CalibrationParameterEstimate> _estimateCalibrationParameters(
      List<ProcessedCurrent> processedCurrents) {
    if (currentSessionCalibrationSet.values.length < 2 ||
        currentSessionRawMeasurementSet.values.isEmpty) {
      return {};
    }

    final cumulativeParameterEstimates =
        <double, CalibrationParameterEstimate>{};

    for (var calibration
        in currentSessionCalibrationSet.toList().reversed.take(4)) {
      final List<double> sensitivityEstimates = [];
      final List<double> baseLineEstimates = [];

      for (var reference
          in currentSessionCalibrationSet.toList().reversed.take(4)) {
        if (reference.acquisitionTime != calibration.acquisitionTime &&
            reference.value.number != calibration.value.number) {
          // Create estimates for possible pairs with all other points
          var estimate = _twoPairLinearEstimate(
              _avgClosestMeasurementsToCalibration(
                  calibration, processedCurrents),
              calibration.value.number!,
              _avgClosestMeasurementsToCalibration(
                  reference, processedCurrents),
              reference.value.number!);

          sensitivityEstimates.add(estimate.sensitivity);
          baseLineEstimates.add(estimate.baseLine);
        }
      }

      final avgSensitivity = _avgDoubles(sensitivityEstimates);
      final avgBaseLine = _avgDoubles(baseLineEstimates);

      cumulativeParameterEstimates[_avgClosestMeasurementsToCalibration(
              calibration, processedCurrents)] =
          CalibrationParameterEstimate(avgSensitivity, avgBaseLine);
    }
    return cumulativeParameterEstimates;
  }

  CalibrationParameterEstimate _twoPairLinearEstimate(
      double newMeas, double newCalib, double refMeas, double refCalib) {
    final sensitivity = ((refMeas - newMeas) / (refCalib - newCalib)).abs();
    final baseline = newMeas - (sensitivity * refMeas);

    return CalibrationParameterEstimate(sensitivity, baseline);
  }

  /// === Utility Methods ===
  double _getAvgCurrent(List<double> rawValues) {
    final avgVoltage =
        rawValues.fold<double>(0, (sum, element) => sum + element) /
            rawValues.length;
    return (avgVoltage / 40000000) * 1000000;
  }

  double _avgDoubles(List<double> avgCurrents) {
    return avgCurrents.fold<double>(0, (sum, element) => sum + element) /
        avgCurrents.length;
  }

  List<double> _getNeighbouringSamples(
      List<double> items, int index, int radius) {
    int start = max(0, index - radius);
    int end = min(items.length, index + radius + 1);
    return items.getRange(start, end).toList();
  }

  List<ProcessedCurrent> _getNeighbouringMeasurements(
      List<ProcessedCurrent> items, int index, int radius) {
    int start = max(0, index - radius);
    int end = min(items.length, index + radius + 1);
    return items.getRange(start, end).toList();
  }

  ProcessedCurrent _getClosestMeasurement(
      DataPoint calibration, List<ProcessedCurrent> avgCurrents) {
    var estimate = avgCurrents.reduce((value, element) =>
        value.acquisitionTime.difference(calibration.acquisitionTime).abs() <
                element.acquisitionTime
                    .difference(calibration.acquisitionTime)
                    .abs()
            ? value
            : element);
    return estimate;
  }

  double _avgClosestMeasurementsToCalibration(
      DataPoint calibration, List<ProcessedCurrent> avgCurrents,
      {radius = 1}) {
    final point = _getClosestMeasurement(calibration, avgCurrents);
    final index = avgCurrents.indexOf(point);

    return _avgDoubles(_getNeighbouringMeasurements(avgCurrents, index, radius)
        .map((e) => e.value)
        .toList());
  }

  Tuple2<double, double> _findClosestCalibrationParams(
      double inputCurrent, List<double> availableCurrents) {
    double lowNearestCalibration = 0;
    double highNearestCalibration = 0;

    // Find the two closest available calibration parameters by current
    for (var current in availableCurrents) {
      if (current < inputCurrent && current > lowNearestCalibration) {
        lowNearestCalibration = current;
      } else if (current > inputCurrent) {
        highNearestCalibration = current;
        break;
      }
    }
    return Tuple2(lowNearestCalibration, highNearestCalibration);
  }

  Tuple2<double, double> _interpolateCalibrationEstimates(
      double measurementCurrent,
      Tuple2<double, double> calibrationCurrents,
      Map<double, CalibrationParameterEstimate> estimates) {
    double finalSensitivity = 0;
    double finalBaseLine = 0;

    if (calibrationCurrents.item1 == 0) {
      finalSensitivity = estimates[calibrationCurrents.item2]!.sensitivity;
      finalBaseLine = estimates[calibrationCurrents.item2]!.baseLine;
    } else if (calibrationCurrents.item2 == 0) {
      finalSensitivity = estimates[calibrationCurrents.item1]!.sensitivity;
      finalBaseLine = estimates[calibrationCurrents.item1]!.baseLine;
    } else {
      double highSensitivity =
          estimates[calibrationCurrents.item2]!.sensitivity;
      double highBaseLine = estimates[calibrationCurrents.item2]!.baseLine;
      double lowSensitivity = estimates[calibrationCurrents.item1]!.sensitivity;
      double lowBaseLine = estimates[calibrationCurrents.item1]!.baseLine;

      finalSensitivity = lowSensitivity +
          ((measurementCurrent - calibrationCurrents.item1) *
              ((highSensitivity - lowSensitivity) /
                  (calibrationCurrents.item2 - calibrationCurrents.item1)));
      finalBaseLine = lowBaseLine +
          ((measurementCurrent - calibrationCurrents.item1) *
              ((highBaseLine - lowBaseLine) /
                  (calibrationCurrents.item2 - calibrationCurrents.item1)));
    }
    return Tuple2(finalSensitivity, finalBaseLine);
  }

  List<double> _getSortedAvailableCalibrationCurrents(
      Map<double, CalibrationParameterEstimate> estimates) {
    var availableCurrents = estimates.keys.toList();
    availableCurrents.sort();
    return availableCurrents;
  }

  double _avgMeasurementWithNeighbors(List<ProcessedCurrent> rawMeasurements,
      int measurementIndex, int nPrev, int nNext) {
    var avgGroup = <ProcessedCurrent>[];
    if (measurementIndex - nPrev < 0 &&
        measurementIndex + nNext + 1 > rawMeasurements.length) {
      avgGroup = rawMeasurements;
    } else if (measurementIndex - nPrev < 0) {
      avgGroup = rawMeasurements.sublist(0, measurementIndex + nNext + 1);
    } else if (measurementIndex + nNext + 1 > rawMeasurements.length) {
      avgGroup = rawMeasurements.sublist(measurementIndex - nPrev);
    } else {
      avgGroup = rawMeasurements.sublist(
          measurementIndex - nPrev, measurementIndex + nNext + 1);
    }
    return _avgDoubles(avgGroup.map((e) => e.value).toList());
  }
}

enum PeakCleaningMethod { absoluteDiff, median }

class ProcessedCurrent {
  const ProcessedCurrent(this.acquisitionTime, this.value);

  final DateTime acquisitionTime;
  final double value;
}

class CalibrationParameterEstimate {
  const CalibrationParameterEstimate(this.sensitivity, this.baseLine);

  final double sensitivity;
  final double baseLine;
}
