import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamasteps_frontend/ui/model/user_data_model.dart';

class userProfilePage extends StatefulWidget {
  final String? imageUrl;
  final String userEmail;
  final String name;
  final int age;
  final DateTime pregnancyStartDate;
  final String guardianPhoneNumber;
  final String activityLevel;
  final List<WalkPreference> walkPreferences;
  const userProfilePage({
    super.key,
    required this.imageUrl,
    required this.userEmail,
    required this.name,
    required this.age,
    required this.pregnancyStartDate,
    required this.guardianPhoneNumber,
    required this.activityLevel,
    required this.walkPreferences,
  });

  @override
  State<userProfilePage> createState() => _userProfilePageState();
}

class _userProfilePageState extends State<userProfilePage> {
  final nameTextController = TextEditingController();
  final ageTextController = TextEditingController();
  final pregnancyStartTextController = TextEditingController();
  final guardianPhoneNumberController = TextEditingController();
  final activityLevelController = TextEditingController();
  final walkTimeController = TextEditingController();
  // late ApiResponse futureApiResponse;

  @override
  void initState() {
    super.initState();
    nameTextController.text = widget.userEmail;
    ageTextController.text = widget.age.toString();
    pregnancyStartTextController.text =
        DateFormat("yyyy년 MM월 dd일").format(widget.pregnancyStartDate);
    guardianPhoneNumberController.text = widget.guardianPhoneNumber;
    activityLevelController.text = widget.activityLevel;
    // walkTimeController.text = widget.walkPreferences
    //     .map((e) =>
    //         e.dayOfWeek +
    //         ' ' +
    //         e.startTime.toString() +
    //         ' ~ ' +
    //         e.endTime.toString())
    //     .join('\n');
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: Icon(Icons.edit),
        ),
        body: Column(
          children: [
            _Header(
              ImageUrl: widget.imageUrl,
            ),
            _Body(
              nameTextController: nameTextController,
              ageTextController: ageTextController,
              pregnancyStartTextController: pregnancyStartTextController,
              guardianPhoneNumberController: guardianPhoneNumberController,
              activityLevelController: activityLevelController,
              walkTimeController: walkTimeController,
              walkPreferences: widget.walkPreferences,
              // futureApiResponse: initSetting(),
            ),
          ],
        ),
      ),
    );
  }

  // Future<dynamic> initSetting() async {
  //   final url = 'https://dev.mamasteps.dev/api/v1/users/me';
  //   final Access_Token = await storage.read(key: ACCESS_TOKEN_KEY);
  //   try {
  //     final response = await http.post(
  //       Uri.parse(url),
  //       headers: <String, String>{
  //         'Authorization': 'Bearer $Access_Token',
  //         'Content-Type': 'application/json',
  //       },
  //     );
  //
  //     print('Server Response: ${response.statusCode}');
  //     print('Exception: ${response.body}');
  //
  //     if (response.statusCode == 200) {
  //       return ApiResponse.fromJson(jsonDecode(response.body));
  //     } else {
  //       Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => GoogleLogin(),
  //           ));
  //     }
  //   } catch (error) {
  //     print('Error sending POST request: $error');
  //   }
  // }

  // Future<ApiResponse> initSetting() async {
  //   return ApiResponse(
  //     isSuccess: true,
  //     code: '200',
  //     message: '성공',
  //     result: UserProfile(
  //       profileImageUrl:
  //           'https://lh3.googleusercontent.com/a/ACg8ocIr5TFXGf6UJATm6xjdXZ64DRBZfiEn3zdBFKG2EGQbrpg',
  //       email: 'tlgusld03@gmail.com',
  //       name: '김영래',
  //       age: 28,
  //       pregnancyStartDate: DateTime.parse('2024-01-13'),
  //       guardianPhoneNumber: '010-1234-5678',
  //       activityLevel: '보통',
  //       walkPreferences: [
  //         WalkPreference(
  //             dayOfWeek: '월요일', startTime: '10:00', endTime: '11:00'),
  //         WalkPreference(
  //             dayOfWeek: '화요일', startTime: '10:00', endTime: '11:00'),
  //         WalkPreference(
  //             dayOfWeek: '수요일', startTime: '10:00', endTime: '11:00'),
  //         WalkPreference(
  //             dayOfWeek: '목요일', startTime: '10:00', endTime: '11:00'),
  //         WalkPreference(
  //             dayOfWeek: '금요일', startTime: '10:00', endTime: '11:00'),
  //         WalkPreference(
  //             dayOfWeek: '토요일', startTime: '10:00', endTime: '11:00'),
  //         WalkPreference(
  //             dayOfWeek: '일요일', startTime: '10:00', endTime: '11:00'),
  //       ],
  //     ),
  //   );
  // }
}

// class ApiResponse {
//   bool isSuccess;
//   String code;
//   String message;
//   UserProfile result;
//
//   ApiResponse(
//       {required this.isSuccess,
//       required this.code,
//       required this.message,
//       required this.result});
//
//   factory ApiResponse.fromJson(Map<String, dynamic> json) {
//     return ApiResponse(
//       isSuccess: json['isSuccess'],
//       code: json['code'],
//       message: json['message'],
//       result: UserProfile.fromJson(json['result']),
//     );
//   }
// }

// class UserProfile {
//   String profileImageUrl;
//   String email;
//   String name;
//   int age;
//   DateTime pregnancyStartDate;
//   String guardianPhoneNumber;
//   String activityLevel;
//   List<WalkPreference> walkPreferences;
//
//   UserProfile({
//     required this.profileImageUrl,
//     required this.email,
//     required this.name,
//     required this.age,
//     required this.pregnancyStartDate,
//     required this.guardianPhoneNumber,
//     required this.activityLevel,
//     required this.walkPreferences,
//   });
//
//   factory UserProfile.fromJson(Map<String, dynamic> json) {
//     var list = json['walkPreferences'] as List;
//     List<WalkPreference> walkPreferencesList =
//         list.map((i) => WalkPreference.fromJson(i)).toList();
//     return UserProfile(
//       profileImageUrl: json['profileImageUrl'],
//       email: json['email'],
//       name: json['name'],
//       age: json['age'],
//       pregnancyStartDate: DateTime.parse(json['pregnancyStartDate']),
//       guardianPhoneNumber: json['guardianPhoneNumber'],
//       activityLevel: json['activityLevel'],
//       walkPreferences: walkPreferencesList,
//     );
//   }
// }

// class WalkPreference {
//   String dayOfWeek;
//   String startTime;
//   String endTime;
//
//   WalkPreference(
//       {required this.dayOfWeek,
//       required this.startTime,
//       required this.endTime});
//
//   factory WalkPreference.fromJson(Map<String, dynamic> json) {
//     return WalkPreference(
//       dayOfWeek: json['dayOfWeek'],
//       startTime: json['startTime'],
//       endTime: json['endTime'],
//     );
//   }
// }

class _Header extends StatelessWidget {
  final String? ImageUrl;
  const _Header({
    super.key,
    required this.ImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.4,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.2,
              child: Positioned(
                child: Image.asset(
                  'asset/image/others_home_screen_back_ground_image.png',
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            top: 40,
            child: Text(
              "내 정보",
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.normal,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            left: MediaQuery.of(context).size.width * 0.5 - 75,
            top: 110,
            child: ClipOval(
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Image(
                  fit: BoxFit.cover,
                  image: NetworkImage(ImageUrl ??
                      'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/Default_pfp.svg/340px-Default_pfp.svg.png'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Body extends StatefulWidget {
  final TextEditingController nameTextController;
  final TextEditingController ageTextController;
  final TextEditingController pregnancyStartTextController;
  final TextEditingController guardianPhoneNumberController;
  final TextEditingController activityLevelController;
  final TextEditingController walkTimeController;
  final List<WalkPreference> walkPreferences;
  // final Future<ApiResponse> futureApiResponse;

  const _Body({
    super.key,
    required this.nameTextController,
    required this.ageTextController,
    required this.pregnancyStartTextController,
    required this.guardianPhoneNumberController,
    required this.activityLevelController,
    required this.walkTimeController,
    required this.walkPreferences,
    // required this.futureApiResponse,
  });

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    String dayOfWeekToKorean(String day) {
      Map<String, String> dayOfWeekKorean = {
        "Monday": "월요일",
        "Tuesday": "화요일",
        "Wednesday": "수요일",
        "Thursday": "목요일",
        "Friday": "금요일",
        "Saturday": "토요일",
        "Sunday": "일요일",
      };

      // 문자열의 첫 글자를 대문자로 변환하고 나머지는 소문자로 변환하여
      // 맵에서 정확한 키를 찾을 수 있도록 합니다.
      String formattedDay =
          day[0].toUpperCase() + day.substring(1).toLowerCase();

      return dayOfWeekKorean[formattedDay] ?? "알 수 없는 요일";
    }

    return Expanded(
      flex: 1,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: screenWidth,
            height: 600,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ProfileFormField(
                  labelText: '유저 이메일',
                  controller: widget.nameTextController,
                ),
                Divider(),
                ProfileFormField(
                  labelText: '나이',
                  controller: widget.ageTextController,
                ),
                Divider(),
                ProfileFormField(
                  labelText: '임신 날짜',
                  controller: widget.pregnancyStartTextController,
                ),
                Divider(),
                ProfileFormField(
                    labelText: '보호자 전화번호',
                    controller: widget.guardianPhoneNumberController),
                Divider(),
                ProfileFormField(
                  labelText: '평소 활동량',
                  controller: widget.activityLevelController,
                ),
                Divider(),
                Container(
                  width: screenWidth,
                  height: 80,
                  child: Container(
                    width: screenWidth,
                    height: 110,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '산책 선호시간',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: screenWidth,
                          height: 50,
                          child: SingleChildScrollView(
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: widget.walkPreferences
                                    .map<Widget>(
                                      (WalkPreference e) => Text(
                                          dayOfWeekToKorean(e.dayOfWeek) +
                                              ' : ' +
                                              e.startTime.hour.toString() +
                                              "시 " +
                                              e.startTime.minute.toString() +
                                              "분 ~ "+
                                              e.endTime.hour.toString() +
                                              "시 " +
                                              e.endTime.minute.toString() +
                                              "분"),
                                    )
                                    .toList()),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileFormField extends StatefulWidget {
  final String labelText;
  final TextEditingController controller;
  const ProfileFormField({
    Key? key,
    required this.labelText,
    required this.controller,
  }) : super(key: key);

  @override
  State<ProfileFormField> createState() => _ProfileFormFieldState();
}

class _ProfileFormFieldState extends State<ProfileFormField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.labelText,
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextFormField(
              controller: widget.controller,
              decoration: InputDecoration(
                border: InputBorder.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// FutureBuilder(
// future: widget.futureApiResponse, // 비동기 작업의 결과를 기다리는 Future
// builder: (BuildContext context, AsyncSnapshot snapshot) {
// if (snapshot.connectionState == ConnectionState.waiting) {
// // 데이터를 기다리는 동안 로딩 인디케이터를 보여줍니다.
// return CircularProgressIndicator();
// } else if (snapshot.hasError) {
// // 에러가 발생하면 에러 메시지를 보여줍니다.
// return Text('Error: ${snapshot.error}');
// } else if (snapshot.hasData) {
// // 데이터가 정상적으로 반환되었으면, walkPreferences 리스트를 사용하여 위젯을 생성합니다.
// var walkPreferences =
// snapshot.data.result.walkPreferences;
// return Container(
// width: screenWidth,
// height: 110,
// child: Column(
// crossAxisAlignment: CrossAxisAlignment.start,
// children: [
// Text(
// '산책 선호시간',
// style: TextStyle(fontWeight: FontWeight.bold),
// ),
// const SizedBox(height: 8),
// Container(
// width: screenWidth,
// height: 50,
// child: SingleChildScrollView(
// child: Column(
// mainAxisSize: MainAxisSize.min,
// crossAxisAlignment:
// CrossAxisAlignment.start,
// children: walkPreferences
//     .map<Widget>((WalkPreference e) =>
// Text(e.dayOfWeek +
// ' ' +
// e.startTime.toString() +
// ' ~ ' +
// e.endTime.toString()))
//     .toList()),
// ),
// ),
// ],
// ),
// );
// } else {
// return ProfileFormField(
// labelText: '산책 선호시간',
// controller: widget.walkTimeController);
// }
// },
// ),
