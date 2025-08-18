import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:login/constants/colors.dart';
import 'package:login/dio/dio_interceptors.dart';
import 'package:login/widgets/custom_icon_btn.dart';
import 'package:dio/dio.dart';
import 'package:login/widgets/user_info_card.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  late final Dio dio;
  final url = "https://app.wattaudit.com/api-v2/res-20/getSpecificUserVisitsList.php";
  
  Future<void> _makeSecureApiCall() async {
    try {
      
      final response = await dio.post(
        url,
        data: {
          
        }
      );
      if(response.statusCode == 200) {
        print("Success: ${response.data}");
        // Handle successful response
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('API call successful!'), backgroundColor: Colors.green),
        );
      } else {
        print("Error: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('API call failed: ${response.statusCode}'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      print('API call error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('API call error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150,
            pinned: true,
            leading: IconButton(
              onPressed: () {},
              icon: Icon(CupertinoIcons.bars, color: primaryColor, size: 40,),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              // title: Text("User Info"), // Visible when collapsed
              background: Container(
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/images/logo.jpg',
                  key: UniqueKey(), // Prevent reuse error
                  height: 80,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text('Liste des RES020', style: TextStyle(color: primaryColor, fontSize: 20),),
                SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomIconBtn(text: 'Filtre', icon: Icon(Icons.arrow_downward),),
                    GestureDetector(
                      onTap: _makeSecureApiCall,
                      child: CustomIconBtn(text: 'Rafraichir', icon: Icon(CupertinoIcons.arrow_clockwise),),
                    )
                  ],
                ),
                SizedBox(height: 15,),
                ElevatedButton(
                  onPressed: _makeSecureApiCall,
                  child: Text('Test Secure API Call'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
                SizedBox(height: 25,),
                UserInfoCard(),
              ],
            ),
            ),
            ),
          
        ],
      ),
    );
  }
}
