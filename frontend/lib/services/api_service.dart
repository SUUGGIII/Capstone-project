import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:meeting_app/pages/login_page.dart';

class ApiService {
  static const String _baseUrl = 'http://127.0.0.1:8080';

  static Future<http.Response> post(String path, {Map<String, String>? headers, Object? body, BuildContext? context}) async {
    return _requestWithAuth('POST', path, headers: headers, body: body, context: context);
  }

  static Future<http.Response> _requestWithAuth(String method, String path, {Map<String, String>? headers, Object? body, BuildContext? context}) async {
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    headers ??= {};
    headers['Content-Type'] = 'application/json';
    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    final url = Uri.parse('$_baseUrl$path');
    http.Response response;

    if (method == 'POST') {
      response = await http.post(url, headers: headers, body: jsonEncode(body));
    } else {
      // Add other methods like GET if needed
      throw UnimplementedError('HTTP method $method not implemented');
    }

    if (response.statusCode == 401) {
      print('[ApiService] Received 401. Attempting to refresh token.');
      final newTokens = await _refreshToken(context);

      if (newTokens != null) {
        print('[ApiService] Token refreshed successfully. Retrying original request.');
        
        // Create new headers for the retry
        final newHeaders = Map<String, String>.from(headers);
        newHeaders['Authorization'] = 'Bearer ${newTokens['accessToken']}';
        
        print('[ApiService] Retrying with new token: ${newHeaders['Authorization']}');

        if (method == 'POST') {
          response = await http.post(url, headers: newHeaders, body: jsonEncode(body));
        }
        
        print('[ApiService] Retry request status code: ${response.statusCode}');
        return response;
      } else {
        print('[ApiService] Failed to refresh token. User will be logged out.');
        // Navigation is now handled inside _refreshToken
        throw Exception('Failed to refresh token');
      }
    }

    return response;
  }

  static Future<Map<String, String>?> _refreshToken(BuildContext? context) async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refreshToken');

    print('[ApiService] Refreshing token with: $refreshToken');

    if (refreshToken == null) {
      print('[ApiService] No refresh token found.');
      return null;
    }

    final url = Uri.parse('$_baseUrl/jwt/refresh');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      print('[ApiService] Refresh endpoint response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccessToken = data['accessToken'];
        final newRefreshToken = data['refreshToken'];

        if (newAccessToken != null && newRefreshToken != null) {
          await prefs.setString('accessToken', newAccessToken);
          await prefs.setString('refreshToken', newRefreshToken);
          print('[ApiService] New tokens saved to SharedPreferences.');
          return {'accessToken': newAccessToken, 'refreshToken': newRefreshToken};
        }
      }
    } catch (e) {
      print('[ApiService] Error during token refresh: $e');
    }

    // If refresh fails for any reason, clear tokens and navigate to login
    print('[ApiService] Clearing tokens and navigating to login page.');
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');

    if (context != null && context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
    
    return null;
  }
}
