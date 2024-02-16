import 'package:flutter/material.dart';
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
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MapPage(),
                ),
              );
            },
            child: const Text('산책시작',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                )),
            backgroundColor: const Color(0xFFA412DB),
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
