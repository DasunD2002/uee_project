import 'package:flutter/material.dart';

enum AppLanguage {
  english(
    code: 'en',
    locale: Locale('en'),
    englishName: 'English',
    nativeName: 'English',
    displayName: 'English',
  ),
  sinhala(
    code: 'si',
    locale: Locale('si'),
    englishName: 'Sinhala',
    nativeName: 'සිංහල',
    displayName: 'සිංහල (Sinhala)',
  ),
  tamil(
    code: 'ta',
    locale: Locale('ta'),
    englishName: 'Tamil',
    nativeName: 'தமிழ்',
    displayName: 'தமிழ் (Tamil)',
  );

  const AppLanguage({
    required this.code,
    required this.locale,
    required this.englishName,
    required this.nativeName,
    required this.displayName,
  });

  final String code;
  final Locale locale;
  final String englishName;
  final String nativeName;
  final String displayName;

  static AppLanguage fromCode(String? code) {
    if (code == null) return AppLanguage.english;
    return AppLanguage.values.firstWhere(
      (lang) => lang.code.toLowerCase() == code.toLowerCase(),
      orElse: () => AppLanguage.english,
    );
  }
}
