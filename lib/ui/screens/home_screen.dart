import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:scanner/models/broiler_count.dart';
import 'package:scanner/provider/app_provider.dart';
import 'package:scanner/widgets/snackbar.dart';
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

  final DateTime _ =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  @override
  void initState() {
    _tooltip = TooltipBehavior(enable: true);

    // get broiler datas from api
    Provider.of<AppProvider>(context, listen: false).getBroiler(
        callback: (code, message) {
      if (code != 200) {
        launchSnackbar(context: context, mode: "ERROR", message: message);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();

    return Container(
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6), color: Colors.white),
      child: app.loading == "fetching"
          ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Fetching Broiler Data"),
                SizedBox(width: 15.0),
                SizedBox(
                    height: 15,
                    width: 15,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                    )),
              ],
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Text(DateFormat("hh:mm").format(DateTime.now()),
                              style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(width: 5.0),
                          Text(DateFormat("EEE, dd MMM yyyy")
                              .format(DateTime.now()))
                        ],
                      )),
                  const SizedBox(height: 16.0),
                  SfCartesianChart(
                      tooltipBehavior: _tooltip,
                      title: const ChartTitle(
                          text: "Broiler Counter Graph",
                          textStyle:
                              TextStyle(fontFamily: 'abel', fontSize: 18.0)),
                      primaryXAxis: DateTimeAxis(
                        minimum: _,
                        intervalType: DateTimeIntervalType.hours,
                        interval: 4,
                        maximum: _.add(const Duration(
                            hours: 23, microseconds: 59, seconds: 59)),
                        // sets the date format to 12 hour
                        dateFormat: DateFormat("h a"),
                      ),
                      primaryYAxis: const NumericAxis(
                        title: AxisTitle(text: 'Broiler Count'),
                        interval: 5,
                        minimum: 0,
                        maximum: 100,
                      ),
                      series: <CartesianSeries<BroilerCount, DateTime>>[
                        ColumnSeries<BroilerCount, DateTime>(
                            dataSource: app.broilers,
                            color: Colors.teal,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(5)),
                            xValueMapper: (BroilerCount data, _) => DateTime(
                                data.createdAt.year,
                                data.createdAt.month,
                                data.createdAt.day,
                                data.createdAt.hour),
                            yValueMapper: (BroilerCount data, _) => data.count),
                      ]),
                  const SizedBox(height: 35),
                  const Text(
                    "Recent Count Table",
                    style: TextStyle(fontFamily: 'abel', fontSize: 22.0),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.7,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12)),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          children: [
                            ATable(
                              dataSource: app.broilers,
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
}
