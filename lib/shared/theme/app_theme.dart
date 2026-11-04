import 'package:flutter/material.dart';

import '../../core/domain/models.dart';

/// Design tokens — DITRANSKRIP TERKUNCI dari DESIGN.md §1.2 (MASTER_SPEC §7).
/// RULES §1.6: widget dilarang meng-hardcode warna/hex di luar file ini.
abstract final class AppColors {
  static const primary = Color(0xFFF97316);
  static const primaryDark = Color(0xFFEA580C);
  static const primarySoft = Color(0xFFFFEDD5);
  static const background = Color(0xFFFDF1E3);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF1C1917);
  static const muted = Color(0xFF78716C);
  static const onPrimary = Color(0xFFFFFFFF);
  static const accent = Color(0xFF8B5CF6);
  static const danger = Color(0xFFE11D48);
  static const success = Color(0xFF059669);

  // kategori — pasangan (bg, ink) dijaga kontras ≥ 4.5:1 (DESIGN §1.3)
  static const catAkademik = Color(0xFFBFD7FE);
  static const catAkademikInk = Color(0xFF1E3A8A);
  static const catPersonal = Color(0xFFF9C9D4);
  static const catPersonalInk = Color(0xFF9D174D);
  static const catOrganisasi = Color(0xFFDDD1FC);
  static const catOrganisasiInk = Color(0xFF5B21B6);
  static const catLainnya = Color(0xFFFDE9A8);
  static const catLainnyaInk = Color(0xFF854D0E);

  static const divider = Color(0xFFF0E4D4);

  // tambahan dari prototype v2 (warna CSS → token, RULES §1.6)
  static const chevron = Color(0xFFCDBFB0); // ikon chevron kartu
  static const fieldFill = Color(0xFFFDF6EE); // bg input
  static const hint = Color(0xFFA8A29E); // teks hint/placeholder
  static const borderSoft = Color(0xFFEFE3D2); // outline tombol sekunder
  static const trackCream = Color(0xFFF3E7D8); // track bar/kalender
  static const dotTask = Color(0xFFEAC98F); // dot "ada tugas" (kalender F2)
  static const iconCream = Color(0xFFE8D5BD); // ikon empty-state
  static const grabber = Color(0xFFEDE5DA); // handle bottom sheet
  static const dangerSoft = Color(0xFFFFF1F2); // bg badge prioritas tinggi
  static const successSoft = Color(0xFFECFDF5); // bg badge selesai
  static const primaryShadow = Color(0x66F97316); // shadow FAB 40% orange
  static const overdueStripe = Color(
    0xFFF9A8B4,
  ); // sisi muda stripe dot overdue (kalender)
}

/// Pasangan warna per kategori — dipakai chip/kartu (ChipCategory).
const categoryColorPairs = <Category, (Color, Color)>{
  Category.akademik: (AppColors.catAkademik, AppColors.catAkademikInk),
  Category.personal: (AppColors.catPersonal, AppColors.catPersonalInk),
  Category.organisasi: (AppColors.catOrganisasi, AppColors.catOrganisasiInk),
  Category.lainnya: (AppColors.catLainnya, AppColors.catLainnyaInk),
};

/// Spacing scale base 4 (DESIGN §3).
abstract final class Spacing {
  static const s4 = 4.0;
  static const s8 = 8.0;
  static const s12 = 12.0;
  static const s16 = 16.0;
  static const s20 = 20.0;
  static const s24 = 24.0;
  static const s32 = 32.0;
}

/// Radius (DESIGN §3).
abstract final class AppRadius {
  static const card = BorderRadius.all(Radius.circular(24));
  static const input = BorderRadius.all(Radius.circular(16));
  static const sheet = BorderRadius.vertical(top: Radius.circular(28));
  static const chip = BorderRadius.all(Radius.circular(999));
}

/// ThemeData aplikasi —(Parameter kental dari token; komponen meng-consume
/// AppColors/AppRadius/Spacing, gaya teks di sini untuk headline/label).
ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    secondary: AppColors.accent,
    error: AppColors.danger,
    surface: AppColors.surface,
  ).copyWith(surface: AppColors.surface);

  final base = ThemeData(useMaterial3: true, colorScheme: scheme);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      foregroundColor: AppColors.ink,
    ),
    dividerTheme: const DividerThemeData(color: AppColors.divider),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(999)),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.fieldFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: AppRadius.input,
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: AppColors.hint, fontSize: 13),
      labelStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.muted,
      ),
    ),
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    ),
  );
}
