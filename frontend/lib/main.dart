// 기능: Flutter 애플리케이션의 시작점(Entry Point) 역할을 함. 앱의 최상위 위젯인 MyApp을 실행하고, NavigationProvider를 통해 전역 상태 관리를 설정하며, 앱의 기본 테마와 초기 화면(LoginPage)을 정의함.
// 호출: NavigationProvider를 생성하고, LoginPage를 앱의 첫 화면으로 호출함. LiveKitTheme의 buildThemeData 메소드를 호출하여 앱의 테마를 설정함.
// 호출됨: Flutter 프레임워크에 의해 앱 실행 시 가장 먼저 호출됨.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meeting_app/providers/navigation_provider.dart';
import 'package:meeting_app/pages/login_page.dart';
import 'package:meeting_app/theme/theme.dart';


import 'package:meeting_app/utils/navigator.dart';


void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => NavigationProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Meeting App',
      theme: LiveKitTheme().buildThemeData(context),
      home: const LoginPage(),
    );
  }
}