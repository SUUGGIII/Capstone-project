import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'http://localhost:8080';

  static Future<bool> submitVote({
    required String roomName,
    required String topic,
    required String voterId,
    required String selectedOption,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/votes'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'roomName': roomName,
          'topic': topic,
          'voterId': voterId,
          'selectedOption': selectedOption,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to submit vote: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error submitting vote: $e');
      return false;
    }
  }
}
