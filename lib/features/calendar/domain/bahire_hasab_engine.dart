/// ─────────────────────────────────────────────────────────────────────────────
///  BAHIRE HASAB ENGINE
///  Calculates all Ethiopian Orthodox movable feasts and fasting seasons
///  based on the Bahire Hasab (Sea of Computation) — the traditional Ethiopian
///  computus for determining Orthodox holy days.
///
///  The system is anchored on Easter (Tensae) and works backwards/forwards
///  to derive all other movable feasts.
///
///  Key anchor: Ethiopian Easter (Fasika/Tensae)
///  Using the Ethiopian version of the Alexandrian Easter computation
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'calendar_engine.dart';

class MovableFeast {
  final String nameAmharic;
  final String nameEnglish;
  final EthiopianDate date;
  final FeastType type;
  final String? descriptionAmharic;
  final String? descriptionEnglish;
  final FastingType? associatedFasting;

  const MovableFeast({
    required this.nameAmharic,
    required this.nameEnglish,
    required this.date,
    required this.type,
    this.descriptionAmharic,
    this.descriptionEnglish,
    this.associatedFasting,
  });
}

enum FeastType {
  major,        // ዐቢይ (Great feast of the Lord)
  marian,       // ማርያም (Feast of Mary)
  saint,        // ቅዱሳን (Saints)
  commemorative,
  fast,
  eve,
}

class FastingPeriod {
  final String nameAmharic;
  final String nameEnglish;
  final EthiopianDate start;
  final EthiopianDate end;
  final FastingType type;
  final String? descriptionAmharic;
  final bool morningFast;  // No eating until 9 AM
  final bool eveningFast;  // No meat/dairy
  final int durationDays;

  const FastingPeriod({
    required this.nameAmharic,
    required this.nameEnglish,
    required this.start,
    required this.end,
    required this.type,
    this.descriptionAmharic,
    this.morningFast = true,
    this.eveningFast = true,
    required this.durationDays,
  });
}

enum FastingType {
  abiyTsom,     // ዐቢይ ጾም — Great Lent (55 days)
  tsome_egzi,   // ጾም ጌታ — Fast of the Lord
  filseta,      // ፍልሰታ — Assumption fast (August)
  genna,        // ገና — Advent fast before Christmas
  nineveah,     // ጾም ነነዌ — Fast of Nineveh
  apostles,     // ጾም ሐዋርያት — Apostles' fast
  wednesdays,   // ረቡዕ — Wednesday fast
  fridays,      // ዓርብ — Friday fast
}

class BahireHasabEngine {
  BahireHasabEngine._();

  // ─── Amete Mihret (Ethiopian Calendar year offset) ───────────────────────
  // The Ethiopian year is: Gregorian_year - 7 (approximately)
  // More precisely: Ethiopian year = Gregorian year - 8 (after Sept 11)
  //                                = Gregorian year - 7 (before Sept 11)

  /// Calculate Ethiopian Easter (Tensae/Fasika) for a given Ethiopian year
  /// Based on the Alexandrian Easter algorithm adapted for Ethiopian calendar
  static EthiopianDate calculateEaster(int ethiopianYear) {
    // Step 1: Find the Amete Alem (era of the world) year
    // Ethiopian calendar uses Era of the World (Amete Alem = 5500 + year)
    final ameteAlem = ethiopianYear + 5500;

    // Step 2: Calculate remainder mod 19 (Wenber)
    final wenber = ameteAlem % 19;

    // Step 3: Calculate Abektie (solar cycle position)
    final abektie = (wenber * 11) % 30;

    // Step 4: Calculate Metkie (lunar month offset)  
    final metkie = abektie < 5 ? abektie + 2 : abektie - 3;

    // Step 5: Mebaja (day of full moon)
    // The full moon falls on Miyazia (month 8) day = 29 - metkie
    // This gives us the Paschal full moon
    int easterMonth = 8; // Miyazia
    int easterDay = 29 - metkie;

    // Step 6: Find Sunday after the Paschal full moon
    final fullMoonDate = EthiopianDate(year: ethiopianYear, month: easterMonth, day: easterDay);
    final fullMoonJdn = fullMoonDate.toJdn();
    final fullMoonWeekday = (fullMoonJdn + 1) % 7; // 0=Sunday

    // Easter is the Sunday on or after the full moon
    int daysToSunday = (7 - fullMoonWeekday) % 7;
    final easterJdn = fullMoonJdn + daysToSunday;
    final easterDate = CalendarEngine.jdnToEthiopian(easterJdn);

    return easterDate;
  }

  /// Calculate all movable feasts for a given Ethiopian year
  static List<MovableFeast> getMovableFeasts(int ethiopianYear) {
    final easter = calculateEaster(ethiopianYear);
    final easterJdn = easter.toJdn();
    final feasts = <MovableFeast>[];

    EthiopianDate dayOffset(int days) =>
        CalendarEngine.jdnToEthiopian(easterJdn + days);

    // ── Pre-Easter feasts ──────────────────────────────────────────────────

    // Tsome Hirkal / Nineveah (3 days fast, ~63 days before Easter)
    feasts.add(MovableFeast(
      nameAmharic: 'ጾም ነነዌ',
      nameEnglish: 'Fast of Nineveh',
      date: dayOffset(-63),
      type: FeastType.fast,
      descriptionAmharic: 'ሦስት ቀን የነነዌ ጾም',
      descriptionEnglish: 'Three-day fast of Nineveh (Yonas)',
    ));

    // Hoho Sunday (~56 before Easter)
    feasts.add(MovableFeast(
      nameAmharic: 'ሆሆ',
      nameEnglish: 'Hoho',
      date: dayOffset(-56),
      type: FeastType.commemorative,
      descriptionEnglish: 'Beginning of Great Lent preparation',
    ));

    // Debre Zeit / Abiy Tsom start (~55 days before Easter)
    feasts.add(MovableFeast(
      nameAmharic: 'ዐቢይ ጾም',
      nameEnglish: 'Abiy Tsom (Great Lent)',
      date: dayOffset(-55),
      type: FeastType.fast,
      descriptionAmharic: 'ዐቢይ ጾም ጀምሮ ምእምናን ለ55 ቀናት ይጾማሉ',
      descriptionEnglish: 'Great Lent begins — 55 days of fasting',
    ));

    // Palm Sunday (Hosanna) - 1 week before Easter
    feasts.add(MovableFeast(
      nameAmharic: 'ሆሳዕና (ደብረ ዘይት)',
      nameEnglish: 'Hosanna (Palm Sunday)',
      date: dayOffset(-7),
      type: FeastType.major,
      descriptionAmharic: 'ጌታ ወደ ኢየሩሳሌም ሲገባ ሕዝቡ ሆሳዕና እያሉ ተቀበሉት',
      descriptionEnglish: 'Christ\'s entry into Jerusalem',
    ));

    // Siklet (Crucifixion) — Good Friday
    feasts.add(MovableFeast(
      nameAmharic: 'ስቅለት',
      nameEnglish: 'Siklet (Good Friday)',
      date: dayOffset(-2),
      type: FeastType.major,
      descriptionAmharic: 'ጌታ ኢየሱስ ክርስቶስ ተሰቅሎ ሞቶ የዳነን',
      descriptionEnglish: 'Crucifixion of Jesus Christ',
    ));

    // Holy Saturday
    feasts.add(MovableFeast(
      nameAmharic: 'ቀዳሚት ሰንበት',
      nameEnglish: 'Holy Saturday',
      date: dayOffset(-1),
      type: FeastType.major,
      descriptionEnglish: 'Day before Easter — great vigil',
    ));

    // Easter (Tensae / Fasika)
    feasts.add(MovableFeast(
      nameAmharic: 'ትንሣኤ (ፋሲካ)',
      nameEnglish: 'Tensae (Ethiopian Easter)',
      date: easter,
      type: FeastType.major,
      descriptionAmharic: 'ጌታ ኢየሱስ ክርስቶስ ከሙታን ተነስቷል',
      descriptionEnglish: 'Resurrection of Jesus Christ — the greatest feast',
    ));

    // ── Post-Easter feasts ─────────────────────────────────────────────────

    // Debre Genet (Doubting Thomas Sunday) +7
    feasts.add(MovableFeast(
      nameAmharic: 'ደብረ ገነት',
      nameEnglish: 'Debre Genet',
      date: dayOffset(7),
      type: FeastType.major,
      descriptionEnglish: 'The Sunday of Doubting Thomas',
    ));

    // Tibebe Mariam (3rd Sunday after Easter) +14
    feasts.add(MovableFeast(
      nameAmharic: 'ጥብ ሶሻ',
      nameEnglish: 'Tibebe Mariam',
      date: dayOffset(14),
      type: FeastType.marian,
      descriptionEnglish: 'Sunday of the Wise Virgins',
    ));

    // Gebäre Mehret +21
    feasts.add(MovableFeast(
      nameAmharic: 'ገባሬ ምሕረት',
      nameEnglish: 'Gebare Mehret',
      date: dayOffset(21),
      type: FeastType.major,
    ));

    // Yesus Chelot +28
    feasts.add(MovableFeast(
      nameAmharic: 'ኢየሱስ ጨሎት',
      nameEnglish: 'Yesus Chelot',
      date: dayOffset(28),
      type: FeastType.major,
    ));

    // Hamus Erget / Ascension of Christ (+39)
    feasts.add(MovableFeast(
      nameAmharic: 'ዕርገት',
      nameEnglish: 'Erget (Ascension)',
      date: dayOffset(39),
      type: FeastType.major,
      descriptionAmharic: 'ጌታ ዐረገ ወደ ሰማይ',
      descriptionEnglish: 'Ascension of Christ into Heaven (39 days after Easter)',
    ));

    // Erget Sunday (+42)
    feasts.add(MovableFeast(
      nameAmharic: 'ዕርገት (እሁድ)',
      nameEnglish: 'Erget Sunday',
      date: dayOffset(42),
      type: FeastType.major,
    ));

    // Pentecost (Paraqlitos) +49
    feasts.add(MovableFeast(
      nameAmharic: 'ጰራቅሊጦስ (ሃምሳኛ)',
      nameEnglish: 'Paraqlitos (Pentecost)',
      date: dayOffset(49),
      type: FeastType.major,
      descriptionAmharic: 'መንፈስ ቅዱስ ወረደ',
      descriptionEnglish: 'Descent of the Holy Spirit — 50 days after Easter',
    ));

    // Apostles Fast begins (+50)
    feasts.add(MovableFeast(
      nameAmharic: 'ጾም ሐዋርያት',
      nameEnglish: 'Apostles\' Fast',
      date: dayOffset(50),
      type: FeastType.fast,
      descriptionEnglish: 'Fast of the Apostles begins (after Pentecost)',
    ));

    return feasts;
  }

  /// Calculate all fasting periods for a given Ethiopian year
  static List<FastingPeriod> getFastingPeriods(int ethiopianYear) {
    final easter = calculateEaster(ethiopianYear);
    final easterJdn = easter.toJdn();
    final periods = <FastingPeriod>[];

    EthiopianDate dayOffset(int days) =>
        CalendarEngine.jdnToEthiopian(easterJdn + days);

    // ── Great Lent (Abiy Tsom) ─────────────────────────────────────────────
    final abiyStart = dayOffset(-55);
    final abiyEnd = dayOffset(-1); // Through Holy Saturday
    periods.add(FastingPeriod(
      nameAmharic: 'ዐቢይ ጾም',
      nameEnglish: 'Abiy Tsom (Great Lent)',
      start: abiyStart,
      end: abiyEnd,
      type: FastingType.abiyTsom,
      descriptionAmharic: '55 ቀን ጾም — ትልቁ ጾም',
      durationDays: 55,
      morningFast: true,
      eveningFast: true,
    ));

    // ── Fast of Nineveh (3 days) ───────────────────────────────────────────
    final nineveahStart = dayOffset(-63);
    final nineveahEnd = dayOffset(-61);
    periods.add(FastingPeriod(
      nameAmharic: 'ጾም ነነዌ',
      nameEnglish: 'Tsome Nineveh',
      start: nineveahStart,
      end: nineveahEnd,
      type: FastingType.nineveah,
      descriptionAmharic: 'ሦስት ቀን ጾም — የነነዌ ሰዎች ንሰሐ',
      durationDays: 3,
    ));

    // ── Apostles Fast (from Pentecost+1 to July 5 — Hamle Krstna Mariam) ──
    final apostlesStart = dayOffset(50);
    final apostlesEnd = EthiopianDate(year: ethiopianYear, month: 11, day: 5); // Hamle 5
    final apostlesDuration =
        apostlesEnd.toJdn() - apostlesStart.toJdn() + 1;
    if (apostlesDuration > 0) {
      periods.add(FastingPeriod(
        nameAmharic: 'ጾም ሐዋርያት',
        nameEnglish: 'Apostles\' Fast',
        start: apostlesStart,
        end: apostlesEnd,
        type: FastingType.apostles,
        descriptionAmharic: 'ሐዋርያት ጾሙ',
        durationDays: apostlesDuration,
      ));
    }

    // ── Filseta / Assumption Fast (Nehasse 1–15) ───────────────────────────
    periods.add(FastingPeriod(
      nameAmharic: 'ፍልሰታ ጾም',
      nameEnglish: 'Filseta Fast (Assumption)',
      start: EthiopianDate(year: ethiopianYear, month: 12, day: 1),
      end: EthiopianDate(year: ethiopianYear, month: 12, day: 15),
      type: FastingType.filseta,
      descriptionAmharic: 'ለ15 ቀናት የእናታችን ማርያም ፍልሰታ ጾም',
      durationDays: 15,
    ));

    // ── Advent / Genna Fast (Hidar 15 – Tahsas 28) ────────────────────────
    periods.add(FastingPeriod(
      nameAmharic: 'ጾም ገና (ፊልጶስ)',
      nameEnglish: 'Advent / Genna Fast',
      start: EthiopianDate(year: ethiopianYear, month: 3, day: 15),
      end: EthiopianDate(year: ethiopianYear, month: 4, day: 28),
      type: FastingType.genna,
      descriptionAmharic: '43 ቀን ጾም ለፊልጶስ',
      durationDays: 43,
    ));

    return periods;
  }

  /// Check if a given Ethiopian date falls within a fasting period
  static FastingPeriod? getFastingPeriodForDate(
      EthiopianDate date, List<FastingPeriod> periods) {
    final jdn = date.toJdn();
    for (final period in periods) {
      if (jdn >= period.start.toJdn() && jdn <= period.end.toJdn()) {
        return period;
      }
    }
    return null;
  }

  /// Check if today is a Wednesday or Friday fast (weekly fasts)
  static bool isWeeklyFastDay(EthiopianDate date) {
    final weekday = CalendarEngine.ethiopianWeekday(date);
    return weekday == 3 || weekday == 5; // Wednesday=3, Friday=5
  }
}