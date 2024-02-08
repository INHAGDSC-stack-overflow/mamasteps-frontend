import 'package:flutter/material.dart';
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
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            _showAddDialog();
          }),
      body: Column(
        children: [
          TableCalendar(
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
          Expanded(
            child: ValueListenableBuilder<List<Event>>(
              valueListenable: selectedEvents,
              builder: (context, value, _) {
                return ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(value[index].title),
                    );
                  },
                );
              },
            ),
          ),
        ],
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
                    setState(() {
                      if (events[selectedDay] != null) {
                        events[selectedDay]!.add(Event(_eventController.text));
                      } else {
                        events[selectedDay] = [Event(_eventController.text)];
                      }
                    });
                    _eventController.clear();
                    Navigator.of(context).pop();
                  },
                  child: Text('Save'),
                ),
              ],
            ));
  }
}

class Event {
  String title;

  Event(this.title);
}

Map<DateTime, List<Event>> events = {
  DateTime.utc(2024, 2, 2): [Event('Event 1'), Event('Event 2')],
  DateTime.utc(2024, 2, 3): [Event('Event 3')],
};

List<Event> _getEventsForDay(DateTime day) {
  return events[day] ?? [];
}
