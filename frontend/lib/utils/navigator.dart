import 'package:flutter/material.dart';

// 앱 전역에서 네비게이션 상태에 접근하기 위한 글로벌 키
// 이 키를 사용하면 위젯 트리 상의 context 정보 없이도 다이얼로그를 띄우거나 페이지를 이동할 수 있습니다.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
