/// Format waktu konsisten `30 OKT · 10:00 AM` (DESIGN.md §2 / RULES §4.4).
/// Diimplement manual (tanpa dep intl) — SATU tempat, tidak ad-hoc di widget.
library;

import 'filters.dart' show sameDay;

const _bulan = [
  'JAN',
  'FEB',
  'MAR',
  'APR',
  'MEI',
  'JUN',
  'JUL',
  'AGU',
  'SEP',
  'OKT',
  'NOV',
  'DES',
];

String fmtDeadline(DateTime d) {
  final jam24 = d.hour % 24;
  final ap = jam24 >= 12 ? 'PM' : 'AM';
  final h12 = jam24 % 12 == 0 ? 12 : jam24 % 12;
  final mm = d.minute.toString().padLeft(2, '0');
  return '${d.day} ${_bulan[d.month - 1]} · '
      '${h12.toString().padLeft(2, '0')}:$mm $ap';
}

String fmtMonthYear(DateTime d) {
  const penuh = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  return '${penuh[d.month - 1]} ${d.year}';
}

const _hari = ['SENIN', 'SELASA', 'RABU', 'KAMIS', 'JUMAT', 'SABTU', 'MINGGU'];

/// Overline SummaryCard: `MINGGU, 26 OKT 2026` (design-reference Beranda).
String fmtHeaderDate(DateTime d) =>
    '${_hari[d.weekday - 1]}, ${d.day} ${_bulan[d.month - 1]} ${d.year}';

/// Label hari terpilih Jadwal: `Jum, 30 Okt` (skema id-ID short).
String fmtShortDay(DateTime d) {
  const short = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
  return '${short[d.weekday - 1]}, ${d.day} ${_bulan[d.month - 1]}';
}

/// Stempel waktu item inbox (prototype renderNotifs):
/// `Hari ini · 08:00` / `Kemarin · 08:00` / `27 Okt` (+ tahun beda).
String fmtNotifTime(DateTime at, DateTime now) {
  final hh = at.hour.toString().padLeft(2, '0');
  final mm = at.minute.toString().padLeft(2, '0');
  if (sameDay(at, now)) return 'Hari ini · $hh:$mm';
  if (sameDay(at, now.subtract(const Duration(days: 1)))) {
    return 'Kemarin · $hh:$mm';
  }
  final tahun = at.year != now.year ? ' ${at.year}' : '';
  return '${at.day} ${_bulan[at.month - 1]}$tahun';
}
