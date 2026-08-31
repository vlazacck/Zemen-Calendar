void main() {
  int gregorianToJdn(int year, int month, int day) {
    final a = (14 - month) ~/ 12;
    final y = year + 4800 - a;
    final m = month + 12 * a - 3;
    return day + (153 * m + 2) ~/ 5 + 365 * y + y ~/ 4 - y ~/ 100 + y ~/ 400 - 32045;
  }

  const epochJdn = 1723856;

  Map<String, int> jdnToEth(int jdn) {
    final days = jdn - epochJdn;
    final year = (4 * days + 3) ~/ 1461 + 1;
    final dayOfYear = days - (365 * (year - 1) + year ~/ 4);
    final month = dayOfYear ~/ 30 + 1;
    final day = dayOfYear % 30 + 1;
    return {'year': year, 'month': month, 'day': day};
  }

  // June 19, 2026 Gregorian
  final jdn = gregorianToJdn(2026, 6, 19);
  print('JDN for June 19 2026: $jdn');
  final eth = jdnToEth(jdn);
  print('Ethiopian with epoch 1723856: year=${eth["year"]} month=${eth["month"]} day=${eth["day"]}');

  // Try epoch 1724220 (alternative)
  const epochJdn2 = 1724220;
  Map<String, int> jdnToEth2(int jdn) {
    final days = jdn - epochJdn2;
    final year = (4 * days + 3) ~/ 1461 + 1;
    final dayOfYear = days - (365 * (year - 1) + year ~/ 4);
    final month = dayOfYear ~/ 30 + 1;
    final day = dayOfYear % 30 + 1;
    return {'year': year, 'month': month, 'day': day};
  }
  final eth2 = jdnToEth2(jdn);
  print('Ethiopian with epoch 1724220: year=${eth2["year"]} month=${eth2["month"]} day=${eth2["day"]}');

  // Ethiopian New Year 2018 (Meskerem 1, 2018) = September 11, 2025
  final jdn2018 = gregorianToJdn(2025, 9, 11);
  print('\nJDN for Sep 11, 2025: $jdn2018');
  final ethNew = jdnToEth(jdn2018);
  print('Ethiopian with epoch 1723856: year=${ethNew["year"]} month=${ethNew["month"]} day=${ethNew["day"]}');
  final ethNew2 = jdnToEth2(jdn2018);
  print('Ethiopian with epoch 1724220: year=${ethNew2["year"]} month=${ethNew2["month"]} day=${ethNew2["day"]}');
}
