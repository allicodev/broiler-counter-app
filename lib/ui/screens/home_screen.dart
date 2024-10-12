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
  String graphFilter;
  HomeScreen({Key? key, required this.graphFilter}) : super(key: key);

  @override
  State<HomeScreen> createState() => _SyncfusionBarChartState();
}

class _SyncfusionBarChartState extends State<HomeScreen> {
  late TooltipBehavior _tooltip;
  final Random random = Random();

  DateTime _ =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  String graphFilter = "";
  DateFormat dateFormat = DateFormat("ha");

  @override
  void initState() {
    _tooltip = TooltipBehavior(enable: true);

    // get broiler datas from api
    fetchBroilers();
    setState(() => graphFilter = widget.graphFilter);
    super.initState();
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.graphFilter != widget.graphFilter) {
      setState(() => graphFilter = widget.graphFilter);

      switch (widget.graphFilter.toLowerCase()) {
        case "monthly":
          {
            dateFormat = DateFormat("MMM");
            _ = DateTime(DateTime.now().year, 1, 1);
            break;
          }

        case "daily":
          {
            dateFormat = DateFormat("ha");
            break;
          }
      }

      setState(() {});
    }
  }

  fetchBroilers() {
    Provider.of<AppProvider>(context, listen: false).getBroiler(
        query: {"type": graphFilter},
        callback: (code, message) {
          if (code != 200) {
            launchSnackbar(context: context, mode: "ERROR", message: message);
          }
        });
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
                          text: "Broiler Chart",
                          textStyle:
                              TextStyle(fontFamily: 'abel', fontSize: 18.0)),
                      primaryXAxis: DateTimeAxis(
                        minimum: _,
                        interval: 4,
                        maximum: _.add(graphFilter.toLowerCase() == "daily"
                            ? const Duration(
                                hours: 23, microseconds: 59, seconds: 59)
                            : DateTime(DateTime.now().year, 12, 31)
                                .difference(_)),
                        dateFormat: dateFormat,
                      ),
                      primaryYAxis: const NumericAxis(
                        // title: AxisTitle(text: 'Broiler Count'),
                        interval: 5,
                        minimum: 0,
                        maximum: 100,
                      ),
                      series: <CartesianSeries<BroilerCount, DateTime>>[
                        ColumnSeries<BroilerCount, DateTime>(
                            dataSource: graphFilter.toLowerCase() == "monthly"
                                ? mergeBroilerCounts(app.broilers)
                                : app.broilers,
                            color: Colors.teal,
                            name: "Broilers",
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(5)),
                            xValueMapper: (BroilerCount data, _) => DateTime(
                                data.createdAt.year,
                                data.createdAt.month,
                                graphFilter.toLowerCase() == "monthly"
                                    ? 0
                                    : data.createdAt.day,
                                graphFilter.toLowerCase() == "monthly"
                                    ? 0
                                    : data.createdAt.hour),
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
                                dataSource:
                                    graphFilter.toLowerCase() == "monthly"
                                        ? mergeBroilerCounts(app.broilers)
                                        : app.broilers,
                                columns: const ["Date", "Count"],
                                showMonthlyOnly:
                                    graphFilter.toLowerCase() == "monthly"),
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

List<BroilerCount> mergeBroilerCounts(List<BroilerCount> broilers) {
  Map<String, int> mergedCounts = {};

  for (var broiler in broilers) {
    String key = '${broiler.createdAt.year}-${broiler.createdAt.month}';

    if (mergedCounts.containsKey(key)) {
      mergedCounts[key] = mergedCounts[key]! + broiler.count;
    } else {
      mergedCounts[key] = broiler.count;
    }
  }

  List<BroilerCount> mergedList = [];

  mergedCounts.forEach((key, value) {
    var parts = key.split('-');
    int year = int.parse(parts[0]);
    int month = int.parse(parts[1]);

    mergedList.add(BroilerCount(
      createdAt: DateTime(year, month),
      count: value,
    ));
  });

  return mergedList;
}
