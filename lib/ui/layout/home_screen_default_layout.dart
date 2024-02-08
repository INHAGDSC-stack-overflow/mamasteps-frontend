import 'package:flutter/material.dart';

class HomeScreenDefaultLayout extends StatelessWidget {
  final Widget Header;
  final List<Widget> Body;


  const HomeScreenDefaultLayout({super.key,
    required this.Header,
    required this.Body,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
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
