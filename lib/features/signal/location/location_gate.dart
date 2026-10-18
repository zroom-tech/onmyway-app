import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/ui/ui.dart';

/// 위치 권한은 위치가 필요한 행동을 처음 할 때 요청한다 (traffic-signal D-055, design-guide X6).
/// 앱 실행·탭 진입 때는 부르지 않는다.
///
/// [needAccuracy]: 기록·등록·신고처럼 현장 확인이 필요한 행동이면 true (FR-04-C-03, 오차 50m 초과면 거부)
Future<Position?> ensureLocation(BuildContext context, {required String action, bool needAccuracy = false}) async {
  if (!await Geolocator.isLocationServiceEnabled()) {
    if (context.mounted) _snack(context, '기기의 위치 서비스를 켜 주세요');
    return null;
  }

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    if (!context.mounted) return null;
    final agreed = await _permissionPrompt(context);
    if (agreed != true) return null;
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
    if (context.mounted) await _deniedSheet(context);
    return null;
  }

  final Position pos;
  try {
    // 실내·지하에서 위치가 안 잡히면 버튼이 멈춘 채로 남지 않게 끊는다
    pos = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.best, timeLimit: Duration(seconds: 15)));
  } on TimeoutException {
    if (context.mounted) _snack(context, '위치를 잡지 못했어요. 하늘이 보이는 곳에서 다시 해 주세요');
    return null;
  }
  if (needAccuracy && pos.accuracy > 50) {
    if (context.mounted) _snack(context, '위치를 다시 잡는 중이에요. 잠시 후 다시 해 주세요');
    return null;
  }
  return pos;
}

void _snack(BuildContext context, String msg) => showToast(context, msg);

/// PermissionPrompt (design-guide 4-2) — OS 권한 팝업 직전 설명
Future<bool?> _permissionPrompt(BuildContext context) => showAppSheet<bool>(
      context,
      title: '위치를 써도 될까요?',
      body: '신호를 직접 보고 있는지 확인하려고 위치를 써요. 앱을 쓰는 동안에만 사용해요',
      children: (context) => [
        Button('위치 허용하기', onPressed: () => Navigator.pop(context, true)),
        Button.secondary('허용하지 않고 계속하기', onPressed: () => Navigator.pop(context, false)),
      ],
    );

/// 거부 상태에서 위치가 필요한 행동 진입 (FR-01-A-05, §정책성 문구)
Future<void> _deniedSheet(BuildContext context) => showAppSheet<void>(
      context,
      title: '지금 있는 곳을 확인해야 해요',
      body: '신호를 직접 보고 있는지 확인하려고 위치를 써요',
      children: (context) => [
        Button('설정으로 가기', onPressed: () {
          Navigator.pop(context);
          Geolocator.openAppSettings();
        }),
        Button.secondary('닫기', onPressed: () => Navigator.pop(context)),
      ],
    );
