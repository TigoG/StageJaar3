import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sen_gs_1_ca_connector_plugin/constant/sensible_defaults.dart';
import 'package:sen_gs_1_web/cubit/app_cubit.dart';
import 'package:sen_gs_1_web/widgets/data/donut_chart.dart';
import 'package:sen_gs_1_web/widgets/data/line_chart.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<StatefulWidget> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (BuildContext context, AppState appState) {
        return Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Center(
            child: SingleChildScrollView( 
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: SensibleDefaults.getVerticalSpacing(context)),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      bool isMobile = constraints.maxWidth < SensibleDefaults.phoneSize;

                      double chartHeight = MediaQuery.of(context).size.height * 0.5;
                      double chartWidth = MediaQuery.of(context).size.width * 0.5;

                      double lineChartWidth = isMobile ? MediaQuery.of(context).size.width * 0.8 : chartWidth;

                      return isMobile
                          ? Column(
                              children: [
                                SizedBox(
                                  width: lineChartWidth,
                                  height: chartHeight,
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                                    child: LineChartWidget(),
                                  ),
                                ),
                                SizedBox(height: SensibleDefaults.getVerticalSpacing(context)),
                                SizedBox(
                                  width: chartWidth,
                                  height: chartHeight,
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                                    child: DonutChart(),
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                SizedBox(
                                  width: chartWidth,
                                  height: chartHeight,
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                                    child: LineChartWidget(),
                                  ),
                                ),
                                SizedBox(
                                  width: chartWidth,
                                  height: chartHeight,
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                                    child: DonutChart(),
                                  ),
                                ),
                              ],
                            );
                    },
                  ),
                  SizedBox(height: SensibleDefaults.getVerticalSpacing(context)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
