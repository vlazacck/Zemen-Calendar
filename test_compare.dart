class EthiopianDate {
  final int year;
  final int month;
  final int day;

  const EthiopianDate({
    required this.year,
    required this.month,
    required this.day,
  });

  @override
  String toString() => '$year-$month-$day';
}

void main() {
  final testCases = [
    (2460565, 2017, 1, 1),
    (2460930, 2018, 1, 1),
    (2461211, 2018, 10, 12),
  ];

  print('Searching for correct conversion parameters...');

  for (int epoch in [1723856, 1724219, 1724220, 1724221, 1724222, 1724223]) {
    for (int leapMode in [0, 1]) { // 0: year ~/ 4, 1: (year - 1) ~/ 4
      int ethiopianToJdn(int year, int month, int day) {
        final leap = (leapMode == 0) ? (year ~/ 4) : ((year - 1) ~/ 4);
        return (year - 1) * 365 +
            leap +
            30 * (month - 1) +
            day -
            1 +
            epoch;
      }

      for (int B = -20; B <= 20; B++) {
        for (int E = -5; E <= 5; E++) {
          bool ok = true;
          for (final t in testCases) {
            final jdn = t.$1;
            final ey = t.$2;
            final em = t.$3;
            final ed = t.$4;

            final days = jdn - epoch;
            final year = (4 * days + B) ~/ 1461 + E;
            
            final leap = (leapMode == 0) ? (year ~/ 4) : ((year - 1) ~/ 4);
            final daysPrior = 365 * (year - 1) + leap;
            final dayOfYear = days - daysPrior;
            final month = dayOfYear ~/ 30 + 1;
            final day = dayOfYear % 30 + 1;

            if (year != ey || month != em || day != ed) {
              ok = false;
              break;
            }
          }

          if (ok) {
            // Verify full range
            bool fullRangeOk = true;
            for (int jdn = epoch; jdn <= 3000000; jdn += 100) {
              final days = jdn - epoch;
              final year = (4 * days + B) ~/ 1461 + E;
              
              final leap = (leapMode == 0) ? (year ~/ 4) : ((year - 1) ~/ 4);
              final daysPrior = 365 * (year - 1) + leap;
              final dayOfYear = days - daysPrior;
              final month = dayOfYear ~/ 30 + 1;
              final day = dayOfYear % 30 + 1;

              final recon = ethiopianToJdn(year, month, day);
              if (recon != jdn) {
                fullRangeOk = false;
                break;
              }

              if (month < 1 || month > 13) {
                fullRangeOk = false;
                break;
              }
              final maxDays = (month == 13) ? ((year % 4 == 3) ? 6 : 5) : 30;
              if (day < 1 || day > maxDays) {
                fullRangeOk = false;
                break;
              }
            }

            if (fullRangeOk) {
              // Verify fully (every single day)
              bool fullyVerified = true;
              for (int jdn = epoch; jdn <= 3000000; jdn++) {
                final days = jdn - epoch;
                final year = (4 * days + B) ~/ 1461 + E;
                
                final leap = (leapMode == 0) ? (year ~/ 4) : ((year - 1) ~/ 4);
                final daysPrior = 365 * (year - 1) + leap;
                final dayOfYear = days - daysPrior;
                final month = dayOfYear ~/ 30 + 1;
                final day = dayOfYear % 30 + 1;

                final recon = ethiopianToJdn(year, month, day);
                if (recon != jdn) {
                  fullyVerified = false;
                  break;
                }
              }

              if (fullyVerified) {
                print('FOUND PERFECT ALGORITHM: epoch=$epoch, leapMode=$leapMode, B=$B, E=$E');
                return;
              }
            }
          }
        }
      }
    }
  }
  print('No perfect algorithm found.');
}
