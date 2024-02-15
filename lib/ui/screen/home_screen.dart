import 'package:flutter/material.dart';
import 'package:charts_flutter_updated/flutter.dart' as charts;
import 'package:mamasteps_frontend/ui/layout/home_screen_default_layout.dart';

class HomeScreen extends StatefulWidget {
  final int weeks = 16;
  final int todayWalkTimeMin = 17;
  final int thisWeekWalkTimeHour = 1;
  final int thisWeekWalkTimeMin = 26;
  final int thisWeekAchievement = 10;
  final int totalWeekAchievement = 20;
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final int weeks = 16;
  final int todayWalkTimeMin = 17;
  final int thisWeekWalkTimeHour = 1;
  final int thisWeekWalkTimeMin = 26;
  final int thisWeekAchievement = 10;
  final int totalWeekAchievement = 20;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double progressRatio = thisWeekAchievement / totalWeekAchievement;
    double progressBarWidth = screenWidth * 0.8 * progressRatio;
    return HomeScreenDefaultLayout(
        Header: _Header(
          weeks: 10,
        ),
        Body: buildWidgetsList(
            screenWidth,
            todayWalkTimeMin,
            thisWeekWalkTimeHour,
            thisWeekWalkTimeMin,
            thisWeekAchievement,
            totalWeekAchievement,
            progressBarWidth));
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
    return Stack(
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
                    fontSize: 24,
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
    );
  }
}

class walkTime {
  final String day_of_week;
  final int sales;

  walkTime(this.day_of_week, this.sales);
}

class SimpleBarChart extends StatelessWidget {
  const SimpleBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    final List<walkTime> seriesList = [
      walkTime(
        '월',
        1,
      ),
      walkTime(
        '화',
        2,
      ),
      walkTime(
        '수',
        3,
      ),
      walkTime(
        '목',
        4,
      ),
      walkTime(
        '금',
        5,
      ),
      walkTime(
        '토',
        6,
      ),
      walkTime(
        '일',
        7,
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
    int todayWalkTimeMin,
    int thisWeekWalkTimeHour,
    int thisWeekWalkTimeMin,
    int thisWeekAchievement,
    int totalWeekAchievement,
    double progressBarWidth) {
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
                '$todayWalkTimeMin M',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
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
                '${thisWeekWalkTimeHour}H ${thisWeekWalkTimeMin}M',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
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
                        color: Colors.blue,
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
                child: SimpleBarChart(), // 여기에 SimpleBarChart 위젯의 정의가 필요합니다.
              ),
            ),
          ],
        ),
      ),
    ),
  ];
}
