import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:login/screens/user_info_screen.dart';
import 'package:login/screens/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FlutterSecureStorage storage = FlutterSecureStorage();
  var id;

  final url = Uri.parse('https://app.wattaudit.com/api-v2/validate_token.php');

  Future<void> validateToken() async {
    
    final jwt = await storage.read(key: 'jwt');
    final name = await storage.read(key: 'username');
    print("Username: $name");

    final response = await http.post(
      url,
      body: jsonEncode({"jwt": jwt}),
    );
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      if (jsonResponse['status'] == 'success') {
        setState(() {
          id = jsonResponse['user_data']['cl_id'];
        });
        print("ID: $id");
      }
    } else {
      throw Exception("Error Occurred");
    }
  }

  Future<void> regenerateToken() async {
    final url = Uri.parse("https://app.wattaudit.com/api-v2/regenerate_token.php");
    final refreshToken = await storage.read(key: "refreshToken");
    print("This is homeScreen token: $refreshToken");
    final response = await http.post(
      url,
      
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {
         "refresh_token" : refreshToken
      },
      
    );
    print("Full Response: ${response.body}");

    if(response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if(jsonResponse['status'] == 'success') {
        
      await storage.write(key: "refreshToken", value: jsonResponse['refresh_token']);
      await storage.write(key: "jwt", value: jsonResponse['jwt']);
      await storage.write(key: "abc", value: jsonResponse['data']['cl_id']);

      final abc = await storage.read(key: "abc");
      print("ABC: $abc");
      } else {
        print("Error while giving response");
      }
    } else {
      throw Exception("Throw Exception");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home Screen"), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "User Information",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    if (id != null) Text("User Id: $id"),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await validateToken();
              },
              child: Text("Validate Token"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserInfoScreen()),
                );
              },
              child: Text("Test Secure API Calls"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            ElevatedButton(
              onPressed: () => regenerateToken(),
              child: Text("Regenerate Token"),
            ),
          ],
        ),
      ),
    );
  }
}
