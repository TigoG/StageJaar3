import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class GroupedBarChart extends StatelessWidget {
  final List<List<double>> data; // List of bar groups, each containing 4 values
  final List<String> labels; // Labels for each group

  const GroupedBarChart({
    super.key,
    required this.data,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceEvenly,
        barGroups: data.asMap().entries.map((entry) {
          int groupIndex = entry.key;
          List<double> groupData = entry.value;

          return BarChartGroupData(
            x: groupIndex,
            barRods: groupData.map((barValue) {
              // Calculate the correct color
              int barIndex = groupData.indexOf(barValue);
              return BarChartRodData(
                y: barValue, // Height of the bar
                colors: [Colors.primaries[barIndex % Colors.primaries.length]], // Color assignment
                width: 16, // Adjust width as needed
                borderRadius: BorderRadius.circular(4), // Rounded corners for bars
              );
            }).toList(),
            barsSpace: 6, // Space between bars in a group
          );
        }).toList(),
        titlesData: FlTitlesData(
          leftTitles: SideTitles(showTitles: true),
          bottomTitles: SideTitles(
            showTitles: true,
            getTitles: (double value) {
              final index = value.toInt();
              return index < labels.length ? labels[index] : '';
            },
          ),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(enabled: true),
      ),
    );
  }
}
