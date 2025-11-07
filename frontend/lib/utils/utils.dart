// 기능: 데스크톱 환경에서 애플리케이션의 창이 닫히기 전에 실행되어야 할 비동기 콜백 함수를 저장하는 전역 변수 onWindowShouldClose를 정의함.
// 호출: 직접적으로 다른 코드를 호출하지 않음. FutureOr<void> Function() 타입으로, 할당된 함수가 호출될 때 다른 코드를 실행할 수 있음.
// 호출됨: room.dart 파일에서 onWindowShouldClose 변수에 룸 연결 해제 로직을 할당함. 실제 이 변수에 할당된 함수는 각 데스크톱 플랫폼의 러너(runner) 코드(예: main.cc 또는 flutter_window.cpp 등)에서 창 닫기 이벤트 발생 시 호출될 것으로 추정됨.
import 'dart:async';

FutureOr<void> Function()? onWindowShouldClose;
