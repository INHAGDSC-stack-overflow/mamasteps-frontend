import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mamasteps_frontend/map/component/util/get_position.dart';
import 'package:mamasteps_frontend/map/screen/map_page.dart';
import 'package:mamasteps_frontend/ui/component/user_server_comunication.dart';
import 'package:mamasteps_frontend/ui/model/user_data_model.dart';

class HomeScreenDefaultLayout extends StatefulWidget {
  final Widget Header;
  final List<Widget> Body;

  const HomeScreenDefaultLayout({
    super.key,
    required this.Header,
    required this.Body,
  });

  @override
  State<HomeScreenDefaultLayout> createState() => _HomeScreenDefaultLayoutState();
}

class _HomeScreenDefaultLayoutState extends State<HomeScreenDefaultLayout> {
  late int walkSpeed;

  void acceptGetInfo() async {
    myInfo apiResponse = await getMyInfo(context);
    setState(() {
      if (apiResponse.isSuccess) {
        walkSpeed = apiResponse.walkSpeed;
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    acceptGetInfo();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        floatingActionButton: SizedBox(
          width: 100,
          child: FloatingActionButton(
            onPressed: () async {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MapPage(
                    walkSpeed: walkSpeed,
                  ),
                ),
              );
            },
            child: Text(
              '산책시작',
              style: TextStyle(
                fontSize: 20, // FloatingActionButton의 크기에 맞게 텍스트 크기 조정
                fontWeight: FontWeight.normal,
                color: Colors.white,
              ),
            ),
            backgroundColor: Color(0xFFA412DB),
            // 버튼의 모양을 정의
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(40), // 여기서 원하는 둥근 정도를 조정하세요
              ),
            ),
          ),
        ),
        body: SizedBox(
          width: screenWidth,
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: Column(
              children: [
                widget.Header,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: widget.Body,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
