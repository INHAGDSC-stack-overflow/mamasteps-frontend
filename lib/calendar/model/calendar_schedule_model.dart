// addRequest Post 요청시 사용되는 모델
class addRecordRequest {
  final int id;
  final int routeId;
  final DateTime date;
  final int completedTimeSeconds;
  final String createdAt;
  final String updatedAt;

  addRecordRequest({
    required this.id,
    required this.routeId,
    required this.date,
    required this.completedTimeSeconds,
    required this.createdAt,
    required this.updatedAt,
  });

  factory addRecordRequest.fromJson(Map<String, dynamic> json) {
    return addRecordRequest(
      id: json['id'],
      routeId: json['routeId'],
      date: DateTime.parse(json['date']),
      completedTimeSeconds: json['completedTimeSeconds'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'routeId': routeId,
      'date': date.toIso8601String(),
      'completedTimeSeconds': completedTimeSeconds,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

//getRecordResponse Get 요청 응답 모델
class getRecordResponse {
  final bool isSuccess;
  final String code;
  final String message;
  final List<getRecordResult> result;

  getRecordResponse({
    required this.isSuccess,
    required this.code,
    required this.message,
    required this.result,
  });

  factory getRecordResponse.fromJson(Map<String, dynamic> json) {
    var resultList = json['result'] as List;
    List<getRecordResult> resultsList = resultList.map((i) => getRecordResult.fromJson(i)).toList();

    return getRecordResponse(
      isSuccess: json['isSuccess'],
      code: json['code'],
      message: json['message'],
      result: resultsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isSuccess': isSuccess,
      'code': code,
      'message': message,
      'result': result.map((v) => v.toJson()).toList(),
    };
  }
}

class getRecordResult {
  final int id;
  final int routeId;
  final DateTime date;
  final int completedTimeSeconds;
  final String createdAt;
  final String updatedAt;

  getRecordResult({
    required this.id,
    required this.routeId,
    required this.date,
    required this.completedTimeSeconds,
    required this.createdAt,
    required this.updatedAt,
  });

  factory getRecordResult.fromJson(Map<String, dynamic> json) {
    var dateList = json['date'] as List;
    DateTime date = DateTime(
      dateList[0],
      dateList[1],
      dateList[2],
      dateList[3],
      dateList[4],
      dateList[5],
      dateList[6] ~/ 1000000,
    );
    return getRecordResult(
      id: json['id'],
      routeId: json['routeId'],
      date: date,
      completedTimeSeconds: json['completedTimeSeconds'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'routeId': routeId,
      'date': date.toIso8601String(),
      'completedTimeSeconds': completedTimeSeconds,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

//getSchedule Get 요청 응답 모델
class getScheduleResponse {
  final bool isSuccess;
  final String code;
  final String message;
  final List<getScheduleResult> result;

  getScheduleResponse({
    required this.isSuccess,
    required this.code,
    required this.message,
    required this.result,
  });

  factory getScheduleResponse.fromJson(Map<String, dynamic> json) {
    var resultList = json['result'] as List;
    List<getScheduleResult> resultsList = resultList.map((i) => getScheduleResult.fromJson(i)).toList();

    return getScheduleResponse(
      isSuccess: json['isSuccess'],
      code: json['code'],
      message: json['message'],
      result: resultsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isSuccess': isSuccess,
      'code': code,
      'message': message,
      'result': result.map((v) => v.toJson()).toList(),
    };
  }
}

class getScheduleResult {
  final int id;
  final int? routeId;
  final DateTime date;
  final int targetTimeSeconds;
  final String createdAt;
  final String updatedAt;

  getScheduleResult({
    required this.id,
    this.routeId,
    required this.date,
    required this.targetTimeSeconds,
    required this.createdAt,
    required this.updatedAt,
  });

  factory getScheduleResult.fromJson(Map<String, dynamic> json) {
    var dateList = json['date'] as List;
    DateTime date = DateTime(
      dateList[0],
      dateList[1],
      dateList[2],
      dateList[3],
      dateList[4],
    );
    return getScheduleResult(
      id: json['id'],
      routeId: json['routeId'],
      date: date,
      targetTimeSeconds: json['targetTimeSeconds'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'routeId': routeId,
      'date': date.toIso8601String(),
      'targetTimeSeconds': targetTimeSeconds,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

// // 캘린더 스케쥴 모델
// class EventMap {
//   Map<DateTime, List<Event>> events;
//
//   EventMap(this.events);
// }
// class Event {
//   String title;
//
//   Event(this.title);
// }
