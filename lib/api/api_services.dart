import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:login/constants/constants.dart';

import '../model/visit_model.dart';

class ApiServices {
  var id;
  final storage = FlutterSecureStorage();
  final Uri _loginUrl = Uri.parse('$baseUrl/api_login.php');
  final Uri _validateTokenUrl = Uri.parse('$baseUrl/validate_token.php');
  final Uri _regenerateTokenUrl = Uri.parse('$baseUrl/regenerate_token.php');
  final Uri _visitsListUrl = Uri.parse(
    '$baseUrl/res-20/getSpecificUserVisitsList.php',
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
      body: jsonEncode({
        'jwt': !isTokenRegenerated ? 'jwt' : jwt}),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['status'] == 'success') {
        return {'status': true, 'user_id': jsonResponse['user_data']['cl_id']};
      } else if (jsonResponse['status'] == 'error' && jsonResponse['message'] == 'INVALID') {
        print("Invalid Token");
        if(!isTokenRegenerated) {
          bool regenerated = await regenerateToken();
          if(regenerated) {
            return await validateToken();
          } else {
            throw Exception("Token validation failed");
          }
        }
      }
       else {
        return {'status': jsonResponse['status'], 'message': jsonResponse['message']};
      }
    } else {
      throw Exception('Token validation failed');
    }
    return validateToken();
  }

  // Regenerate Token

  Future<bool> regenerateToken() async {
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
        isTokenRegenerated = true;
        return true;
      } else {
        print("Error while giving response");
        return false;
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
          "jwt": isTokenRegenerated == false ? 'hgjhgjhjbghcghj' : jwt,
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
          print("Api status ${data['status'].toString()}");
          if (data['visits_list'] != null) {
            List<dynamic> visitJsonList = data['visits_list'];
            return visitJsonList
                .map((json) => VisitModel.fromJson(json))
                .toList();
          } else {
            return [];
          }
        } else if (data['status'] == 'error' && data['message'] == 'INVALID') {
          print('Error and Token is invalid');
          print("Token status: $isTokenRegenerated");
          if (!isTokenRegenerated) {
            bool regenerated = await regenerateToken();
            if(regenerated) {
          return await makeSecureApiCall();
            } else {
              throw Exception("Token regeneration failed");
            }
            
            print("Token status inside: $isTokenRegenerated");
            
          }
          
        } else {
          print("Status code : ${data['status'].toString()}");
          print("message ${data['message'].toString()}");
          throw Exception("Api returned error status");
        }
      } else {
        throw Exception("Failed with status code: ${response.statusCode}");
      }
      return [];
    } catch (e) {
      print("Api call erro: $e");
      throw e;
    }
  }
}
