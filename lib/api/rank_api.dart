import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:rank_ten/api/rank_exceptions.dart';

class RankApi {
  final baseUrl = 'http://192.168.0.22:5000';

  Future<dynamic> get({String endpoint, String bearerToken = ""}) async {
    var jsonResponse;

    try {
      final res = await http.get(baseUrl + endpoint,
          headers: getHeaders(bearerToken: bearerToken));
      jsonResponse = parseResponse(res);
    } on SocketException {
      return DefaultError('No network connection');
    }

    return jsonResponse;
  }

  Future<dynamic> post(
      {String endpoint,
      Map<String, dynamic> data = const {},
      String bearerToken = ""}) async {
    var jsonResponse;

    try {
      final res = await http.post(baseUrl + endpoint,
          body: jsonEncode(data),
          headers: getHeaders(bearerToken: bearerToken));
      jsonResponse = parseResponse(res);
    } on SocketException {
      return DefaultError('No network connection');
    }

    return jsonResponse;
  }

  Map<String, dynamic> getHeaders({String bearerToken}) {
    return bearerToken == ""
        ? Map<String, dynamic>()
        : {'Authorization': 'Bearer $bearerToken'};
  }

  dynamic parseResponse(http.Response res) {
    switch (res.statusCode) {
      case 200:
        return json.decode(res.body.toString());
      case 400:
        return SchemaValidationError(res.body.toString());
      case 401:
        return AuthenticationError(res.body.toString());
      case 403:
        return UnauthorizedError(res.body.toString());
      default:
        return DefaultError(res.body.toString());
    }
  }
}