import 'package:flutter/material.dart';

class AppTheme {
  static const primaryColorLight = Colors.blue;
  static const foregroundColorLight = Colors.black54;
  static const backgroundColorLight = Colors.white;
  static const titleColorLight = Colors.white;
  static var barForegroundColorLight = Colors.white;
  static const primaryColorDark = Colors.blueGrey; // 5cafdb
  static const foregroundColorDark = Colors.white;
  static final backgroundColorDark = Colors.grey[850]!;
  static const titleColorDark = Colors.white;
  static var barForegroundColorDark = Colors.white;

  static ThemeData _buildTheme({
    required MaterialColor primarySwatch,
    required Color foregroundColor,
    required Color backgroundColor,
    required Color titleColor,
    required Color barForegroundColor,
  }) {
    return ThemeData(
      primarySwatch: primarySwatch,
      appBarTheme: AppBarTheme(
        backgroundColor: primarySwatch,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: titleColor,
          fontSize: 20,
        ),
        iconTheme: IconThemeData(
          color: barForegroundColor,
        ),
        actionsIconTheme: IconThemeData(
          color: barForegroundColor,
        ),
        toolbarTextStyle: TextStyle(
          color: barForegroundColor,
        ),
      ),
      scaffoldBackgroundColor: backgroundColor,
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primarySwatch,
        foregroundColor: barForegroundColor,
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: backgroundColor,
      ),
      listTileTheme: ListTileThemeData(
        textColor: foregroundColor,
        iconColor: foregroundColor,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: backgroundColor,
      ),
      inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: foregroundColor),
          iconColor: foregroundColor),
      bottomSheetTheme: BottomSheetThemeData(backgroundColor: backgroundColor),
      chipTheme: ChipThemeData(
        backgroundColor: backgroundColor,
        labelStyle: TextStyle(color: foregroundColor),
      ),
      iconTheme: IconThemeData(
        color: foregroundColor,
      ),
      switchTheme: const SwitchThemeData(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
      dropdownMenuTheme: DropdownMenuThemeData(menuStyle: MenuStyle()),
      textTheme: TextTheme(
        titleLarge: TextStyle(color: foregroundColor), // 设置 drawer 标题颜色
        titleMedium: TextStyle(color: foregroundColor),
        titleSmall: TextStyle(color: foregroundColor),
        bodyLarge: TextStyle(color: foregroundColor),
        bodyMedium: TextStyle(color: foregroundColor),
        bodySmall: TextStyle(color: foregroundColor),
        headlineLarge: TextStyle(color: titleColor),
        headlineMedium: TextStyle(color: titleColor),
        headlineSmall: TextStyle(color: titleColor),
        // 设置 drawer 项目文字颜色
      ),
    );
  }

  static ThemeData get defaultTheme => _buildTheme(
        primarySwatch: primaryColorLight,
        foregroundColor: foregroundColorLight,
        backgroundColor: backgroundColorLight,
        titleColor: titleColorLight,
        barForegroundColor: barForegroundColorLight,
      );

  static ThemeData get darkTheme => _buildTheme(
        primarySwatch: primaryColorDark,
        foregroundColor: foregroundColorDark,
        backgroundColor: backgroundColorDark,
        titleColor: titleColorDark,
        barForegroundColor: barForegroundColorDark,
      );
}
