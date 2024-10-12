import 'package:flutter/cupertino.dart';
import 'package:scanner/models/broiler_count.dart';
import 'package:scanner/models/user_model.dart';
import 'package:scanner/services/api_services.dart';
import 'package:scanner/services/api_status.dart';

class AppProvider extends ChangeNotifier {
  String _loading = "stop";
  String get loading => _loading;

  List<BroilerCount> _broiler = [];
  List<BroilerCount> get broilers => _broiler;

  User? _currentUser = null;
  User? get currentUser => _currentUser;

  double _price = 0.00;
  double get price => _price;

  setLoading(String loading) async {
    _loading = loading;
    notifyListeners();
  }

  setUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  setChickenPrice(double price) {
    _price = price;
    notifyListeners();
  }

  getBroiler({Map<String, dynamic>? query, required Function callback}) async {
    setLoading("fetching");
    final response =
        await APIServices.get(endpoint: "/api/broiler", query: query);
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

  getUser({required id}) async {
    final response =
        await APIServices.get(endpoint: "/api/app/get-user", query: {"id": id});
    if (response is Success) {
      setLoading("");
      if (response.response['success']) {
        setUser(User.fromJson(response.response["data"]["user"]));
      }
    }
  }

  login({required payload, required Function callback}) async {
    setLoading("loggin-in");

    final response =
        await APIServices.get(endpoint: "/api/app/login", query: payload);
    if (response is Success) {
      setLoading("");
      if (response.response['success']) {
        var id = response.response["data"]["user"]["_id"];
        setUser(User.fromJson(response.response["data"]["user"]));
        callback(response.code, response.response["message"] ?? "Success.", id);
      } else {
        callback(403, response.response["message"] ?? "Success.");
      }
    }
    if (response is Failure) {
      callback(response.code, response.response["message"] ?? "Failed.");
      setLoading("");
    }
  }

  getChickenPrice() async {
    final response = await APIServices.get(endpoint: "/api/chicken-price");
    if (response is Success) {
      var data = response.response['data'];
      if (data is List && data.isNotEmpty) {
        setChickenPrice(double.parse(data[0]["chickenPrice"].toString()));
      }
    }
  }
}
