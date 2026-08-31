/// Ethiopian calendar conversion and date utilities.
library;

class EthiopianDate {
  final int year;
  final int month;
  final int day;

  const EthiopianDate({
    required this.year,
    required this.month,
    required this.day,
  });

  int toJdn() => CalendarEngine.ethiopianToJdn(year, month, day);

  int differenceInDays(EthiopianDate other) => toJdn() - other.toJdn();

  @override
  bool operator ==(Object other) =>
      other is EthiopianDate &&
      year == other.year &&
      month == other.month &&
      day == other.day;

  @override
  int get hashCode => Object.hash(year, month, day);
}

class CalendarEngine {
  CalendarEngine._();

  static const _epochJdn = 1724221;

  static const monthNamesAmharic = [
    'መስከረም',
    'ጥቅምት',
    'ኅዳር',
    'ታኅሣሥ',
    'ጥር',
    'የካቲት',
    'መጋቢት',
    'ሚያዝያ',
    'ግንቦት',
    'ሰኔ',
    'ሐምሌ',
    'ነሐሴ',
    'ጳጉሜ',
  ];

  static const monthNamesEnglish = [
    'Meskerem',
    'Tikimt',
    'Hidar',
    'Tahsas',
    'Tir',
    'Yekatit',
    'Megabit',
    'Miyazya',
    'Ginbot',
    'Sene',
    'Hamle',
    'Nehasse',
    'Pagume',
  ];

  static const weekdayNamesAmharic = [
    'እሁድ',
    'ሰኞ',
    'ማክሰኞ',
    'ረቡዕ',
    'ሐሙስ',
    'ዓርብ',
    'ቅዳሜ',
  ];

  static const weekdayNamesEnglish = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  static const _evangelistsAmharic = ['ማቴዎስ', 'ማርቆስ', 'ሉቃስ', 'ዮሐንስ'];
  static const _evangelistsEnglish = ['Matthew', 'Mark', 'Luke', 'John'];

  static EthiopianDate today() => fromGregorian(DateTime.now());

  static EthiopianDate fromGregorian(DateTime date) {
    final jdn = _gregorianToJdn(date.year, date.month, date.day);
    return jdnToEthiopian(jdn);
  }

  static DateTime toGregorian(EthiopianDate date) {
    final jdn = date.toJdn();
    return _jdnToGregorian(jdn);
  }

  static int ethiopianToJdn(int year, int month, int day) {
    return (year - 1) * 365 +
        (year ~/ 4) +
        30 * (month - 1) +
        day -
        1 +
        _epochJdn;
  }

  static EthiopianDate jdnToEthiopian(int jdn) {
    final days = jdn - _epochJdn;
    final year = (4 * days + 2) ~/ 1461 + 1;
    final dayOfYear = days - (365 * (year - 1) + year ~/ 4);
    final month = dayOfYear ~/ 30 + 1;
    final day = dayOfYear % 30 + 1;
    return EthiopianDate(year: year, month: month, day: day);
  }

  static bool isEthiopianLeapYear(int year) => year % 4 == 3;

  static int daysInEthiopianMonth(int year, int month) {
    if (month == 13) return isEthiopianLeapYear(year) ? 6 : 5;
    return 30;
  }

  /// 0 = Sunday, 6 = Saturday (matches Bahire Hasab weekday math).
  static int ethiopianWeekday(EthiopianDate date) => (date.toJdn() + 1) % 7;

  /// Returns the number as standard Arabic digits (1, 2, 3…).
  /// Ethiopic/Geez numerals are intentionally not used — Arabic digits
  /// are universally readable and render correctly with any font.
  static String toGeezNumeral(int number) => number.toString();

  static String evangelistForYear(int year, {bool amharic = true}) {
    final index = (year - 1) % 4;
    return amharic ? _evangelistsAmharic[index] : _evangelistsEnglish[index];
  }

  static String currentSeason(EthiopianDate date, {bool amharic = true}) {
    final seasonsAm = ['በጋ', 'ክረምት', 'መኸር', 'በልግ'];
    final seasonsEn = ['Summer', 'Rainy Season', 'Autumn', 'Winter'];
    final index = switch (date.month) {
      >= 1 && <= 3 => 2, // Meskerem - Hidar -> መኸር / Autumn
      >= 4 && <= 6 => 0, // Tahsas - Yekatit -> በጋ / Winter
      >= 7 && <= 9 => 3, // Megabit - Ginbot -> በልግ / Spring
      _ => 1, // Sene - Pagume (10, 11, 12, 13) -> ክረምት / Rainy Season
    };
    return amharic ? seasonsAm[index] : seasonsEn[index];
  }

  static double moonPhase(DateTime date) {
    final jdn = _gregorianToJdn(date.year, date.month, date.day);
    final days = jdn - 2451550.1;
    final phase = (days % 29.530588853) / 29.530588853;
    return phase < 0 ? phase + 1 : phase;
  }

  static String moonPhaseName(double phase, {bool amharic = true}) {
    final namesAm = [
      'አዲስ ጨረቃ',
      'እድገት',
      'ቅዳሜ ጨረቃ',
      'ሙሉ ጨረቃ',
      'መቀነስ',
      'ቅዳሜ ጨረቃ',
      'አዲስ ጨረቃ',
    ];
    final namesEn = [
      'New Moon',
      'Waxing Crescent',
      'First Quarter',
      'Full Moon',
      'Waning Gibbous',
      'Last Quarter',
      'New Moon',
    ];
    final index = ((phase * 8).round()) % 8;
    final safeIndex = index.clamp(0, namesEn.length - 1);
    return amharic ? namesAm[safeIndex] : namesEn[safeIndex];
  }

  static String toEthiopianTime(DateTime now, {bool amharic = true}) {
    final hour = now.hour;
    final minute = now.minute.toString().padLeft(2, '0');
    final isDay = hour >= 6 && hour < 18;
    final adjusted = (hour - 6 + 24) % 24;
    final ethHour = adjusted % 12 == 0 ? 12 : adjusted % 12;
    final period = isDay ? (amharic ? 'ቀን' : 'D') : (amharic ? 'ሌሊት' : 'Night');
    return '$ethHour:$minute $period';
  }

  static int _gregorianToJdn(int year, int month, int day) {
    final a = (14 - month) ~/ 12;
    final y = year + 4800 - a;
    final m = month + 12 * a - 3;
    return day +
        (153 * m + 2) ~/ 5 +
        365 * y +
        y ~/ 4 -
        y ~/ 100 +
        y ~/ 400 -
        32045;
  }

  static DateTime _jdnToGregorian(int jdn) {
    final a = jdn + 32044;
    final b = (4 * a + 3) ~/ 146097;
    final c = a - (146097 * b) ~/ 4;
    final d = (4 * c + 3) ~/ 1461;
    final e = c - (1461 * d) ~/ 4;
    final m = (5 * e + 2) ~/ 153;
    final day = e - (153 * m + 2) ~/ 5 + 1;
    final month = m + 3 - 12 * (m ~/ 10);
    final year = 100 * b + d - 4800 + m ~/ 10;
    return DateTime(year, month, day);
  }
}
