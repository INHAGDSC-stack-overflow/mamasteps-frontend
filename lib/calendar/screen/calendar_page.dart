import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class TableCalendarPage extends StatefulWidget {
  const TableCalendarPage({super.key});

  @override
  State<TableCalendarPage> createState() => _TableCalendarPageState();
}

class _TableCalendarPageState extends State<TableCalendarPage> {
  @override
  void initState() {
    super.initState();
    selectedEvents = ValueNotifier(_getEventsForDay(selectedDay));
  }

  @override
  void dispose() {
    selectedEvents.dispose();
    super.dispose();
  }

  late final ValueNotifier<List<Event>> selectedEvents;
  DateTime selectedDay = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  DateTime focusedDay = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              _showAddDialog();
            }),
        body: Column(
          children: [
            Expanded(
              flex: 1,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Positioned(
                    child: Image.asset(
                      'asset/image/others_home_screen_back_ground_image.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 40,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "산책 일정 관리",
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.normal,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  TableCalendar(
                    // 캘린더
                    locale: 'ko_KR',
                    firstDay: DateTime.utc(2010, 10, 16),
                    lastDay: DateTime.utc(2030, 3, 14),
                    focusedDay: focusedDay,
                    onDaySelected: _onDaySelected,
                    selectedDayPredicate: (DateTime day) {
                      return isSameDay(selectedDay, day);
                    },
                    eventLoader: _getEventsForDay,
                  ),
                  Padding(
                    //날짜 출력부
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        DateFormat('yyyy년 MM월 dd일 산책일정').format(selectedDay),
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.normal),
                      ),
                    ),
                  ),
                  Expanded(
                    // 이벤트 리스트 출력부
                    child: ValueListenableBuilder<List<Event>>(
                      valueListenable: selectedEvents,
                      builder: (context, value, _) {
                        return ListView.builder(
                          itemCount: value.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: InkWell(
                                onTap: () {
                                  _showEditDialog(index);
                                },
                                child: SizedBox(
                                  height: 50,
                                  child: Card(
                                    color: Colors.white,
                                    elevation: 0,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Align(
                                          child: Text(
                                            value[index].title,
                                            style: TextStyle(
                                              color: Colors.blue,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          alignment: Alignment.centerLeft),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(this.selectedDay, selectedDay)) {
      setState(() {
        this.selectedDay = selectedDay;
        this.focusedDay = focusedDay;
      });
      this.selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  void _showAddDialog() {
    final TextEditingController _eventController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Event'),
        content: TextField(
          controller: _eventController,
          decoration: InputDecoration(hintText: 'Event Name'),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_eventController.text.isEmpty) return;
              setState(
                () {
                  if (events[selectedDay] != null) {
                    events[selectedDay]!.add(Event(_eventController.text));
                  } else {
                    events[selectedDay] = [Event(_eventController.text)];
                  }
                },
              );
              _eventController.clear();
              Navigator.of(context).pop();
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(index) {
    final TextEditingController _eventController = TextEditingController();
    _eventController.text = events[selectedDay]![index].title;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Event'),
        content: TextField(
          controller: _eventController,
          decoration: InputDecoration(hintText: 'Event Name'),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_eventController.text.isEmpty) return;
              setState(() {
                events[selectedDay]![index].title = _eventController.text;
              });
              _eventController.clear();
              Navigator.of(context).pop();
            },
            child: Text('Save'),
          ),
          TextButton(
            child: Text('delete'),
            onPressed: () {
              setState(
                () {
                  events[selectedDay]!.removeAt(index);
                },
              );
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

class Event {
  String title;

  Event(this.title);
}

Map<DateTime, List<Event>> events = {
  DateTime.utc(2024, 2, 2): [Event('17 분'), Event('18 분')],
  DateTime.utc(2024, 2, 3): [Event('20 분')],
};

List<Event> _getEventsForDay(DateTime day) {
  return events[day] ?? [];
}