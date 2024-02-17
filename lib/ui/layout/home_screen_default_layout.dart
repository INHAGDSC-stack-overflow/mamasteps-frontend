import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mamasteps_frontend/map/component/util/get_position.dart';
import 'package:mamasteps_frontend/map/screen/map_page.dart';

class HomeScreenDefaultLayout extends StatelessWidget {
  final Widget Header;
  final List<Widget> Body;

  const HomeScreenDefaultLayout({
    super.key,
    required this.Header,
    required this.Body,
  });

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
        body: Column(
          children: [
            Expanded(
              flex: 2,
              child: Header,
            ),
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: Body,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
