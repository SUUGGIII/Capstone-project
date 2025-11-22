import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'http://localhost:8080';

  static Future<bool> startVote({
    required String roomName,
    required String topic,
    required List<String> options,
    required String proposerId, // Add proposerId parameter
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/votes/start'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'roomName': roomName,
          'topic': topic,
          'options': options,
          'proposerId': proposerId, // Include in JSON body
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to start vote: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error starting vote: $e');
      return false;
    }
  }

  static Future<bool> castVote({
    required int voteId,
    required String voterId,
    required String selectedOption,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/votes/cast'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'voteId': voteId,
          'voterId': voterId,
          'selectedOption': selectedOption,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to cast vote: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error casting vote: $e');
      return false;
    }
  }

  static Future<bool> closeVote({required int voteId}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/votes/$voteId/close'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to close vote: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error closing vote: $e');
      return false;
    }
  }
}
