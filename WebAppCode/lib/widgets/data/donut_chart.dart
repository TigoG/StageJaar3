import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DonutChart extends StatelessWidget {
  const DonutChart({super.key});

  @override
  Widget build(BuildContext context) {

    double chartSize = MediaQuery.of(context).size.width * 0.2;

    if (chartSize < 150) {
      chartSize = 150;
    }

    return Center(
      child: Container(
        width: chartSize,
        height: chartSize,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: PieChart(
          PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: chartSize * 0.05,
            sections: _buildChartSections(chartSize),
            borderData: FlBorderData(show: false),
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildChartSections(double chartSize) {
    return [
      PieChartSectionData(
        color: Colors.blue,
        value: 40,
        title: '40%',
        radius: chartSize * 0.3,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
      ),
      PieChartSectionData(
        color: Colors.red,
        value: 30,
        title: '30%',
        radius: chartSize * 0.3,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
      ),
      PieChartSectionData(
        color: Colors.green,
        value: 20,
        title: '20%',
        radius: chartSize * 0.3, 
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
      ),
      PieChartSectionData(
        color: Colors.yellow,
        value: 10,
        title: '10%',
        radius: chartSize * 0.3,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    ];
  }
}
