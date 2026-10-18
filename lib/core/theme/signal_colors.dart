import 'package:flutter/material.dart';

import 'tokens.g.dart';

/// 보행 신호 색. Material ColorScheme에 없는 색이라 ThemeExtension으로 둔다.
///
/// 신호 표현에만 쓴다. 신호 상태는 색만으로 전달하지 않고 텍스트·형태를 함께 쓴다
/// (design-guide 3-2).
@immutable
class SignalColors extends ThemeExtension<SignalColors> {
  const SignalColors({
    required this.go,
    required this.stop,
    required this.soon,
    required this.unknown,
  });

  static const light = SignalColors(
    go: TokenColors.signalGo,
    stop: TokenColors.signalStop,
    soon: TokenColors.signalSoon,
    unknown: TokenColors.signalUnknown,
  );

  final Color go;
  final Color stop;
  final Color soon;
  final Color unknown;

  @override
  SignalColors copyWith({Color? go, Color? stop, Color? soon, Color? unknown}) {
    return SignalColors(
      go: go ?? this.go,
      stop: stop ?? this.stop,
      soon: soon ?? this.soon,
      unknown: unknown ?? this.unknown,
    );
  }

  @override
  SignalColors lerp(SignalColors? other, double t) {
    if (other == null) return this;
    return SignalColors(
      go: Color.lerp(go, other.go, t)!,
      stop: Color.lerp(stop, other.stop, t)!,
      soon: Color.lerp(soon, other.soon, t)!,
      unknown: Color.lerp(unknown, other.unknown, t)!,
    );
  }
}
