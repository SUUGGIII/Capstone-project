import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// 1. 사용자 정보 구조체 (Model)
class UserProfile {
  int userId;
  String username;
  String nickname;
  String email;
  int? age;
  String? sex;
  String? occupation;

  UserProfile({
    required this.userId,
    required this.username,
    required this.nickname,
    required this.email,
    this.age,
    this.sex,
    this.occupation,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['id'] ?? 0,
      username: json['username'] ?? '',
      nickname: json['nickname'] ?? '',
      email: json['email'] ?? '',
      age: json['age'],
      sex: json['sex'],
      occupation: json['occupation'],
    );
  }
}

// 2. 전역에서 접근 가능한 저장소 (Singleton Pattern)
class UserStore {
  // 싱글톤 패턴 구현
  static final UserStore _instance = UserStore._internal();
  factory UserStore() => _instance;
  UserStore._internal();

  // 실제 사용자 정보를 담을 변수
  UserProfile? _user;

  // getter
  UserProfile? get user => _user;

  // 로그인 직후 호출할 함수 (서버에서 정보 가져오기)
  Future<void> fetchUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null) return;

    try {
      final url = Uri.parse('http://localhost:8080/user');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _user = UserProfile.fromJson(data); // 데이터 저장
        print("사용자 정보 저장 완료: ${_user?.nickname}");
      } else {
        throw Exception('정보 로드 실패');
      }
    } catch (e) {
      print("사용자 정보 가져오기 오류: $e");
      rethrow;
    }
  }

  // 로그아웃 시 데이터 초기화
  void clear() {
    _user = null;
  }

  // 프로필 수정 시 로컬 데이터도 업데이트
  void updateUser({
    required String nickname,
    required String email,
    int? age,
    String? sex,
    String? occupation,
  }) {
    if (_user != null) {
      _user!.nickname = nickname;
      _user!.email = email;
      _user!.age = age;
      _user!.sex = sex;
      _user!.occupation = occupation;
    }
  }
}