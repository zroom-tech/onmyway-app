/// 등록 때 주변 횡단보도 판정 (traffic-signal FR-03-B, D-028). 서버 `src/lib/signal/register.ts`와 같은 기준.
/// 서버도 같은 기준으로 다시 확인하므로, 여기서는 기록 전에 사용자에게 먼저 물어보는 데 쓴다.
library;

import 'package:latlong2/latlong.dart';

/// 운영 설정값 초기값
const duplicateRadiusM = 15.0;
const duplicateAngleDeg = 20.0;
const intersectionRadiusM = 40.0;

/// 등록 지도에 기존 횡단보도를 그리는 반경 (D-070) — 등록 가능 50m + 최대 길이 80m의 절반
const existingRadiusM = 90.0;

class Candidate {
  const Candidate({required this.id, required this.name, required this.endA, required this.endB, required this.groupId});
  final String id;
  final String name;
  final LatLng endA;
  final LatLng endB;
  final String groupId;

  LatLng get midpoint => mid(endA, endB);
}

const _distance = Distance();

LatLng mid(LatLng a, LatLng b) => LatLng((a.latitude + b.latitude) / 2, (a.longitude + b.longitude) / 2);

double distanceM(LatLng a, LatLng b) => _distance.as(LengthUnit.Meter, a, b);

/// 방향 없는 두 선분의 각도 차 (0~90)
double lineAngleDiff(LatLng a1, LatLng a2, LatLng b1, LatLng b2) {
  double norm(double deg) => ((deg % 180) + 180) % 180;
  final d = (norm(_distance.bearing(a1, a2)) - norm(_distance.bearing(b1, b2))).abs();
  return d > 90 ? 180 - d : d;
}

/// "이 횡단보도인가요?" 후보 (FR-03-B-01)
List<Candidate> duplicates(List<Candidate> all, LatLng a, LatLng b) {
  final m = mid(a, b);
  final list = all.where((c) => distanceM(c.midpoint, m) <= duplicateRadiusM && lineAngleDiff(c.endA, c.endB, a, b) <= duplicateAngleDeg).toList()
    ..sort((x, y) => distanceM(x.midpoint, m).compareTo(distanceM(y.midpoint, m)));
  return list;
}

/// 같은 교차로로 묶일 횡단보도 — "같이 켜지는 횡단보도" 선택지 (FR-03-B-04·C-01), 가까운 순
List<Candidate> intersectionMembers(List<Candidate> all, LatLng a, LatLng b) {
  final m = mid(a, b);
  return all.where((c) => distanceM(c.midpoint, m) <= intersectionRadiusM).toList()
    ..sort((x, y) => distanceM(x.midpoint, m).compareTo(distanceM(y.midpoint, m)));
}
