import 'package:flutter/material.dart';
import '../colors.dart';

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.light(
    primary: AppColors.primaryColor,
    secondary: AppColors.secondaryColor,
    background: AppColors.backgroundColor,
    surface: AppColors.lightBackgroundColor,
    onPrimary: AppColors.lightTextColor,
    onSecondary: AppColors.lightTextColor,
    onBackground: AppColors.darkTextColor,
    onSurface: AppColors.darkTextColor,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: AppColors.darkTextColor),
    bodyMedium: TextStyle(color: AppColors.darkTextColor),
    bodySmall: TextStyle(color: AppColors.darkTextColor),
    titleLarge: TextStyle(color: AppColors.darkTextColor),
    titleMedium: TextStyle(color: AppColors.darkTextColor),
    titleSmall: TextStyle(color: AppColors.darkTextColor),
  ),
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.dark(
    primary: AppColors.primaryColor,
    secondary: AppColors.secondaryColor,
    background: AppColors.darkTextColor,
    surface: AppColors.darkTextColor,
    onPrimary: AppColors.lightTextColor,
    onSecondary: AppColors.lightTextColor,
    onBackground: AppColors.lightTextColor,
    onSurface: AppColors.lightTextColor,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: AppColors.lightTextColor),
    bodyMedium: TextStyle(color: AppColors.lightTextColor),
    bodySmall: TextStyle(color: AppColors.lightTextColor),
    titleLarge: TextStyle(color: AppColors.lightTextColor),
    titleMedium: TextStyle(color: AppColors.lightTextColor),
    titleSmall: TextStyle(color: AppColors.lightTextColor),
  ),
);