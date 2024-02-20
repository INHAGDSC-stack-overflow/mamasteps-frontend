import 'package:flutter/material.dart';
import 'package:charts_flutter_updated/flutter.dart' as charts;
import 'package:mamasteps_frontend/calendar/component/calendar_server_communication.dart';
import 'package:mamasteps_frontend/calendar/model/calendar_schedule_model.dart';
import 'package:mamasteps_frontend/storage/user/user_data.dart';
import 'package:mamasteps_frontend/ui/component/user_server_comunication.dart';
import 'package:mamasteps_frontend/ui/layout/home_screen_default_layout.dart';
import 'package:mamasteps_frontend/ui/model/user_data_model.dart';

class HomeScreen extends StatefulWidget {
  // final int weeks = 16;
  // final int todayWalkTimeMin = 17;
  // final int thisWeekWalkTimeHour = 1;
  // final int thisWeekWalkTimeMin = 26;
  // final int thisWeekAchievement = 10;
  // final int totalWeekAchievement = 20;
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int weeks = 0;
  late int todayWalkTimeTotalSeconds = 0;
  // late int todayWalkTimeMin = 0;
  late int thisWeekWalkTimeTotalSeconds = 0;
  // late int thisWeekWalkTimeHour = 0;
  // late int thisWeekWalkTimeMin = 0;
  late int thisWeekAchievement = 10;
  late int totalWeekAchievement = 20;
  late List<int> weekWalkTime = [0, 0, 0, 0, 0, 0, 0];

  @override
  void initState() {
    super.initState();
    acceptResponse();
    acceptUserResponse();
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double progressRatio = thisWeekAchievement / totalWeekAchievement;
    double progressBarWidth = screenWidth * 0.8 * progressRatio;
    return HomeScreenDefaultLayout(
        Header: _Header(
          weeks: weeks,
        ),
        Body: buildWidgetsList(
            screenWidth,
            // todayWalkTimeMin,
            // thisWeekWalkTimeHour,
            // thisWeekWalkTimeMin,
            todayWalkTimeTotalSeconds,
            thisWeekWalkTimeTotalSeconds,
            thisWeekAchievement,
            totalWeekAchievement,
            weekWalkTime,
            progressBarWidth));
  }

  void acceptUserResponse() async{
    getMeResponse apiResponse = await getMe();
    setState(() {
      DateTime now = DateTime.now();
      Duration difference = now.difference(apiResponse.result.pregnancyStartDate);
      int weeks = difference.inDays ~/ 7;
      if (apiResponse.isSuccess) {
        weeks = weeks;
      }
      user_storage.write(key: 'guardianPhoneNumber', value: apiResponse.result.guardianPhoneNumber);
    });
  }
  void acceptResponse() async {
    getRecordResponse apiResponse = await getRecords();
    setState(() {
      if (apiResponse.isSuccess) {

        DateTime now = DateTime.now();
        DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        DateTime endOfWeek =
        now.add(Duration(days: DateTime.daysPerWeek - now.weekday));

        for (int i = 0; i < apiResponse.result.length; i++) {
          // 이번주 총 산책 시간 계산
          if (apiResponse.result[i].date.isAfter(startOfWeek) &&
              apiResponse.result[i].date.isBefore(endOfWeek)) {
            thisWeekWalkTimeTotalSeconds +=
                apiResponse.result[i].completedTimeSeconds;
            // 요일별 산책 시간 저장
            weekWalkTime[i] = apiResponse.result[i].completedTimeSeconds.toInt() ~/ 3600;
          }

          // 오늘 산책 시간 계산
          apiResponse.result[i].date.isAtSameMomentAs(now)
              ? todayWalkTimeTotalSeconds +=
              apiResponse.result[i].completedTimeSeconds
              : null;
        }
      }
    });
  }
}

class _Header extends StatelessWidget {
  final int weeks;
  const _Header({
    super.key,
    required this.weeks,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 300,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Positioned(
            child: Image.asset(
              'asset/image/root_tab_top_image.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            right: 0,
            child: IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {},
            ),
          ),
          Positioned(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: Text(
                    '임신',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  child: Text(
                    weeks.toString(),
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  child: Text(
                    '주차',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class walkTime {
  final String day_of_week;
  final int sales;

  walkTime(this.day_of_week, this.sales);
}

class SimpleBarChart extends StatelessWidget {
  final List<int> walkTimeList;

  const SimpleBarChart({super.key,
  required this.walkTimeList
  });

  @override
  Widget build(BuildContext context) {
    final List<walkTime> seriesList = [
      walkTime(
        '월',
        walkTimeList[0],
      ),
      walkTime(
        '화',
        walkTimeList[1],
      ),
      walkTime(
        '수',
        walkTimeList[2],
      ),
      walkTime(
        '목',
        walkTimeList[3],
      ),
      walkTime(
        '금',
        walkTimeList[4],
      ),
      walkTime(
        '토',
        walkTimeList[5],
      ),
      walkTime(
        '일',
        walkTimeList[6],
      ),
    ];

    List<charts.Series<walkTime, String>> series = [
      charts.Series(
        id: 'Sales',
        data: seriesList,
        domainFn: (walkTime day_of_week, _) => day_of_week.day_of_week,
        measureFn: (walkTime time, _) => time.sales,
      ),
    ];

    return charts.BarChart(
      series,
      animate: true,
      behaviors: [
        new charts.RangeAnnotation(
          [
            charts.RangeAnnotationSegment(
              3,
              3,
              charts.RangeAnnotationAxisType.measure,
              color: charts.MaterialPalette.gray.shadeDefault,
              startLabel: 'recommended',
              labelDirection: charts.AnnotationLabelDirection.horizontal,
              labelAnchor: charts.AnnotationLabelAnchor.start,
            ),
          ],
        ),
      ],
    );
  }
}

List<Widget> buildWidgetsList(
    double screenWidth,
    // int todayWalkTimeMin,
    // int thisWeekWalkTimeHour,
    // int thisWeekWalkTimeMin,
    int totdayWalkTimeTotalSeconds,
    int thisWeekWalkTimeTotalSeconds,
    int thisWeekAchievement,
    int totalWeekAchievement,
    List<int> weekWalkTime,
    double progressBarWidth) {
  int todayHours = totdayWalkTimeTotalSeconds ~/ 3600;
  int todayMinutes = (totdayWalkTimeTotalSeconds % 3600) ~/ 60;
  int thisWeekWalkTimeHour = thisWeekWalkTimeTotalSeconds ~/ 3600;
  int thisWeekWalkTimeMin = (thisWeekWalkTimeTotalSeconds % 3600) ~/ 60;
  return [
    SizedBox(
      width: screenWidth,
      height: 100,
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                '오늘의 산책 시간',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                '${todayHours.toString().padLeft(2, '0')} 시간 ${todayMinutes.toString().padLeft(2, '0')} 분',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xffa412db),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    const SizedBox(height: 20),
    SizedBox(
      width: screenWidth,
      height: 100,
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                '이번 주 총 산책 시간',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                '${thisWeekWalkTimeHour.toString().padLeft(2, '0')} 시간 ${thisWeekWalkTimeMin.toString().padLeft(2, '0')} 분',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xffa412db),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    const SizedBox(height: 20),
    SizedBox(
      width: screenWidth,
      height: 100,
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    '이번 주 업적 달성률',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  width: screenWidth * 0.17,
                  height: 23,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
                    ),
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    elevation: 2,
                    shadowColor: Colors.blue,
                    child: Center(
                      child: Text(
                        '$thisWeekAchievement/$totalWeekAchievement',
                        style: TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Stack(
                children: <Widget>[
                  Container(
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      height: 20,
                      width: progressBarWidth,
                      decoration: BoxDecoration(
                        color: Color(0xffa412db),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    const SizedBox(height: 20),
    SizedBox(
      width: screenWidth,
      height: 400,
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                '일별 산책 시간',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              height: 300,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: SimpleBarChart(walkTimeList: weekWalkTime,), // 여기에 SimpleBarChart 위젯의 정의가 필요합니다.
              ),
            ),
          ],
        ),
      ),
    ),
  ];
}
