// import 'package:flutter/material.dart';
// import 'package:mamasteps_frontend/map/component/timer/convert.dart';
// import 'package:mamasteps_frontend/map/component/timer/count_down_timer.dart';
// import 'package:mamasteps_frontend/ui/screen/root_tab.dart';
//
// class AfterWalking extends StatefulWidget {
//   final int totalSeconds;
//
//   const AfterWalking({
//     super.key,
//     required this.totalSeconds,
//   });
//
//   @override
//   State<AfterWalking> createState() => _AfterWalkingState();
// }
//
// class _AfterWalkingState extends State<AfterWalking> {
//   double currentSliderValue = 0;
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Color(0xff5f5f5),
//         body: Column(
//           children: [
//             _Header(),
//             _Body(
//               totalSeconds: widget.totalSeconds,
//               currentSliderValue: currentSliderValue,
//               onSliderChange: onSliderChange,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void onSliderChange(double value) {
//     setState(() {
//       currentSliderValue = value;
//     });
//   }
// }
//
// //상단 헤더
// class _Header extends StatelessWidget {
//   const _Header({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       flex: 1,
//       child: Container(
//         child: Stack(
//           fit: StackFit.expand,
//           children: <Widget>[
//             Positioned(
//               child: Image.asset(
//                 'asset/image/others_home_screen_back_ground_image.png',
//                 fit: BoxFit.cover,
//               ),
//             ),
//             Positioned(
//               left: 0,
//               top: 40,
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 child: Text(
//                   "산책이 끝났어요!",
//                   style: TextStyle(
//                     fontSize: 35,
//                     fontWeight: FontWeight.normal,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _Body extends StatefulWidget {
//   final int totalSeconds;
//   final double currentSliderValue;
//   final ValueChanged onSliderChange;
//   const _Body({
//     super.key,
//     required this.totalSeconds,
//     required this.currentSliderValue,
//     required this.onSliderChange,
//   });
//
//   @override
//   State<_Body> createState() => _BodyState();
// }
//
// class _BodyState extends State<_Body> {
//   late List<int> numbers;
//   late int hour;
//   late int min;
//   late int sec;
//   int reaction = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     initTimeSet(widget.totalSeconds, numbers, hour, min, sec);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       flex: 3,
//       child: Column(
//         children: [
//           SizedBox(
//             height: 150,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Text('총 산책 시간'),
//                 Container(
//                   child: Card(
//                     child: Center(
//                       child: Text(
//                         '$hour:$min:$sec',
//                         style: TextStyle(fontSize: 48),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 20),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               Container(
//                 child: Column(
//                   children: [
//                     ElevatedButton(
//                       onPressed: () {},
//                       child: Image.asset('asset/image/easy.png'),
//                     ),
//                     Text('쉬워요'),
//                   ],
//                 ),
//               ),
//               Container(
//                 child: Column(
//                   children: [
//                     ElevatedButton(
//                       onPressed: () {},
//                       child: Image.asset('asset/image/good.png'),
//                     ),
//                     Text('적당해요'),
//                   ],
//                 ),
//               ),
//               Container(
//                 child: Column(
//                   children: [
//                     ElevatedButton(
//                       onPressed: () {},
//                       child: Image.asset('asset/image/hard.png'),
//                     ),
//                     Text('힘들어요'),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           Container(
//             child: Text('강도를 평가해 주세요!\n "약간 힘든 정도"가 제일 적당합니다!'),
//           ),
//           Align(
//             alignment: Alignment.bottomLeft,
//             child: IconButton(
//               onPressed: () {
//                 Navigator.of(context).pushAndRemoveUntil(
//                   MaterialPageRoute(
//                     builder: (_) => RootTab(),
//                   ),
//                   (route) => false,
//                 );
//               },
//               icon: Icon(Icons.arrow_back),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void initTimeSet(
//       int totalsec, List<int> numbers, int hour, int min, int sec) {
//     numbers = totalToHMS(totalsec);
//     hour = numbers[0];
//     min = numbers[1];
//     sec = numbers[2];
//   }
//
//   Widget afterWalkingScreenbuilder(BuildContext context) {
//     if (reaction == null) {
//       return Expanded(
//         flex: 3,
//         child: Column(
//           children: [
//             SizedBox(
//               height: 150,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   Text('총 산책 시간'),
//                   Container(
//                     child: Card(
//                       child: Center(
//                         child: Text(
//                           '$hour:$min:$sec',
//                           style: TextStyle(fontSize: 48),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 Container(
//                   child: Column(
//                     children: [
//                       ElevatedButton(
//                         onPressed: () {},
//                         child: Image.asset('asset/image/easy.png'),
//                       ),
//                       Text('쉬워요'),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   child: Column(
//                     children: [
//                       ElevatedButton(
//                         onPressed: () {},
//                         child: Image.asset('asset/image/good.png'),
//                       ),
//                       Text('적당해요'),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   child: Column(
//                     children: [
//                       ElevatedButton(
//                         onPressed: () {},
//                         child: Image.asset('asset/image/hard.png'),
//                       ),
//                       Text('힘들어요'),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             Container(
//               child: Text('강도를 평가해 주세요!\n "약간 힘든 정도"가 제일 적당합니다!'),
//             ),
//             Align(
//               alignment: Alignment.bottomLeft,
//               child: IconButton(
//                 onPressed: () {
//                   Navigator.of(context).pushAndRemoveUntil(
//                     MaterialPageRoute(
//                       builder: (_) => RootTab(),
//                     ),
//                     (route) => false,
//                   );
//                 },
//                 icon: Icon(Icons.arrow_back),
//               ),
//             ),
//           ],
//         ),
//       );
//     } else if (reaction == 0 || reaction == 2) {
//       return Container(
//         child: _MiddleOfBody(
//           image: Image.asset('asset/image/easy.png'),
//           currentSliderValue: widget.currentSliderValue,
//           onSliderChange: widget.onSliderChange,
//         ),
//       );
//     } else {
//       return Container();
//     }
//   }
// }
//
// class _MiddleOfBody extends StatefulWidget {
//   final double currentSliderValue;
//   final Image image;
//   final ValueChanged onSliderChange;
//   const _MiddleOfBody({
//     super.key,
//     required this.image,
//     required this.currentSliderValue,
//     required this.onSliderChange,
//   });
//
//   @override
//   State<_MiddleOfBody> createState() => _MiddleOfBodyState();
// }
//
// class _MiddleOfBodyState extends State<_MiddleOfBody> {
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Container(
//           height: 50,
//           child: Column(children: [
//             widget.image,
//             Text('쉬워요'),
//           ]),
//         ),
//         const SizedBox(height: 16.0),
//         Slider(
//           value: widget.currentSliderValue,
//           min: 0,
//           max: 70,
//           divisions: 8,
//           onChanged: (double value) {
//             widget.onSliderChange(value);
//           },
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             Text('너무 쉬워요')
//           ]
//         )
//       ],
//     );
//   }
// }
