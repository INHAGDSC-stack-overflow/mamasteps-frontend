import 'package:flutter/material.dart';
import 'package:mamasteps_frontend/map/screen/map_screen.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  PageController controller = PageController();
  var currentPageValue = 0.0;
  List<String> PageViewList = ['첫번째 페이지', '두번째 페이지', '세번째 페이지'];

  @override
  void initState() {
    // TODO: implement initState
    controller.addListener(() {
      setState(() {
        currentPageValue = controller.page;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("산책 경로 만들기"),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Text('산책 시간 설정'),
          //TimePickerDialog(initialTime: TimeOfDay.now()),
          Text('산책 경로 선택'),
          Container(
            child: PageView.builder(itemBuilder: (context,position){
              return Transform(
                transform: Matrix4.identity()
                ..rotateX(currentPageValue - position),
                child: pageViewList[position],
              );
            })
          )
        ],
      ),
    );
  }
}
