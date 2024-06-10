import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scanner/widgets/table.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _SyncfusionBarChartState();
}

class _SyncfusionBarChartState extends State<HomeScreen> {
  late TooltipBehavior _tooltip;
  final Random random = Random();

  @override
  void initState() {
    _tooltip = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6), color: Colors.white),
          child: Column(
            children: [
              SfCartesianChart(
                  borderWidth: 0,
                  tooltipBehavior: _tooltip,
                  title: const ChartTitle(
                      text: "Broiler Counter Graph",
                      textStyle: TextStyle(fontFamily: 'abel', fontSize: 22.0)),
                  primaryXAxis: const CategoryAxis(
                    title: AxisTitle(text: 'Time/Date'),
                  ),
                  primaryYAxis: const NumericAxis(
                    title: AxisTitle(text: 'Broiler Count'),
                  ),
                  series: <CartesianSeries<ChartData, int>>[
                    ColumnSeries<ChartData, int>(
                        dataSource: List.generate(
                            5,
                            (i) => ChartData(
                                i, random.nextInt(50), DateTime.now())),
                        color: Colors.teal,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(5)),
                        xValueMapper: (ChartData data, _) => data.x,
                        yValueMapper: (ChartData data, _) => data.y),
                  ]),
              const SizedBox(height: 35),
              const Text(
                "Recent Count Table",
                style: TextStyle(fontFamily: 'abel', fontSize: 22.0),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        ATable(
                          dataSource: List.generate(
                              5,
                              (i) => ChartData(
                                  i, random.nextInt(50), DateTime.now())),
                          columns: const ["Date", "Count"],
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      );
}

class ChartData {
  ChartData(this.x, this.y, this.createdAt);
  final int x;
  final int y;
  final DateTime createdAt;
}
