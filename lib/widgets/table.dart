import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scanner/ui/screens/home_screen.dart';

class ATable extends StatelessWidget {
  List<ChartData> dataSource;
  List<String> columns;
  ATable({Key? key, required this.dataSource, required this.columns})
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
            DataCell(Text(DateFormat('MM/dd/yy hh:mm a')
                .format(dataSource[index].createdAt))),
            DataCell(Text(dataSource[index].y.toInt().toString())),
          ]),
        ).toList(),
      ),
    );
  }
}
