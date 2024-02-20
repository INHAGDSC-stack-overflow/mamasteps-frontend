class getMeResponse {
  final bool isSuccess;
  final String code;
  final String message;
  final UserProfile result;

  getMeResponse({
    required this.isSuccess,
    required this.code,
    required this.message,
    required this.result,
  });

  factory getMeResponse.fromJson(Map<String, dynamic> json) {
    return getMeResponse(
      isSuccess: json['isSuccess'],
      code: json['code'],
      message: json['message'],
      result: UserProfile.fromJson(json['result']),
    );
  }
}

class UserProfile {
  final String profileImageUrl;
  final String email;
  final String name;
  final int age;
  final DateTime pregnancyStartDate;
  final String guardianPhoneNumber;
  final String activityLevel;
  // final List<WalkPreference> walkPreferences;

  UserProfile({
    required this.profileImageUrl,
    required this.email,
    required this.name,
    required this.age,
    required this.pregnancyStartDate,
    required this.guardianPhoneNumber,
    required this.activityLevel,
    // required this.walkPreferences,
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
    return UserProfile(
      profileImageUrl: json['profileImageUrl'],
      email: json['email'],
      name: json['name'],
      age: json['age'],
      pregnancyStartDate: date,
      guardianPhoneNumber: json['guardianPhoneNumber'],
      activityLevel: json['activityLevel'],
      // walkPreferences: (json['walkPreferences'] as List)
      //     .map((x) => WalkPreference.fromJson(x as Map<String, dynamic>))
      //     .toList(),
    );
  }
}

class WalkPreference {
  final String dayOfWeek;
  final Time startTime;
  final Time endTime;

  WalkPreference({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  factory WalkPreference.fromJson(Map<String, dynamic> json) {

    return WalkPreference(
      dayOfWeek: json['dayOfWeek'],
      startTime: Time.fromJson(json['startTime']),
      endTime: Time.fromJson(json['endTime']),
    );
  }
}

class Time {
  final int hour;
  final int minute;
  final int second;
  final int nano;

  Time({
    required this.hour,
    required this.minute,
    required this.second,
    required this.nano,
  });

  factory Time.fromJson(Map<String, dynamic> json) {
    return Time(
      hour: json['hour'],
      minute: json['minute'],
      second: json['second'],
      nano: json['nano'],
    );
  }
}