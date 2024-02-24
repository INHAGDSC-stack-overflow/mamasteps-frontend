import 'package:googleapis/cloudsearch/v1.dart';

class getMeResponse {
  final bool isSuccess;
  final String code;
  final String message;
  final List<dynamic> pregnancyStartDate;
  final String guardianPhoneNumber;
  final UserProfile result;

  getMeResponse({
    required this.isSuccess,
    required this.code,
    required this.message,
    required this.pregnancyStartDate,
    required this.guardianPhoneNumber,
    required this.result,
  });

  factory getMeResponse.fromJson(Map<String, dynamic> json) {
    return getMeResponse(
      isSuccess: json['isSuccess'],
      code: json['code'],
      message: json['message'],
      pregnancyStartDate: json['result']['pregnancyStartDate'],
      guardianPhoneNumber: json['result']['guardianPhoneNumber'],
      result: UserProfile.fromJson(json['result']),
    );
  }
}

class UserProfile {
  final String? profileImageUrl;
  final String email;
  final String name;
  final int age;
  final DateTime pregnancyStartDate;
  final String guardianPhoneNumber;
  final String activityLevel;
  final List<WalkPreference> walkPreferences;

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
    var dateList = json['pregnancyStartDate'] as List;
    DateTime date = DateTime(
      dateList[0],
      dateList[1],
      dateList[2],
      dateList[3],
      dateList[4],
    );
    var prefsJson = json['walkPreferences'] as List<dynamic>;
    print(prefsJson);
    List<WalkPreference> prefs = prefsJson.map((prefJson) => WalkPreference.fromJson(prefJson as Map<String, dynamic>)).toList();
    return UserProfile(
      profileImageUrl: json['profileImageUrl'],
      email: json['email'],
      name: json['name'],
      age: json['age'],
      pregnancyStartDate: date,
      guardianPhoneNumber: json['guardianPhoneNumber'],
      activityLevel: json['activityLevel'],
      walkPreferences: prefs,
    );
  }
}

class WalkPreference {
  final String dayOfWeek;
  final DateTime startTime;
  final DateTime endTime;

  WalkPreference({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  factory WalkPreference.fromJson(Map<String, dynamic> json) {
    var startTimeList = json['startTime'] as List<dynamic>;
    var endTimeList = json['endTime'] as List<dynamic>;
    DateTime startTime = DateTime(0, 0, 0, startTimeList[0], startTimeList[1]);
    DateTime endTime = DateTime(0, 0, 0, endTimeList[0], endTimeList[1]);

    return WalkPreference(
      dayOfWeek: json['dayOfWeek'],
      startTime: startTime,
      endTime: endTime,
    );
  }
}

class Time {
  final int hour;
  final int minute;
  //final int second;
  //final int nano;

  Time({
    required this.hour,
    required this.minute,
    //required this.second,
    //required this.nano,
  });

  factory Time.fromJson(Map<String, dynamic> json) {
    return Time(
      hour: json['hour'],
      minute: json['minute'],
      //second: json['second'],
      //nano: json['nano'],
    );
  }
}

class myInfo{
  final bool isSuccess;
  final String code;
  final String message;
  final int targetTime;
  final int walkSpeed;

  myInfo({
    required this.isSuccess,
    required this.code,
    required this.message,
    required this.targetTime,
    required this.walkSpeed,
  });

  factory myInfo.fromJson(Map<String, dynamic> json) {
    return myInfo(
      isSuccess: json['isSuccess'],
      code: json['code'],
      message: json['message'],
      targetTime: json['result']['targetTime'],
      walkSpeed: json['result']['walkSpeed'].toInt(),
    );
  }
}
