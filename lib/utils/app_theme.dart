import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const darkBg1 = Color(0xFF0F172A);
  static const darkBg2 = Color(0xFF1E293B);
  static const darkBg3 = Color(0xFF020617);
  static const primaryBlue = Color(0xFF0081C9);
  static const lightBlue = Color(0xFF0EA5E9);
  static const navyBlue = Color(0xFF001742);
  static const darkNavy = Color(0xFF001F3F);
  static const gradientEnd = Color(0xFF1859A4);
  static const cardBg = Color(0xFFF8F9FA);
  static const lightGrey = Color(0xFFF5F5F5);
}

class AppGradients {
  AppGradients._();

  static const darkBackground = LinearGradient(
    colors: [AppColors.darkBg1, AppColors.darkBg2],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const darkBackgroundTopCenter = LinearGradient(
    colors: [AppColors.darkBg1, AppColors.darkBg2],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const primaryBlue = LinearGradient(
    colors: [AppColors.primaryBlue, Colors.blue],
  );

  static const primaryBlueVertical = LinearGradient(
    colors: [Color(0xFF007DFE), Color(0xFF1B4995)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const blueNavy = LinearGradient(
    colors: [AppColors.lightBlue, AppColors.gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const homeCard = LinearGradient(
    colors: [Color(0xFF1198DD), Color(0xFF1859A4)],
  );
}

class AppTextStyles {
  AppTextStyles._();

  static const screenTitle = TextStyle(
    color: Colors.white,
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );

  static const screenSubtitle = TextStyle(
    color: Colors.white54,
    fontSize: 14,
  );

  static const stepText = TextStyle(
    color: Colors.white54,
    fontSize: 12,
  );

  static const hintText = TextStyle(color: Colors.white54);

  static const buttonText = TextStyle(
    fontSize: 16,
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );
}

class AppBorderRadius {
  AppBorderRadius._();

  static final rounded30 = BorderRadius.circular(30);
  static final rounded20 = BorderRadius.circular(20);
  static final rounded15 = BorderRadius.circular(15);
  static final rounded12 = BorderRadius.circular(12);
  static final rounded10 = BorderRadius.circular(10);
}
