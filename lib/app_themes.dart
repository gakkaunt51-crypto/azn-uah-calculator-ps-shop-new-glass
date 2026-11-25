import 'package:flutter/material.dart';

@immutable
class AppThemePalette {
  const AppThemePalette({
    required this.id,
    required this.name,
    required this.seed,
    this.light = false,
    this.gradientStart,
    this.gradientEnd,
    this.oled = false,
    this.isGlass = false,
  });

  final String id;
  final String name;
  final int seed;
  final bool light;
  final int? gradientStart;
  final int? gradientEnd;
  final bool oled;
  final bool isGlass;

  Color get seedColor => Color(seed);
  bool get isGradient => gradientStart != null && gradientEnd != null;
  LinearGradient? get gradient => isGradient
      ? LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(gradientStart!), Color(gradientEnd!)],
        )
      : null;
  Color get swatchColor => Color(gradientStart ?? seed);
}

@immutable
class GlassGradientPreset {
  const GlassGradientPreset({
    required this.name,
    required this.bgStart,
    required this.bgEnd,
    required this.orb1,
    required this.orb2,
    required this.seed,
  });

  final String name;
  final int bgStart;
  final int bgEnd;
  final int orb1;
  final int orb2;
  final int seed;
}

const glassGradientPresets = <GlassGradientPreset>[
  GlassGradientPreset(
    name: 'Неоновый аметист',
    bgStart: 0xFF0E0B1E,
    bgEnd: 0xFF1C1338,
    orb1: 0xFF7C3AED,
    orb2: 0xFF06B6D4,
    seed: 0xFF8B5CF6,
  ),
  GlassGradientPreset(
    name: 'Глубокий океан',
    bgStart: 0xFF071324,
    bgEnd: 0xFF0E2A47,
    orb1: 0xFF0284C7,
    orb2: 0xFF2DD4BF,
    seed: 0xFF38BDF8,
  ),
  GlassGradientPreset(
    name: 'Изумрудный лёд',
    bgStart: 0xFF071A17,
    bgEnd: 0xFF10342C,
    orb1: 0xFF10B981,
    orb2: 0xFF38BDF8,
    seed: 0xFF34D399,
  ),
  GlassGradientPreset(
    name: 'Закатный киберпанк',
    bgStart: 0xFF1E0B1D,
    bgEnd: 0xFF2F1326,
    orb1: 0xFFEC4899,
    orb2: 0xFFF59E0B,
    seed: 0xFFF472B6,
  ),
  GlassGradientPreset(
    name: 'Графитовый кварц',
    bgStart: 0xFF0E1016,
    bgEnd: 0xFF1B202C,
    orb1: 0xFF6366F1,
    orb2: 0xFF94A3B8,
    seed: 0xFF818CF8,
  ),
];

@immutable
class GlassThemeConfig {
  const GlassThemeConfig({
    this.presetIndex = 0,
    this.bgStart = 0xFF0E0B1E,
    this.bgEnd = 0xFF1C1338,
    this.orb1 = 0xFF7C3AED,
    this.orb2 = 0xFF06B6D4,
    this.blurSigma = 14.0,
    this.glassOpacity = 0.12,
    this.borderGlow = 0.24,
  });

  final int presetIndex;
  final int bgStart;
  final int bgEnd;
  final int orb1;
  final int orb2;
  final double blurSigma;
  final double glassOpacity;
  final double borderGlow;

  factory GlassThemeConfig.fromPreset(int index) {
    final safeIdx = index.clamp(0, glassGradientPresets.length - 1).toInt();
    final p = glassGradientPresets[safeIdx];
    return GlassThemeConfig(
      presetIndex: safeIdx,
      bgStart: p.bgStart,
      bgEnd: p.bgEnd,
      orb1: p.orb1,
      orb2: p.orb2,
    );
  }

  GlassThemeConfig copyWith({
    int? presetIndex,
    int? bgStart,
    int? bgEnd,
    int? orb1,
    int? orb2,
    double? blurSigma,
    double? glassOpacity,
    double? borderGlow,
  }) {
    return GlassThemeConfig(
      presetIndex: presetIndex ?? this.presetIndex,
      bgStart: bgStart ?? this.bgStart,
      bgEnd: bgEnd ?? this.bgEnd,
      orb1: orb1 ?? this.orb1,
      orb2: orb2 ?? this.orb2,
      blurSigma: blurSigma ?? this.blurSigma,
      glassOpacity: glassOpacity ?? this.glassOpacity,
      borderGlow: borderGlow ?? this.borderGlow,
    );
  }

  Map<String, dynamic> toJson() => {
        'preset_index': presetIndex,
        'bg_start': bgStart,
        'bg_end': bgEnd,
        'orb1': orb1,
        'orb2': orb2,
        'blur_sigma': blurSigma,
        'glass_opacity': glassOpacity,
        'border_glow': borderGlow,
      };

  factory GlassThemeConfig.fromJson(Map<String, dynamic> json) {
    return GlassThemeConfig(
      presetIndex: (json['preset_index'] as num?)?.toInt() ?? 0,
      bgStart: (json['bg_start'] as num?)?.toInt() ?? 0xFF0E0B1E,
      bgEnd: (json['bg_end'] as num?)?.toInt() ?? 0xFF1C1338,
      orb1: (json['orb1'] as num?)?.toInt() ?? 0xFF7C3AED,
      orb2: (json['orb2'] as num?)?.toInt() ?? 0xFF06B6D4,
      blurSigma: ((json['blur_sigma'] as num?)?.toDouble() ?? 14.0).clamp(4.0, 24.0),
      glassOpacity: ((json['glass_opacity'] as num?)?.toDouble() ?? 0.12).clamp(0.05, 0.30),
      borderGlow: ((json['border_glow'] as num?)?.toDouble() ?? 0.24).clamp(0.08, 0.55),
    );
  }
}

const appThemePalettes = <AppThemePalette>[
  // Glassmorphism theme
  AppThemePalette(
    id: 'glass-morphism',
    name: 'Стекло (Glass)',
    seed: 0xFF8B5CF6,
    gradientStart: 0xFF1E1338,
    gradientEnd: 0xFF06B6D4,
    isGlass: true,
  ),

  // 20 solid themes
  AppThemePalette(id: 'ocean-blue', name: 'Океан', seed: 0xFF3888D8),
  AppThemePalette(id: 'oled-graphite', name: 'OLED-графит', seed: 0xFF777F8B, oled: true),
  AppThemePalette(id: 'paper-light', name: 'Бумага', seed: 0xFF3975B8, light: true),
  AppThemePalette(id: 'forest', name: 'Лес', seed: 0xFF268C62),
  AppThemePalette(id: 'violet', name: 'Фиалка', seed: 0xFF9A75E8),
  AppThemePalette(id: 'ruby', name: 'Рубин', seed: 0xFFE05D68),
  AppThemePalette(id: 'amber', name: 'Янтарь', seed: 0xFFE39A36),
  AppThemePalette(id: 'lagoon', name: 'Лагуна', seed: 0xFF27A6A6),
  AppThemePalette(id: 'slate', name: 'Сланец', seed: 0xFF8291A8),
  AppThemePalette(id: 'cyan', name: 'Циан', seed: 0xFF39B9D4),
  AppThemePalette(id: 'indigo', name: 'Индиго', seed: 0xFF6574D8),
  AppThemePalette(id: 'rose', name: 'Роза', seed: 0xFFD96D9A),
  AppThemePalette(id: 'olive', name: 'Олива', seed: 0xFF929A42),
  AppThemePalette(id: 'plum', name: 'Слива', seed: 0xFF9C5FA6),
  AppThemePalette(id: 'sand', name: 'Песок', seed: 0xFFB8864F, light: true),
  AppThemePalette(id: 'navy', name: 'Полночь', seed: 0xFF4667A7),
  AppThemePalette(id: 'mint', name: 'Мята', seed: 0xFF34A982, light: true),
  AppThemePalette(id: 'coral', name: 'Коралл', seed: 0xFFE2735C),
  AppThemePalette(id: 'lavender', name: 'Лаванда', seed: 0xFF9278C9, light: true),
  AppThemePalette(id: 'silver', name: 'Серебро', seed: 0xFF7F8B98, light: true),

  // 30 gradient themes
  AppThemePalette(id: 'aurora', name: 'Северное сияние', seed: 0xFF55C8BE, gradientStart: 0xFF0B5965, gradientEnd: 0xFF493B78),
  AppThemePalette(id: 'deep-sea', name: 'Глубина', seed: 0xFF47B2D1, gradientStart: 0xFF063B60, gradientEnd: 0xFF087A88),
  AppThemePalette(id: 'blue-hour', name: 'Синий час', seed: 0xFF76A5F8, gradientStart: 0xFF173A70, gradientEnd: 0xFF51478B),
  AppThemePalette(id: 'neon-violet', name: 'Неон', seed: 0xFFBE8CFF, gradientStart: 0xFF452276, gradientEnd: 0xFF922F74),
  AppThemePalette(id: 'orchid', name: 'Орхидея', seed: 0xFFE6A7DC, gradientStart: 0xFF702B68, gradientEnd: 0xFF493B85),
  AppThemePalette(id: 'ember', name: 'Уголь и жар', seed: 0xFFFFA16A, gradientStart: 0xFF502422, gradientEnd: 0xFFB64A32),
  AppThemePalette(id: 'sunset', name: 'Закат', seed: 0xFFFFAA73, gradientStart: 0xFF7D334A, gradientEnd: 0xFFD56C42),
  AppThemePalette(id: 'copper', name: 'Медь', seed: 0xFFE89A70, gradientStart: 0xFF533128, gradientEnd: 0xFF9B5339),
  AppThemePalette(id: 'moss', name: 'Мох', seed: 0xFFA8C87A, gradientStart: 0xFF294A3B, gradientEnd: 0xFF60733C),
  AppThemePalette(id: 'pine', name: 'Сосна', seed: 0xFF67C5A0, gradientStart: 0xFF123B36, gradientEnd: 0xFF17644B),
  AppThemePalette(id: 'jade', name: 'Нефрит', seed: 0xFF75D4BA, gradientStart: 0xFF14564D, gradientEnd: 0xFF257E70),
  AppThemePalette(id: 'ice', name: 'Лёд', seed: 0xFF91DDF1, gradientStart: 0xFF164C71, gradientEnd: 0xFF337E91),
  AppThemePalette(id: 'glacier', name: 'Ледник', seed: 0xFF9CC5FF, gradientStart: 0xFF203F70, gradientEnd: 0xFF3C6F92),
  AppThemePalette(id: 'storm', name: 'Гроза', seed: 0xFF9DAEF5, gradientStart: 0xFF282E50, gradientEnd: 0xFF475A83),
  AppThemePalette(id: 'ink', name: 'Чернила', seed: 0xFF9EABD0, gradientStart: 0xFF20263C, gradientEnd: 0xFF41486B),
  AppThemePalette(id: 'berry', name: 'Ягоды', seed: 0xFFFF91B5, gradientStart: 0xFF612544, gradientEnd: 0xFF9C345C),
  AppThemePalette(id: 'cranberry', name: 'Клюква', seed: 0xFFF18C9A, gradientStart: 0xFF572532, gradientEnd: 0xFFA54150),
  AppThemePalette(id: 'rose-gold', name: 'Розовое золото', seed: 0xFFF1B2A2, gradientStart: 0xFF633A42, gradientEnd: 0xFFAE675D),
  AppThemePalette(id: 'lavender-night', name: 'Лавандовая ночь', seed: 0xFFC2A7F2, gradientStart: 0xFF302B56, gradientEnd: 0xFF684C81),
  AppThemePalette(id: 'amethyst', name: 'Аметист', seed: 0xFFC1A1FF, gradientStart: 0xFF3B286C, gradientEnd: 0xFF7250A2),
  AppThemePalette(id: 'honey', name: 'Мёд', seed: 0xFFFFC468, gradientStart: 0xFF60401D, gradientEnd: 0xFF9A6427),
  AppThemePalette(id: 'citrus', name: 'Цитрус', seed: 0xFFDAE879, gradientStart: 0xFF3C5227, gradientEnd: 0xFF718332),
  AppThemePalette(id: 'volcano', name: 'Вулкан', seed: 0xFFFF8A68, gradientStart: 0xFF472529, gradientEnd: 0xFF9A342F),
  AppThemePalette(id: 'dusk', name: 'Сумерки', seed: 0xFFC39BEB, gradientStart: 0xFF302F5B, gradientEnd: 0xFF75507D),
  AppThemePalette(id: 'coast', name: 'Побережье', seed: 0xFF7FD6CF, gradientStart: 0xFF17545C, gradientEnd: 0xFF367C72),
  AppThemePalette(id: 'blueberry', name: 'Черника', seed: 0xFF9BAEFF, gradientStart: 0xFF29356D, gradientEnd: 0xFF4A4B90),
  AppThemePalette(id: 'steel-blue', name: 'Стальная волна', seed: 0xFF8FC3E0, gradientStart: 0xFF2B485E, gradientEnd: 0xFF3F7180),
  AppThemePalette(id: 'cactus', name: 'Кактус', seed: 0xFFA6CE78, gradientStart: 0xFF304B35, gradientEnd: 0xFF5F783B),
  AppThemePalette(id: 'firelight', name: 'Огонь и свет', seed: 0xFFFFA27D, gradientStart: 0xFF692B2D, gradientEnd: 0xFFB64F37),
  AppThemePalette(id: 'cosmos', name: 'Космос', seed: 0xFF9FB4FF, gradientStart: 0xFF24264D, gradientEnd: 0xFF4F3979),
];

AppThemePalette appThemeById(String id) => appThemePalettes.firstWhere(
      (theme) => theme.id == id,
      orElse: () => appThemePalettes.first,
    );
