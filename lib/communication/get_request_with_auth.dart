import 'dart:convert';
import 'package:http/http.dart' as http;

class GetRequestWithAuth {
  final String apiUrl;
  final String token;

  GetRequestWithAuth({required this.apiUrl, required this.token});

  Future<void> send() async {
    try {
      final http.Response response = await http.get(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      // 응답 확인
      if (response.statusCode == 200) {
        // 성공적으로 요청을 보냈을 때의 처리
        // UTF-8로 디코딩하여 응답 내용을 출력
        print('GET request successful! Response: ${utf8.decode(response.bodyBytes)}');
      } else {
        // 요청이 실패한 경우의 처리
        print('Failed to send GET request. Status code: ${response.statusCode}\nResponse: ${utf8.decode(response.bodyBytes)}');
      }
    } catch (error) {
      // 예외 처리
      print('Error sending GET request: $error');
    }
  }
}