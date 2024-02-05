import 'package:flutter/material.dart';
import 'package:mamasteps_frontend/map/screen/map_page.dart';

class RootTab extends StatefulWidget {
  const RootTab({super.key});

  @override
  State<RootTab> createState() => _RootTabState();
}

class _RootTabState extends State<RootTab> with SingleTickerProviderStateMixin {
  late TabController controller;
  int index = 0;
  @override
  void initState() {
    super.initState();
    controller = TabController(length: 3, vsync: this);
    controller.addListener(tabListener);
  }

  void tabListener() {
    setState(() {
      index = controller.index;
    });
  }

  void dispose() {
    controller.removeListener(tabListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height*0.4,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                        'asset/image/root_tab_top_image.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Center(
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                controller: controller,
                children: [
                  Center(
                    child: Container(
                      child: Text('홈'),
                    ),
                  ),
                  Center(
                    child: Container(
                      child: MapPage(),
                    ),
                  ),
                  Center(
                    child: Container(
                      child: Text('프로필'),
                    ),
                  ),
                ],
              ),
            ),
          ],

        ),
        bottomNavigationBar: BottomNavigationBar(
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.grey,
            selectedFontSize: 10,
            unselectedFontSize: 10,
            type: BottomNavigationBarType.fixed,
            onTap: (int index) {
              controller.animateTo(index);
            },
            currentIndex: index,
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),label: ''),
              BottomNavigationBarItem(
                  icon: Icon(Icons.map_outlined), label: ''),
              BottomNavigationBarItem(
                  icon: Icon(Icons.supervised_user_circle_outlined), label: ''),
            ]),
      ),
    );
  }
}
