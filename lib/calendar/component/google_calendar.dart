import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth show AuthClient;
import 'dart:async';

final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[CalendarApi.calendarScope],
);

Future<CalendarApi> initCalendarApi() async {
  final response = await _googleSignIn.signIn();
  if (response == null) {
    return Future.error('Google Sign In Failed');
  }
  final auth.AuthClient? client = await _googleSignIn.authenticatedClient();
  if (client == null) {
    return Future.error('Google Sign In Failed');
  }
  else{
    var calendar = CalendarApi(client!);
    return calendar;
  }
}
Future<void> insertEvent(CalendarApi calendar, event) async {
  String calendarId = 'primary';

  calendar.events.insert(event, calendarId).then((value) {
    if (value.status == 'confirmed') {
      print('Event added to Google Calendar');
    } else {
      print('Error adding event to Google Calendar');
    }
  });
}

Future<dynamic> getEvent(CalendarApi calendar) async {
  String calendarId = 'primary';
  return calendar.events.list(calendarId);
}

Future<dynamic> getCalendar(CalendarApi calendar, String calendarId) async {
  return calendar.calendars.get(calendarId);
}

Future<dynamic> makeCalendar(CalendarApi calendar) async {
  return calendar.calendars.insert(Calendar());
}
