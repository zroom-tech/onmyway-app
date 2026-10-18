// 생성 파일 — 직접 수정하지 말 것. onmyway-next/design-tokens/tokens.json 수정 후 `npm run tokens`

import 'package:flutter/painting.dart';

abstract final class TokenColors {
  static const brandPrimary = Color(0xFF2D4FD8);
  static const brandOnPrimary = Color(0xFFFFFFFF);
  static const brandPrimaryEdge = Color(0xFF1E3AA8);
  static const brandSubtle = Color(0xFFEEF2FD);
  static const textPrimary = Color(0xFF1A1D23);
  static const textSecondary = Color(0xFF4A5160);
  static const textTertiary = Color(0xFF6B7280);
  static const bgDefault = Color(0xFFFFFFFF);
  static const bgSubtle = Color(0xFFF7F8FA);
  static const borderDefault = Color(0xFFE5E7EB);
  static const borderStrong = Color(0xFFD3D7DE);
  static const signalGo = Color(0xFF087A4B);
  static const signalStop = Color(0xFFD12E2E);
  static const signalSoon = Color(0xFF9A5B00);
  static const signalUnknown = Color(0xFF6B7280);
}

abstract final class TokenTypography {
  static const countdown = TextStyle(
    fontSize: 56,
    height: 1.1429,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.5,
  );
  static const title1 = TextStyle(
    fontSize: 24,
    height: 1.3333,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.6,
  );
  static const title2 = TextStyle(
    fontSize: 20,
    height: 1.4000,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
  );
  static const body1 = TextStyle(
    fontSize: 17,
    height: 1.5294,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.2,
  );
  static const body2 = TextStyle(
    fontSize: 15,
    height: 1.4667,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.15,
  );
  static const caption = TextStyle(
    fontSize: 13,
    height: 1.3846,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );
  static const button = TextStyle(
    fontSize: 17,
    height: 1.4118,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
  );
}

abstract final class TokenSpace {
  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 20;
  static const double s6 = 24;
  static const double s8 = 32;
  static const double s10 = 40;
}

abstract final class TokenRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double full = 9999;
}

abstract final class TokenStroke {
  static const double line = 2;
  static const double edge = 4;
}
