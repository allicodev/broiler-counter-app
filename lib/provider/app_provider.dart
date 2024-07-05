import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:scanner/models/broiler_count.dart';
import 'package:scanner/services/api_services.dart';
import 'package:scanner/services/api_status.dart';

class AppProvider extends ChangeNotifier {
  String _loading = "stop";
  String get loading => _loading;

  List<BroilerCount> _broiler = [];
  List<BroilerCount> get broilers => _broiler;

  setLoading(String loading) async {
    _loading = loading;
    notifyListeners();
  }

  getBroiler({required Function callback}) async {
    setLoading("fetching");
    final response = await APIServices.get(endpoint: "/api/broiler");
    if (response is Success) {
      _broiler = List<BroilerCount>.from(
          response.response["data"].map((x) => BroilerCount.fromJson(x)));
      callback(response.code, response.response["message"] ?? "Success.");
      setLoading("");
    }
    if (response is Failure) {
      callback(response.code, response.response["message"] ?? "Failed.");
      setLoading("");
    }
  }

  sendBroiler({
    required payload,
    required Function callback,
  }) async {
    setLoading("sending");
    final response = await APIServices.post(
        endpoint: "/api/broiler", payload: {"broiler": payload});
    if (response is Success) {
      setLoading("");
      if (response.response['success']) {
        callback(response.code, response.response["message"] ?? "Success.");
      } else {
        callback(403, response.response["message"] ?? "Success.");
      }
    }
    if (response is Failure) {
      callback(response.code, response.response["message"] ?? "Failed.");
      setLoading("");
    }
  }
}
