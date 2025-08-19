import 'package:flutter/material.dart';
import 'package:login/constants/colors.dart';

class UserInfoCard extends StatefulWidget {
  const UserInfoCard({super.key, required this.email, required this.name, required this.id, required this.address, required this.ville, required this.postalCode, required this.codeAccess});
  final String email;
  final String name;
  final String id;
  final String address;
  final String ville;
  final String postalCode;
  final String codeAccess;

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
                  widget.email,
                  style: TextStyle(color: primaryColor, fontSize: 16),
                ),
                VerticalDivider(color: primaryColor, width: 10),
                Column(
                  children: [
                    Text(
                      widget.name,
                      style: TextStyle(color: primaryColor, fontSize: 16),
                    ),
                    Text(
                      widget.id,
                      style: TextStyle(color: primaryColor, fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            if (isShowContainer) InfoContainer(name: widget.name, address: widget.address, ville: widget.ville, postalCode: widget.postalCode, codeAccess: widget.codeAccess,),
          ],
        ),
      ),
    );
  }
}

class InfoContainer extends StatelessWidget {
  const InfoContainer({super.key, required this.name, required this.address, required this.ville, required this.postalCode, required this.codeAccess});
  final String name;
  final String address;
  final String ville;
  final String postalCode;
  final String codeAccess;
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
                  Text(name),
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
                  Text(address),
                ],
              ),
              Row(
                children: [
                  Text(
                    "Ville :",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(ville),
                ],
              ),
              Row(
                children: [
                  Text(
                    "Code postal :",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(postalCode),
                ],
              ),
              Row(
                children: [
                  Text(
                    "Code Acces :",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(codeAccess),
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
