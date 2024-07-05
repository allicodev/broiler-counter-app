import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:scanner/services/api_status.dart';
import 'package:scanner/utilities/constants.dart';
import 'package:collection/collection.dart';
import 'package:http_parser/http_parser.dart';

class APIServices {
  static Future<Object> get(
      {String? externalUrl,
      required String endpoint,
      Map<String, dynamic>? query}) async {
    try {
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
    Map<String, List<PlatformFile>>? imagesPayload,
  }) async {
    try {
      var url = Uri.parse("$BASE_URL$endpoint");

      http.Response response;
      if (imagesPayload == null) {
        response = await http
            .post(url, body: jsonEncode(payload), headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        });
      } else {
        var request = http.MultipartRequest("POST", url);
        payload.forEach((key, value) {
          if (value != null) {
            request.fields[key] = value is Iterable<dynamic> || value is Map
                ? jsonEncode(value)
                : value.toString();
          }
        });

        List properties = imagesPayload.keys.toList();
        for (int i = 0; i < properties.length; i++) {
          if (imagesPayload[properties[i]]!.isEmpty) {
            continue;
          }

          imagesPayload[properties[i]]!.forEachIndexed((index, file) {
            request.files.add(http.MultipartFile.fromBytes(
                properties[i], File(file.path!).readAsBytesSync(),
                filename: file.name,
                contentType: MediaType('image', file.extension ?? 'jpeg',
                    {"index": index.toString()})));
          });
        }

        response = await http.Response.fromStream(await request.send());
      }

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
