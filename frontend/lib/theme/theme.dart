// 기능: 앱의 전반적인 시각적 스타일을 정의함. 색상, 글꼴, 위젯 테마 등을 설정함. LiveKitTheme 클래스를 통해 ThemeData 객체를 빌드하여 앱 전체에 일관된 디자인을 적용하는 데 사용됨.
// 호출: google_fonts 패키지를 사용하여 글꼴을 가져오고, flutter/material.dart의 다양한 위젯 및 테마 관련 클래스를 사용함. 직접적으로 다른 커스텀 위젯이나 페이지를 호출하지는 않음.
// 호출됨: main.dart 파일에서 MaterialApp의 theme 속성에 LiveKitTheme().buildThemeData(context) 형태로 호출되어 앱의 전역 테마를 설정함.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//
// Flutter has a color profile issue so colors will look different
// on Apple devices.
// https://github.com/flutter/flutter/issues/55092
// https://github.com/flutter/flutter/issues/39113
//

extension LKColors on Colors {
  static const lkBlue = Color(0xFF5A8BFF);
  static const lkDarkBlue = Color(0xFF00153C);
}

class LiveKitTheme {
  //
  final bgColor = Colors.white;
  final textColor = Colors.black;
  final cardColor = LKColors.lkDarkBlue;
  final accentColor = Colors.blue[600];

  ThemeData buildThemeData(BuildContext ctx) => ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
        ),
        cardColor: cardColor,
        scaffoldBackgroundColor: bgColor,
        canvasColor: bgColor,
        iconTheme: IconThemeData(
          color: textColor,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            textStyle:
                WidgetStateProperty.all<TextStyle>(GoogleFonts.montserrat(
              fontSize: 15,
            )),
            padding: WidgetStateProperty.all<EdgeInsets>(
                const EdgeInsets.symmetric(vertical: 20, horizontal: 25)),
            shape: WidgetStateProperty.all<OutlinedBorder>(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
            // backgroundColor: WidgetStateProperty.all<Color>(accentColor),
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return accentColor?.withAlpha(128) ?? Colors.transparent;
              }
              return accentColor;
            }),
          ),
        ),
        checkboxTheme: CheckboxThemeData(
          checkColor: WidgetStateProperty.all(Colors.white),
          fillColor: WidgetStateProperty.all(accentColor),
        ),
        switchTheme: SwitchThemeData(
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return accentColor;
            }
            return accentColor?.withAlpha(77) ?? Colors.transparent;
          }),
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            return Colors.white.withValues(alpha: 0.3);
          }),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        textTheme: GoogleFonts.montserratTextTheme(
          Theme.of(ctx).textTheme,
        ).apply(
          displayColor: textColor,
          bodyColor: textColor,
          decorationColor: textColor,
        ),
        hintColor: Colors.red,
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: const TextStyle(
            color: LKColors.lkBlue,
          ),
          hintStyle: TextStyle(
            color: LKColors.lkBlue.withValues(alpha: 5),
          ),
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
          surface: bgColor,
        ),
      );
}
