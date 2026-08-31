/// ─────────────────────────────────────────────────────────────────────────────
///  HOLIDAY ENGINE
///  Fixed Ethiopian Orthodox feasts, national holidays, and saints
///  All dates are in the Ethiopian calendar system
/// ─────────────────────────────────────────────────────────────────────────────
library;

import '../../calendar/domain/calendar_engine.dart';

enum HolidayCategory {
  nationalHoliday,
  orthodoxFeast,
  marianFeast,
  saintCommemoration,
  historicalEvent,
}

class Holiday {
  final String nameAmharic;
  final String nameEnglish;
  final int month;
  final int day;
  final HolidayCategory category;
  final String? descriptionAmharic;
  final String? descriptionEnglish;
  final int importanceLevel; // 1–5, 5 = highest
  final bool isPublicHoliday;

  const Holiday({
    required this.nameAmharic,
    required this.nameEnglish,
    required this.month,
    required this.day,
    required this.category,
    this.descriptionAmharic,
    this.descriptionEnglish,
    this.importanceLevel = 3,
    this.isPublicHoliday = false,
  });

  EthiopianDate toEthiopianDate(int year) =>
      EthiopianDate(year: year, month: month, day: day);
}

class HolidayEngine {
  HolidayEngine._();

  static const List<Holiday> fixedHolidays = [
    // ── National Holidays ──────────────────────────────────────────────────

    Holiday(
      nameAmharic: 'እንቁጣጣሽ (ዕዉር ዓዲ)',
      nameEnglish: 'Enkutatash (Ethiopian New Year)',
      month: 1, day: 1,
      category: HolidayCategory.nationalHoliday,
      descriptionAmharic: 'የኢትዮጵያ አዲስ ዓመት — ሜሴኬረም 1',
      descriptionEnglish: 'Ethiopian New Year — first day of Meskerem',
      importanceLevel: 5,
      isPublicHoliday: true,
    ),

    Holiday(
      nameAmharic: 'ማስቀሌ',
      nameEnglish: 'Meskel (Finding of the True Cross)',
      month: 1, day: 17,
      category: HolidayCategory.orthodoxFeast,
      descriptionAmharic: 'ቅዱስ መስቀሉ የተገኘበት ቀን',
      descriptionEnglish: 'Commemoration of the finding of the True Cross of Christ',
      importanceLevel: 5,
      isPublicHoliday: true,
    ),

    Holiday(
      nameAmharic: 'ጥምቀት',
      nameEnglish: 'Timket (Ethiopian Epiphany)',
      month: 5, day: 11,
      category: HolidayCategory.orthodoxFeast,
      descriptionAmharic: 'ጌታ ኢየሱስ ክርስቶስ ቅዱስ ዮሐንስ ሊያጠምቀው ወደ ዮርዳኖስ ወረደ',
      descriptionEnglish: 'Celebration of Christ\'s baptism in the Jordan River',
      importanceLevel: 5,
      isPublicHoliday: true,
    ),

    Holiday(
      nameAmharic: 'ገና (ልደት)',
      nameEnglish: 'Genna (Ethiopian Christmas)',
      month: 4, day: 29,
      category: HolidayCategory.orthodoxFeast,
      descriptionAmharic: 'ጌታ ኢየሱስ ክርስቶስ ከድንግል ማርያም ተወለደ',
      descriptionEnglish: 'Birth of Jesus Christ — Ethiopian Christmas',
      importanceLevel: 5,
      isPublicHoliday: true,
    ),

    Holiday(
      nameAmharic: 'የአድዋ ድል',
      nameEnglish: 'Adwa Victory Day',
      month: 6, day: 23,
      category: HolidayCategory.historicalEvent,
      descriptionAmharic: 'ኢትዮጵያ በ1888 ዓ.ም. ጣሊያንን ያሸነፈችበት ቀን',
      descriptionEnglish: 'Ethiopia\'s victory over Italy at the Battle of Adwa (1896)',
      importanceLevel: 5,
      isPublicHoliday: true,
    ),

    Holiday(
      nameAmharic: 'ደርግ ውድቀት (ነጻነት ቀን)',
      nameEnglish: 'Patriots\' Victory Day',
      month: 9, day: 2,
      category: HolidayCategory.historicalEvent,
      descriptionAmharic: 'ሚያዚያ 30 — ዴርግ ወደቀ',
      descriptionEnglish: 'End of the Derg regime — Liberation Day (May 28)',
      importanceLevel: 4,
      isPublicHoliday: true,
    ),

    // ── Major Orthodox Feasts ──────────────────────────────────────────────

    Holiday(
      nameAmharic: 'ቅዱስ ዮሐንስ (ቴዎድሮስ)',
      nameEnglish: 'Tekemt 12 — Michael',
      month: 2, day: 12,
      category: HolidayCategory.orthodoxFeast,
      descriptionAmharic: 'ቅዱስ ሚካኤል ሊቀ መላዕክት',
      importanceLevel: 4,
    ),

    Holiday(
      nameAmharic: 'ኪዳነ ምሕረት',
      nameEnglish: 'Kidane Mehret',
      month: 6, day: 16,
      category: HolidayCategory.marianFeast,
      descriptionAmharic: 'የድንግል ማርያም ኪዳነ ምሕረት ዓመታዊ ክብረ-በዓል',
      descriptionEnglish: 'Covenant of Mercy — feast of the Virgin Mary',
      importanceLevel: 4,
    ),

    Holiday(
      nameAmharic: 'ደብረ ታቦር',
      nameEnglish: 'Debre Tabor (Transfiguration)',
      month: 11, day: 13,
      category: HolidayCategory.orthodoxFeast,
      descriptionAmharic: 'ጌታ ኢየሱስ ክርስቶስ ብርሃን ሆኖ ተለወጠ',
      descriptionEnglish: 'Transfiguration of Christ on Mount Tabor',
      importanceLevel: 4,
    ),

    Holiday(
      nameAmharic: 'ፍልሰታ ማርያም',
      nameEnglish: 'Filseta Mariam (Assumption of Mary)',
      month: 12, day: 16,
      category: HolidayCategory.marianFeast,
      descriptionAmharic: 'ድንግል ማርያም ፍልሰታ — ነሐሴ 16',
      descriptionEnglish: 'Dormition and Assumption of the Virgin Mary',
      importanceLevel: 5,
      isPublicHoliday: false,
    ),

    // ── Monthly Marian Feast (Hidar 21) ────────────────────────────────────
    Holiday(
      nameAmharic: 'ኅዳር ማርያም',
      nameEnglish: 'Hidar Mariam',
      month: 3, day: 21,
      category: HolidayCategory.marianFeast,
      descriptionAmharic: 'ኅዳር 21 — ማርያም',
      importanceLevel: 3,
    ),

    // ── Saint Days (Monthly cycle on fixed dates) ──────────────────────────

    Holiday(
      nameAmharic: 'ቅዱስ ዮሐንስ ሐዋርያ',
      nameEnglish: 'Saint John the Apostle',
      month: 5, day: 27,
      category: HolidayCategory.saintCommemoration,
      importanceLevel: 3,
    ),

    Holiday(
      nameAmharic: 'ቅዱስ ጊዮርጊስ',
      nameEnglish: 'Saint George',
      month: 1, day: 23,
      category: HolidayCategory.saintCommemoration,
      descriptionAmharic: 'ሰማዕቱ ቅዱስ ጊዮርጊስ',
      descriptionEnglish: 'The Great Martyr Saint George',
      importanceLevel: 4,
    ),

    Holiday(
      nameAmharic: 'ቅዱስ ሚካኤል',
      nameEnglish: 'Saint Michael the Archangel',
      month: 1, day: 12,
      category: HolidayCategory.saintCommemoration,
      descriptionAmharic: 'ሊቀ መላዕክት ቅዱስ ሚካኤል',
      importanceLevel: 4,
    ),

    Holiday(
      nameAmharic: 'ቅዱስ ቅዱስ ላሊበላ',
      nameEnglish: 'Saint Lalibela',
      month: 4, day: 12,
      category: HolidayCategory.saintCommemoration,
      descriptionAmharic: 'ቅዱስ ላሊበላ',
      importanceLevel: 3,
    ),

    Holiday(
      nameAmharic: 'ቅዱስ ሩፋኤል',
      nameEnglish: 'Saint Raphael',
      month: 2, day: 3,
      category: HolidayCategory.saintCommemoration,
      importanceLevel: 3,
    ),

    // Holiday(
    //   nameAmharic: 'ቅዱስ ጳውሎስ',
    //   nameEnglish: 'Saint Paul',
    //   month: 11, day: 5,
    //   category: HolidayCategory.saintCommemoration,
    //   importanceLevel: 3,
    // ),

    // Holiday(
    //   nameAmharic: 'ቅዱስ ሐዋርያ ጴጥሮስ',
    //   nameEnglish: 'Saint Peter',
    //   month: 11, day: 5,
    //   category: HolidayCategory.saintCommemoration,
    //   importanceLevel: 3,
    // ),

    // ── Ethiopian New Year Eve ─────────────────────────────────────────────
    Holiday(
      nameAmharic: 'ዋሉ (የዓዲ ዋዜማ)',
      nameEnglish: 'Pagume 5/6 — Year Eve',
      month: 13, day: 5,
      category: HolidayCategory.nationalHoliday,
      importanceLevel: 3,
    ),
  ];

  /// Get all holidays for a specific date
  static List<Holiday> getHolidaysForDate(EthiopianDate date) {
    return fixedHolidays
        .where((h) => h.month == date.month && h.day == date.day)
        .toList();
  }

  /// Get all holidays for a month
  static List<Holiday> getHolidaysForMonth(int month) {
    return fixedHolidays.where((h) => h.month == month).toList();
  }

  /// Get upcoming holidays from a given date (next N days)
  static List<({Holiday holiday, EthiopianDate date})> getUpcomingHolidays(
    EthiopianDate from, {
    int count = 5,
    int year = 0,
  }) {
    final ethiopianYear = year > 0 ? year : from.year;
    final results = <({Holiday holiday, EthiopianDate date})>[];
    final fromJdn = from.toJdn();

    // Check current and next year
    for (final y in [ethiopianYear, ethiopianYear + 1]) {
      for (final h in fixedHolidays) {
        // Handle Pagume leap year adjustment
        final maxDay =
            CalendarEngine.daysInEthiopianMonth(y, h.month);
        final day = h.day.clamp(1, maxDay);
        final hDate = EthiopianDate(year: y, month: h.month, day: day);
        if (hDate.toJdn() >= fromJdn) {
          results.add((holiday: h, date: hDate));
        }
      }
    }

    results.sort((a, b) => a.date.toJdn().compareTo(b.date.toJdn()));
    return results.take(count).toList();
  }
}