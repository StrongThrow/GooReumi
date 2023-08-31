import 'package:shared_preferences/shared_preferences.dart';

class LoginStreakManager {
  static const String LAST_LOGIN_DATE_KEY = "last_login_date";
  static const String CONSECUTIVE_DAYS_KEY = "consecutive_days";
  static const String WAS_RESET_KEY = "was_reset";

  // 로그인 연속 횟수를 업데이트하는 함수
  static Future<void> updateLoginStreak() async {
    final prefs = await SharedPreferences.getInstance();

    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime? lastLoginDate;

    // 마지막 로그인 날짜가 저장되어 있다면 불러옴
    if (prefs.containsKey(LAST_LOGIN_DATE_KEY)) {
      lastLoginDate = DateTime.parse(prefs.getString(LAST_LOGIN_DATE_KEY)!);
    }

    int consecutiveDays = prefs.getInt(CONSECUTIVE_DAYS_KEY) ?? 0;

    if (lastLoginDate == null) {
      // 첫 로그인
      consecutiveDays = 1;
      prefs.setBool(WAS_RESET_KEY, false);  // <-- 첫 로그인이므로 리셋 안 됨
    } else if (lastLoginDate.add(Duration(days: 1)).isBefore(today)) {
      // 하루 이상 지난 경우
      consecutiveDays = 1;
      prefs.setBool(WAS_RESET_KEY, true);   // <-- 연속 로그인 리셋됨
    } else if (lastLoginDate.isBefore(today)) {
      // 마지막 로그인은 어제
      consecutiveDays++;
      prefs.setBool(WAS_RESET_KEY, false);  // <-- 연속 로그인 지속
    }
    // 그 외: 이미 오늘 로그인 했으므로 아무것도 하지 않음

    int level;
    if (consecutiveDays >= 4) {
      level = 4;
    } else {
      level = consecutiveDays;
    }
    prefs.setInt("level", level);

    prefs.setString(LAST_LOGIN_DATE_KEY, today.toIso8601String());
    prefs.setInt(CONSECUTIVE_DAYS_KEY, consecutiveDays);
  }

  // 현재 레벨을 가져오는 함수
  static Future<int> getCurrentLevel() async {
    int consecutiveDays = await getConsecutiveDays();

    if (consecutiveDays >= 4) {
      return 4;
    } else {
      return consecutiveDays;
    }
  }

  // 연속 로그인 일수를 가져오는 함수
  static Future<int> getConsecutiveDays() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(CONSECUTIVE_DAYS_KEY) ?? 0;
  }

  // 레벨을 가져오는 함수
  static Future<int> getLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("level") ?? 1;
  }

  // 레벨이 리셋되었는지 확인하는 함수
  static Future<bool> wasLevelReset() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(WAS_RESET_KEY) ?? false;
  }
}