import 'package:flutter/material.dart';

import 'signal_colors.dart';
import 'tokens.g.dart';

/// 디자인 토큰(tokens.g.dart)을 Material 3 테마에 연결한다.
///
/// 다크 모드는 미정이다 (design-guide DG-02). 결정 전까지 라이트 테마만 둔다.
abstract final class AppTheme {
  static const fontFamily = 'Pretendard';

  /// 잔여시간처럼 바뀌는 숫자에 쓴다. 고정폭 숫자라 숫자가 바뀌어도 폭이 흔들리지 않는다.
  static final countdown = TokenTypography.countdown.copyWith(
    fontFamily: fontFamily,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static ThemeData light() {
    const colorScheme = ColorScheme.light(
      primary: TokenColors.brandPrimary,
      onPrimary: TokenColors.brandOnPrimary,
      // Material 기본 보조색(청록)은 신호 녹색과 헷갈린다 — 신호색은 신호에만 (design-guide 3-1)
      secondary: TokenColors.brandPrimary,
      onSecondary: TokenColors.brandOnPrimary,
      secondaryContainer: TokenColors.bgSubtle,
      onSecondaryContainer: TokenColors.brandPrimary,
      surface: TokenColors.bgDefault,
      onSurface: TokenColors.textPrimary,
      onSurfaceVariant: TokenColors.textSecondary,
      surfaceContainerLow: TokenColors.bgSubtle,
      outline: TokenColors.borderDefault,
      outlineVariant: TokenColors.borderDefault,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: TokenColors.bgDefault,
      textTheme:
          const TextTheme(
            headlineSmall: TokenTypography.title1,
            titleLarge: TokenTypography.title2,
            bodyLarge: TokenTypography.body1,
            bodyMedium: TokenTypography.body2,
            bodySmall: TokenTypography.caption,
          ).apply(
            bodyColor: TokenColors.textPrimary,
            displayColor: TokenColors.textPrimary,
          ),
      // 아래는 lib/core/ui 컴포넌트가 감싸는 Material 요소의 모양 (D-073)
      appBarTheme: AppBarTheme(
        backgroundColor: TokenColors.bgDefault,
        foregroundColor: TokenColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: TokenSpace.s5, // 본문 좌우 여백 20과 맞춘다 (design-guide 2장)
        titleTextStyle: TokenTypography.title2.copyWith(fontFamily: fontFamily, color: TokenColors.textPrimary, fontWeight: FontWeight.w700),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: TokenColors.textPrimary,
        contentTextStyle: TokenTypography.body2.copyWith(fontFamily: fontFamily, color: TokenColors.bgDefault),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TokenRadius.md)),
        elevation: 0,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: TokenColors.bgDefault,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: TokenColors.borderStrong,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(TokenRadius.lg))),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: TokenColors.bgSubtle,
        contentPadding: const EdgeInsets.all(TokenSpace.s4),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(TokenRadius.md), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(TokenRadius.md), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TokenRadius.md),
          borderSide: const BorderSide(color: TokenColors.brandPrimary, width: TokenStroke.line),
        ),
        hintStyle: TokenTypography.body1.copyWith(color: TokenColors.textTertiary),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(TokenColors.bgDefault),
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? TokenColors.brandPrimary : TokenColors.borderStrong),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: TokenColors.brandPrimary),
      dividerTheme: const DividerThemeData(color: TokenColors.borderDefault, thickness: 1, space: TokenSpace.s6),
      extensions: const [SignalColors.light],
    );
  }
}
