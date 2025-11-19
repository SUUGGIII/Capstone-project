// 기능: ChangeNotifier를 상속받아 앱의 내비게이션 상태를 관리하는 Provider 클래스를 구현함. 특히 HomePage의 상단 탭에서 현재 선택된 인덱스를 저장하고 변경하는 기능을 제공함.
// 호출: notifyListeners() 메소드를 호출하여 _selectedIndex의 변경 사항을 구독하는 위젯들에게 알림.
// 호출됨: main.dart 파일에서 ChangeNotifierProvider를 통해 앱 전체에 제공되며, home_page.dart에서 현재 페이지를 결정하고, meeting_page.dart 등에서 페이지 전환을 위해 setSelectedIndex 메소드가 호출됨.
import 'package:flutter/material.dart';

class NavigationProvider with ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void setSelectedIndex(int index) {
    if (_selectedIndex != index) {
      _selectedIndex = index;
      notifyListeners();
    }
  }
}
