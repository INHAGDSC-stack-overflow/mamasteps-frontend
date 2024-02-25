import 'dart:async';
import 'package:googleapis/calendar/v3.dart';

// String apikey = dotenv.env['myClientId'].toString();
// final GoogleSignIn _googleSignIn = GoogleSignIn(
//   // Optional clientId
//   // clientId: '[YOUR_OAUTH_2_CLIENT_ID]',
//   scopes: <String>[CalendarApi.calendarScope],
// );
//
// // void main() {
// //   runApp(
// //     const MaterialApp(
// //       title: 'Google Sign In + googleapis',
// //       home: SignInDemo(),
// //     ),
// //   );
// // }
//
// /// The main widget of this demo.
// class SignInDemo extends StatefulWidget {
//   /// Creates the main widget of this demo.
//   const SignInDemo({super.key});
//
//   @override
//   State createState() => SignInDemoState();
// }
//
// /// The state of the main widget.
// class SignInDemoState extends State<SignInDemo> {
//   GoogleSignInAccount? _currentUser;
//   String _contactText = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
//       setState(() {
//         _currentUser = account;
//         print("currentUser : " + _currentUser.toString());
//       });
//       if (_currentUser != null) {
//         _handleGetContact();
//       }
//     });
//     _googleSignIn.signInSilently();
//   }
//
//   Future<void> _handleGetContact() async {
//     setState(() {
//       _contactText = 'Loading contact info...';
//     });
//
// // #docregion CreateAPIClient
//     // Retrieve an [auth.AuthClient] from the current [GoogleSignIn] instance.
//     final auth.AuthClient? client = await _googleSignIn.authenticatedClient();
//
//     assert(client != null, 'Authenticated client missing!');
//
//     // Prepare a People Service authenticated client.
//     final CalendarApi calendarApi = CalendarApi(client!);
//     // Retrieve a list of the `names` of my `connections`
//     final Calendar response =
//         await calendarApi.calendars.get('tlgusdl03@gmail.com') as Calendar;
//     print("getCalendar response : " + response.id.toString());
//     // #enddocregion CreateAPIClient
//     //getCalendar(client);
//
//     final Events eventResponse =
//         await calendarApi.events.list('primary') as Events;
//
//     if (eventResponse.items?.first.start?.date?.day != null) {
//       // 여기서는 `!` 연산자 대신 `?.` 연산자를 사용했기 때문에 안전합니다.
//       var date = eventResponse.items!.first.start?.date?.day.toString();
//       print("getEventCalendar response : " + date.toString());
//     } else {
//       print("response doesn`t exist");
//     }
//
//     var tempEvent = Event(
//         summary: "testEvent",
//         start: EventDateTime(
//           dateTime: DateTime.now().add(Duration(hours:2)),
//         ),
//         end: EventDateTime(
//           dateTime: DateTime.now().add(Duration(hours: 3)),
//         ));
//
//     final Event insertResponse =
//         await calendarApi.events.insert(tempEvent, 'primary');
//
//     print(insertResponse.toString());
//   }
//
//   Future<void> _handleSignIn() async {
//     try {
//       await _googleSignIn.signIn();
//     } catch (error) {
//       print(error); // ignore: avoid_print
//     }
//   }
//
//   Future<void> _handleSignOut() => _googleSignIn.disconnect();
//
//   Widget _buildBody() {
//     final GoogleSignInAccount? user = _currentUser;
//     if (user != null) {
//       return Column(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: <Widget>[
//           ListTile(
//             leading: GoogleUserCircleAvatar(
//               identity: user,
//             ),
//             title: Text(user.displayName ?? ''),
//             subtitle: Text(user.email),
//           ),
//           const Text('Signed in successfully.'),
//           Text(_contactText),
//           ElevatedButton(
//             onPressed: _handleSignOut,
//             child: const Text('SIGN OUT'),
//           ),
//           ElevatedButton(
//             onPressed: _handleGetContact,
//             child: const Text('REFRESH'),
//           ),
//         ],
//       );
//     } else {
//       return Column(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: <Widget>[
//           const Text('You are not currently signed in.'),
//           ElevatedButton(
//             onPressed: _handleSignIn,
//             child: const Text('SIGN IN'),
//           ),
//         ],
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: const Text('Google Sign In + googleapis'),
//         ),
//         body: ConstrainedBox(
//           constraints: const BoxConstraints.expand(),
//           child: _buildBody(),
//         ));
//   }
// }

// Future<void> getCalendar(auth.AuthClient client) async {
// // #docregion CreateAPIClient
//   // Retrieve an [auth.AuthClient] from the current [GoogleSignIn] instance.
//   // Prepare a People Service authenticated client.
//   final CalendarApi calendarApi = CalendarApi(client!);
//   // Retrieve a list of the `names` of my `connections`
//   final Calendar response =
//       await calendarApi.calendarList.get('primary') as Calendar;
//   print("getCalendar response : " + response.toString());
//   // #enddocregion CreateAPIClient
// }

Future<Events> getEvents(CalendarApi calendarApi) async {
  final Events response = await calendarApi.events.list('primary');

  return response;
}

Future<Event> insertEvents(CalendarApi calendarApi, Event data)  async {
  final Event response = await calendarApi.events.insert(data, 'primary');
  print("insert Events response : $response");
  return response;
}