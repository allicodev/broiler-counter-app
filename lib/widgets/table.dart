import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scanner/models/broiler_count.dart';

class ATable extends StatelessWidget {
  List<BroilerCount> dataSource;
  List<String> columns;
  bool? showMonthlyOnly;
  ATable(
      {Key? key,
      required this.dataSource,
      required this.columns,
      this.showMonthlyOnly})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: DataTable(
        columns: columns.map((e) => DataColumn(label: Text(e))).toList(),
        rows: List.generate(
          dataSource.length,
          (index) => DataRow(cells: [
            DataCell(Text(DateFormat(
                    showMonthlyOnly == true ? 'MMM - yyyy' : 'MM/dd/yy hh:mm a')
                .format(dataSource[index].createdAt))),
            DataCell(Text(dataSource[index].count.toInt().toString())),
          ]),
        ).toList(),
      ),
    );
  }
}
