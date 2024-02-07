import 'package:flutter/material.dart';

class SignUpDefaultLayout extends StatelessWidget {
  final Widget child;

  const SignUpDefaultLayout({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand, // Stack을 가능한 전체 영역으로 확장합니다.
      children: <Widget>[
        // 배경 이미지를 먼저 넣습니다.
        Align(
          alignment: Alignment.topCenter, // 이미지를 상단 중앙에 배치합니다.
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height*0.9,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'asset/image/sign_up_back_ground_image.png'), // 로컬 에셋에서 이미지를 로드합니다.
                fit: BoxFit.cover, // 이미지가 전체 컨테이너를 커버하도록 합니다.
              ),
            ),
          ),
        ),
        // 여기에 다른 위젯들을 배치합니다.
        // 예시로, 중앙에 메시지를 표시하는 위젯을 배치할 수 있습니다.
        Center(
          child: child,
        ),
      ],
    );
  }
}
