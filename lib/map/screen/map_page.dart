import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:mamasteps_frontend/map/screen/map_screen.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final dio = Dio();
  PageController _pageController = PageController();
  final List<Widget> _pages = [];
  int _currentPage = 0;
  bool _isLoading = false;
  // List<String> PageViewList = ['첫번째 페이지', '두번째 페이지', '세번째 페이지'];

  // 아직 미완성 코드
  // @override
  // void initState() {
  //   // TODO: implement initState
  //   _pageController.addListener(_handlePageChange);
  //   _loadInitialData();
  //   super.initState();
  // }
  //
  // @override
  // void dispose() {
  //   _pageController.dispose();
  //   super.dispose();
  // }
  //
  // void _handlePageChange(){
  //   if (_pageController.page == _pages.length - 1){
  //     _loadMoreData();
  //   }
  // }
  //
  // Future<void> _loadInitalData() async {
  //   setState(() {
  //     _isLoading = true;
  //   });
  //
  //   var initialData = await dio.get(
  //     'IP 주소를 입력해 주세요',
  //     options: Options(
  //       headers: ['authoraization':'Bearer $access_token'];
  //     )
  //   );
  // }
  //
  // Future<void> _loadMoreData() async {
  //   if (_isLoading) return;
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   var newData = await dio.get(
  //     'IP 주소를 입력해 주세요',
  //     options: Options(
  //       headers: ['authoraization' : 'Bearer $access_token'];
  //     )
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("산책 경로 만들기"),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(child: Text('산책 시간 설정'),
          ),
          //TimePickerDialog(initialTime: TimeOfDay.now()),
          Container(child: Text('산책 경로 선택')),
          Expanded(
            flex: 2,
            child: Container(
                padding: EdgeInsets.all(25.0),
                height: MediaQuery.of(context).size.height / 8,
                //width: MediaQuery.of(context).size.width/2,
                //alignment: Alignment.center,
                child: PageView(
                  children: <Widget>[
                    Container(
                      color: Colors.pink,
                    ),
                    Container(
                      color: Colors.cyan,
                    ),
                    Container(
                      color: Colors.deepPurple,
                    ),
                  ],
                )),
          ),
        ],
      ),
    );
  }
}
