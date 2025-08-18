import 'package:flutter/material.dart';
import 'package:login/constants/colors.dart';

class UserInfoCard extends StatefulWidget {
  const UserInfoCard({super.key});

  @override
  State<UserInfoCard> createState() => _UserInfoCardState();
}

class _UserInfoCardState extends State<UserInfoCard> {
  bool isShowContainer = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isShowContainer = true;
        });
      },
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5), 
              spreadRadius: 5, 
              blurRadius: 7, 
              offset: Offset(0, 3), 
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.folder_shared, color: primaryColor, size: 48),
                Text(
                  'tuqeer@codelounge.io',
                  style: TextStyle(color: primaryColor, fontSize: 16),
                ),
                VerticalDivider(color: primaryColor, width: 10),
                Column(
                  children: [
                    Text(
                      "tuqeer",
                      style: TextStyle(color: primaryColor, fontSize: 16),
                    ),
                    Text(
                      '466',
                      style: TextStyle(color: primaryColor, fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            if (isShowContainer) InfoContainer(),
          ],
        ),
      ),
    );
  }
}

class InfoContainer extends StatelessWidget {
  const InfoContainer({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Information client :",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Text(
                    "Prenom :",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text("tuqeer"),
                ],
              ),
              Row(
                children: [
                  Text("Nom :", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("t3at"),
                ],
              ),
              Row(
                children: [
                  Text(
                    "Address :",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text("0 gava6 25262 gwhw"),
                ],
              ),
              Row(
                children: [
                  Text(
                    "Ville :",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text("CUENCA"),
                ],
              ),
              Row(
                children: [
                  Text(
                    "Code postal :",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text("25262"),
                ],
              ),
              Row(
                children: [
                  Text(
                    "Code Acces :",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text("25262"),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
          onPressed: () {},
          child: Text("Demarrer"),
        ),
      ],
    );
  }
}
