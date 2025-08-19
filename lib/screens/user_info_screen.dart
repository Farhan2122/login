import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:login/api/api_services.dart';
import 'package:login/constants/colors.dart';
import 'package:login/model/visit_model.dart';
import 'package:login/widgets/custom_icon_btn.dart';
import 'package:login/widgets/user_info_card.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  FlutterSecureStorage storage = FlutterSecureStorage();
  late Future<List<VisitModel>> _visitFuture;
  ApiServices apiServices = ApiServices();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _visitFuture = apiServices.makeSecureApiCall();
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
              icon: Icon(CupertinoIcons.bars, color: primaryColor, size: 40),
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
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Liste des RES020',
                    style: TextStyle(color: primaryColor, fontSize: 20),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomIconBtn(
                        text: 'Filtre',
                        icon: Icon(Icons.arrow_downward),
                      ),
                      GestureDetector(
                        onTap: apiServices.makeSecureApiCall,
                        child: CustomIconBtn(
                          text: 'Rafraichir',
                          icon: Icon(CupertinoIcons.arrow_clockwise),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 25),
                  FutureBuilder<List<VisitModel>>(
                    future: _visitFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text("No visits found."));
                      } else {
                        final visits = snapshot.data!;
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: visits.length,
                          itemBuilder: (context, index) {
                            final visit = visits[index];
                            return Container(
                              margin: EdgeInsets.symmetric(vertical: 10),
                              child: UserInfoCard(
                                email: visit.email,
                                name: visit.name,
                                id: visit.id.toString(),
                                address: visit.address,
                                ville: visit.ville,
                                postalCode: visit.postalCode,
                                codeAccess: visit.postalCode,
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
