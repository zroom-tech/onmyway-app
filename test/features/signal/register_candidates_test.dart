// 등록 후보 판정 (traffic-signal FR-03-B-01·B-04, D-028) — 서버 register.ts와 같은 기준
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:onmyway/features/signal/domain/register_candidates.dart';

void main() {
  // 위도 1e-4 ≈ 11.1m, 경도 1e-4 ≈ 8.8m (서울)
  const o = LatLng(37.5006, 127.0365);
  LatLng off(double dLat, double dLng) => LatLng(o.latitude + dLat, o.longitude + dLng);
  Candidate c(String id, LatLng a, LatLng b) => Candidate(id: id, name: id, endA: a, endB: b, groupId: 'g$id');

  final east = c('east', off(0, 0), off(0, 2e-4)); // 동서 방향
  final north = c('north', off(-1e-4, 1.5e-4), off(1e-4, 1.5e-4)); // 남북 방향, 중점 약 13m 떨어짐
  final far = c('far', off(1e-2, 0), off(1e-2, 2e-4));

  test('15m·20° 안 → 중복 후보 (FR-03-B-01)', () {
    final d = duplicates([east, north, far], off(0.5e-4, 0), off(0.5e-4, 2e-4));
    expect(d.map((x) => x.id), ['east']);
  });

  test('방향이 20° 넘게 다르면 중복 아님', () {
    final d = duplicates([north], off(0, 1e-4), off(0, 2e-4));
    expect(d, isEmpty);
  });

  test('반대 방향으로 찍어도 같은 선 (방향 없는 선분)', () {
    final d = duplicates([east], off(0, 2e-4), off(0, 0));
    expect(d.map((x) => x.id), ['east']);
  });

  test('40m 안 횡단보도 = 같은 교차로 후보, 가까운 순 (FR-03-B-04·C-01)', () {
    final m = intersectionMembers([far, north, east], off(-2e-4, 1e-4), off(-2e-4, 3e-4));
    expect(m.map((x) => x.id), ['north', 'east']); // north 22.6m, east 23.9m
  });
}
