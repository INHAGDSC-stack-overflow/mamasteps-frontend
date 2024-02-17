import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamasteps_frontend/login/screen/login_page.dart';
import 'package:mamasteps_frontend/storage/login/login_data.dart';

class userProfilePage extends StatefulWidget {
  const userProfilePage({super.key});

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
  late ApiResponse futureApiResponse;

  @override
  void initState() {
    super.initState();
    initSetting().then((value) {
      setState(() {
        futureApiResponse = value;
        nameTextController.text = futureApiResponse.result.name;
        ageTextController.text = futureApiResponse.result.age.toString();
        pregnancyStartTextController.text = DateFormat('yyyy년 MM월 dd일')
            .format(futureApiResponse.result.pregnancyStartDate);
        guardianPhoneNumberController.text =
            futureApiResponse.result.guardianPhoneNumber;
        activityLevelController.text = futureApiResponse.result.activityLevel;
        walkTimeController.text = futureApiResponse.result.walkPreferences
            .map((e) => e.dayOfWeek + ' ' + e.startTime + ' ~ ' + e.endTime)
            .join('\n');
      });
    });
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
            _Header(),
            _Body(
              nameTextController: nameTextController,
              ageTextController: ageTextController,
              pregnancyStartTextController: pregnancyStartTextController,
              guardianPhoneNumberController: guardianPhoneNumberController,
              activityLevelController: activityLevelController,
              walkTimeController: walkTimeController,
              futureApiResponse: initSetting(),
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

  Future<ApiResponse> initSetting() async {
    return ApiResponse(
      isSuccess: true,
      code: '200',
      message: '성공',
      result: UserProfile(
        profileImageUrl:
            'https://lh3.googleusercontent.com/a/ACg8ocIr5TFXGf6UJATm6xjdXZ64DRBZfiEn3zdBFKG2EGQbrpg',
        email: 'tlgusld03@gmail.com',
        name: '김태훈',
        age: 28,
        pregnancyStartDate: DateTime.parse('2021-08-01'),
        guardianPhoneNumber: '010-1234-5678',
        activityLevel: '보통',
        walkPreferences: [
          WalkPreference(
              dayOfWeek: '월요일', startTime: '10:00', endTime: '11:00'),
          WalkPreference(
              dayOfWeek: '화요일', startTime: '10:00', endTime: '11:00'),
          WalkPreference(
              dayOfWeek: '수요일', startTime: '10:00', endTime: '11:00'),
          WalkPreference(
              dayOfWeek: '목요일', startTime: '10:00', endTime: '11:00'),
          WalkPreference(
              dayOfWeek: '금요일', startTime: '10:00', endTime: '11:00'),
          WalkPreference(
              dayOfWeek: '토요일', startTime: '10:00', endTime: '11:00'),
          WalkPreference(
              dayOfWeek: '일요일', startTime: '10:00', endTime: '11:00'),
        ],
      ),
    );
  }
}

class ApiResponse {
  bool isSuccess;
  String code;
  String message;
  UserProfile result;

  ApiResponse(
      {required this.isSuccess,
      required this.code,
      required this.message,
      required this.result});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      isSuccess: json['isSuccess'],
      code: json['code'],
      message: json['message'],
      result: UserProfile.fromJson(json['result']),
    );
  }
}

class UserProfile {
  String profileImageUrl;
  String email;
  String name;
  int age;
  DateTime pregnancyStartDate;
  String guardianPhoneNumber;
  String activityLevel;
  List<WalkPreference> walkPreferences;

  UserProfile({
    required this.profileImageUrl,
    required this.email,
    required this.name,
    required this.age,
    required this.pregnancyStartDate,
    required this.guardianPhoneNumber,
    required this.activityLevel,
    required this.walkPreferences,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    var list = json['walkPreferences'] as List;
    List<WalkPreference> walkPreferencesList =
        list.map((i) => WalkPreference.fromJson(i)).toList();
    return UserProfile(
      profileImageUrl: json['profileImageUrl'],
      email: json['email'],
      name: json['name'],
      age: json['age'],
      pregnancyStartDate: DateTime.parse(json['pregnancyStartDate']),
      guardianPhoneNumber: json['guardianPhoneNumber'],
      activityLevel: json['activityLevel'],
      walkPreferences: walkPreferencesList,
    );
  }
}

class WalkPreference {
  String dayOfWeek;
  String startTime;
  String endTime;

  WalkPreference(
      {required this.dayOfWeek,
      required this.startTime,
      required this.endTime});

  factory WalkPreference.fromJson(Map<String, dynamic> json) {
    return WalkPreference(
      dayOfWeek: json['dayOfWeek'],
      startTime: json['startTime'],
      endTime: json['endTime'],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({super.key});

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
                  image: NetworkImage(
                      'https://lh3.googleusercontent.com/a/ACg8ocIr5TFXGf6UJATm6xjdXZ64DRBZfiEn3zdBFKG2EGQbrpg'),
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
  final Future<ApiResponse> futureApiResponse;

  const _Body({
    super.key,
    required this.nameTextController,
    required this.ageTextController,
    required this.pregnancyStartTextController,
    required this.guardianPhoneNumberController,
    required this.activityLevelController,
    required this.walkTimeController,
    required this.futureApiResponse,
  });

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
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
                  labelText: '이름',
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
                  child: FutureBuilder(
                    future: widget.futureApiResponse, // 비동기 작업의 결과를 기다리는 Future
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // 데이터를 기다리는 동안 로딩 인디케이터를 보여줍니다.
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        // 에러가 발생하면 에러 메시지를 보여줍니다.
                        return Text('Error: ${snapshot.error}');
                      } else if (snapshot.hasData) {
                        // 데이터가 정상적으로 반환되었으면, walkPreferences 리스트를 사용하여 위젯을 생성합니다.
                        var walkPreferences =
                            snapshot.data.result.walkPreferences;
                        return Container(
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: walkPreferences
                                          .map<Widget>((WalkPreference e) =>
                                              Text(e.dayOfWeek +
                                                  ' ' +
                                                  e.startTime +
                                                  ' ~ ' +
                                                  e.endTime))
                                          .toList()),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return ProfileFormField(
                            labelText: '산책 선호시간',
                            controller: widget.walkTimeController);
                      }
                    },
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
