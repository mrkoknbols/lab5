import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const String _studentNameKey = 'student_name';
  static const String _agreementKey = 'agreement_saved';
  // Убрали _darkModeKey так как он не используется

  // Сохранить ФИО студента
  static Future<void> saveStudentName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_studentNameKey, name);
  }

  // Получить ФИО студента
  static Future<String?> getStudentName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_studentNameKey);
  }

  // Сохранить согласие на обработку
  static Future<void> saveAgreement(bool agreed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_agreementKey, agreed);
  }

  // Получить сохраненное согласие
  static Future<bool> getAgreement() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_agreementKey) ?? false;
  }

  // Очистить все настройки
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}