import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:login/screens/home_screen.dart';
import 'package:login/widgets/custom_textfield.dart';
import 'package:login/widgets/loginButton.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String errorMessage = '';
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final url = Uri.parse('https://app.wattaudit.com/api-v2/api_login.php');

  Future<void> postLoginData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      final response = await http.post(
        url,
        body: jsonEncode({
          'username': usernameController.text,
          'password': passwordController.text,
          "user_type": "installator",
          "platform": "android",
          "device_token": "",
        }),
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['status'] == 'success') {
          // Simple success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login successful!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
          FlutterSecureStorage storage = FlutterSecureStorage();
          await storage.write(key: 'jwt', value: jsonResponse['jwt']);
          await storage.write(key: "username", value: jsonResponse['data']['cl_username']);
          await storage.write(key: 'refreshToken', value: jsonResponse['refresh_token']);
        

        } else {
          setState(() {
            errorMessage = jsonResponse['message'] ?? 'Login failed';
          });
        }
      } else {
        setState(() {
          errorMessage = 'Server error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: CircleAvatar(
                  radius: 80,
                  backgroundImage: AssetImage('assets/images/logo.jpg'),
                ),
              ),
              SizedBox(height: 50),
              Text(
                "Login",
                style: TextStyle(fontSize: 38, fontWeight: FontWeight.w400),
              ),
              SizedBox(height: 30),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextfield(
                      icon: Icon(Icons.email),
                      labelText: "Username",
                      controller: usernameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Username cannot be empty';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    CustomTextfield(
                      icon: Icon(Icons.lock),
                      labelText: "Password",
                      eyeIcon: Icon(Icons.visibility),
                      controller: passwordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password cannot be empty';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Forgot your password?         ",
                    style: TextStyle(color: Color(0xFF456246)),
                  ),
                ],
              ),
              SizedBox(height: 20),

              isLoading
                  ? CircularProgressIndicator()
                  : Loginbutton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await postLoginData();
                        }
                      },
                    ),
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
                  ],
                ),
              ),
              
            ],
          ),
        ),
      ),
    );
  }
}
