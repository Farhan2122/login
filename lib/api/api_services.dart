import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../model/visit_model.dart';

class ApiServices {
  var id;
  final storage = FlutterSecureStorage();
  final Uri _loginUrl = Uri.parse(
    'https://app.wattaudit.com/api-v2/api_login.php',
  );
  final Uri _validateTokenUrl = Uri.parse(
    'https://app.wattaudit.com/api-v2/validate_token.php',
  );
  final Uri _regenerateTokenUrl = Uri.parse(
    'https://app.wattaudit.com/api-v2/regenerate_token.php',
  );
  final Uri _visitsListUrl = Uri.parse(
    'https://app.wattaudit.com/api-v2/res-20/getSpecificUserVisitsList.php',
  );

  Future<Map<String, dynamic>> postLoginData({
    required String username,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final response = await http.post(
        _loginUrl,
        body: jsonEncode({
          'username': username,
          'password': password,
          'user_type': 'installator',
          'platform': 'android',
          'device_token': '',
        }),
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonResponse['status'] == 'success') {
        await storage.write(key: 'jwt', value: jsonResponse['jwt']);
        await storage.write(
          key: 'username',
          value: jsonResponse['data']['cl_username'],
        );
        await storage.write(
          key: 'refreshToken',
          value: jsonResponse['refresh_token'],
        );

        return {'status': true, 'message': 'Login successful!'};
      } else {
        return {
          'status': false,
          'message': jsonResponse['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {'status': false, 'message': 'An error occurred: $e'};
    }
  }

  // validate token
  Future<Map<String, dynamic>> validateToken() async {
    final jwt = await storage.read(key: 'jwt');
    final username = await storage.read(key: 'username');
    print("Username: $username");

    final response = await http.post(
      _validateTokenUrl,
      body: jsonEncode({'jwt': jwt}),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['status'] == 'success') {
        return {'status': true, 'user_id': jsonResponse['user_data']['cl_id']};
      } else {
        return {'status': false, 'message': 'Invalid token'};
      }
    } else {
      throw Exception('Token validation failed');
    }
  }

  // Regenerate Token

  Future<void> regenerateToken() async {
    final refreshToken = await storage.read(key: "refreshToken");
    print("This is homeScreen token: $refreshToken");
    final response = await http.post(
      _regenerateTokenUrl,
      body: jsonEncode({"refresh_token": refreshToken}),
    );
    print("Full Response: ${response.body}");

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['status'] == 'success') {
        await storage.write(
          key: "refreshToken",
          value: jsonResponse['refresh_token'],
        );
        await storage.write(key: "jwt", value: jsonResponse['jwt']);
      } else {
        print("Error while giving response");
      }
    } else {
      throw Exception("Throw Exception");
    }
  }

  // fetch data

  Future<List<VisitModel>> makeSecureApiCall() async {
    final jwt = await storage.read(key: "jwt");
    try {
      final response = await http.post(
        _visitsListUrl,
        body: jsonEncode({
          "jwt": jwt,
          "page_number": 1,
          "start_date": "",
          "cl_name": "",
          "city": "",
          "end_date": "",
          "visit_id": "",
          "bar_type": "se_20",
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          if (data['visits_list'] != null) {
            List<dynamic> visitJsonList = data['visits_list'];
            return visitJsonList
                .map((json) => VisitModel.fromJson(json))
                .toList();
          } else {
            return [];
          }
        } else {
          throw Exception("Api returned error status");
        }
      } else {
        throw Exception("Failed with status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Api call erro: $e");
      throw e;
    }
  }
}
