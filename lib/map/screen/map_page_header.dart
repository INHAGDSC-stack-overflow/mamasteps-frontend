import 'package:flutter/material.dart';

//상단 헤더
class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Container(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Positioned(
              child: Image.asset(
                'asset/image/others_home_screen_back_ground_image.png',
                fit: BoxFit.cover,
              ),
            ),
            const Positioned(
              left: 0,
              top: 40,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "산책 경로 만들기",
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}