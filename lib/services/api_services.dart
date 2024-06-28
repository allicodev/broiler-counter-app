import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:scanner/services/api_status.dart';
import 'package:scanner/utilities/constants.dart';

class APIServices {
  static Future<Object> get(
      {String? externalUrl,
      required String endpoint,
      Map<String, dynamic>? query}) async {
    try {
      print("$BASE_URL$endpoint");
      var url = Uri.parse(externalUrl ?? "$BASE_URL$endpoint")
          .replace(queryParameters: query);
      var response = await http.get(url, headers: <String, String>{
        'Content-Type': 'application/json',
        // 'Authorization': 'Bearer ${Env.Token}}',
        'app-device-platform': 'android'
      });

      if ([200, 201].contains(response.statusCode)) {
        return Success(
            code: response.statusCode, response: jsonDecode(response.body));
      } else {
        return Failure(
            code: response.statusCode, response: jsonDecode(response.body));
      }
    } on HttpException {
      return Failure(code: 101, response: {"message": 'No Internet'});
    } on FormatException {
      return Failure(code: 102, response: {"message": 'Invalid Format'});
    } catch (e) {
      print("API SERVICE ERROR");
      print(e);
      return Failure(code: 103, response: {"message": 'Unknown Error'});
    }
  }

  static Future<Object> post({
    required String endpoint,
    required Map<String, dynamic> payload,
  }) async {
    try {
      var url = Uri.parse("$BASE_URL$endpoint");
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer ${Env.Token}',
        },
        body: jsonEncode(payload),
      );

      if (jsonDecode(response.body)["success"]) {
        return Success(code: 200, response: jsonDecode(response.body));
      } else {
        return Failure(
            code: response.statusCode, response: jsonDecode(response.body));
      }
    } on HttpException {
      return Failure(code: 101, response: {"message": 'No Internet'});
    } on FormatException {
      return Failure(code: 102, response: {"message": 'Invalid Format'});
    } catch (e) {
      print("API SERVICE ERROR");
      print(e);
      return Failure(code: 103, response: {"message": 'Unknown Error'});
    }
  }
}
