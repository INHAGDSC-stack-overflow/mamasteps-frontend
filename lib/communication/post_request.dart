import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PostRequest extends StatelessWidget {
  const PostRequest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HTTP Controller'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                // POST 요청 보내기
                sendPostRequest().then((message) {
                  // 응답 메시지 갱신
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Response Message'),
                        content: Text(message),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                });
              },
              child: const Text('Send POST Request'),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> sendPostRequest() async {
    const String apiUrl = 'http://172.20.10.2:8080/api/v1/auth/login'; // 스프링 서버의 API 주소로 변경

    // 요청 데이터 생성
    Map<String, dynamic> requestData = {
      "email": "test2@naver.com",
      "password": "password"
    };

    // JSON 형식으로 인코딩
    String requestBody = json.encode(requestData);

    try {
      final http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: requestBody,
      );

      // 응답 확인
      if (response.statusCode == 200) {
        // 성공적으로 요청을 보냈을 때의 처리
        // UTF-8로 디코딩하여 응답 내용을 반환
        return 'POST request successful! Response: ${utf8.decode(response.bodyBytes)}';
      } else {
        // 요청이 실패한 경우의 처리
        return 'Failed to send POST request. Status code: ${response.statusCode}\nResponse: ${utf8.decode(response.bodyBytes)}';
      }
    } catch (error) {
      // 예외 처리
      return 'Error sending POST request: $error';
    }
  }
}
