import 'package:flutter/cupertino.dart';

class AppProvider extends ChangeNotifier {
  String _loading = "stop";
  String get loading => _loading;
}
