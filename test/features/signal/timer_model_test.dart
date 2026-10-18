// 타이머 화면 규칙 (traffic-signal F-02, D-051·D-052·D-053·D-057·D-059~D-062)
import 'package:flutter_test/flutter_test.dart';
import 'package:onmyway/features/signal/domain/signal_view.dart';
import 'package:onmyway/features/signal/domain/timer_model.dart';

SignalView view({
  String infoLevel = 'fresh',
  String verification = 'confirmed',
  String button = 'none',
  Map<String, dynamic>? aggregate = const {'C': 120, 'G': 30, 'phase': 4.8},
  Map<String, dynamic>? mine,
  String displaySource = 'aggregate',
  bool replaced = false,
  String? alias,
  int recordCount = 5,
}) =>
    SignalView.fromJson({
      'crosswalkId': 'A',
      'groupId': 'G1',
      'sharedName': '역삼역 3번 출구 앞 · 북쪽 횡단보도',
      'alias': alias,
      'endA': [127.0, 37.5],
      'endB': [127.0002, 37.5],
      'serverTime': 1000.0,
      'slot': {'dayType': 'weekday', 'hour': 8},
      'buttonType': button,
      'infoLevel': infoLevel,
      'verification': verification,
      'recordCount': recordCount,
      'lastMatchAt': 1000.0 - 86400,
      'aggregate': aggregate,
      'mine': mine,
      'displaySource': displaySource,
      'replacedBySignalChange': replaced,
    });

const myRec = {'C': 120, 'G': 30, 'phase': 8.0, 'at': 1000.0 - 2 * 86400, 'matchesAggregate': false};

void main() {
  const now = 1000.0;

  test('대표값 표시: 검증 상태·기록 수·최신성 (FR-02-C-01·C-02)', () {
    final m = timerModelFromView(view(), now: now, inMySignals: true);
    expect(m.params!.phase, 4.8);
    expect(m.trust, '확인됨 · 5명 기록 · 마지막 확인 1일 전');
    expect(m.showSwitch, isFalse); // 내 기록 없음 (FR-02-F-02)
    expect(m.canReport, isTrue);
  });

  test('내 기록 우선 + 불일치 표시 + 스위치 (FR-02-F-01·F-02·F-03, D-057)', () {
    final m = timerModelFromView(view(mine: myRec, displaySource: 'mine'), now: now, inMySignals: true);
    expect(m.params!.phase, 8.0);
    expect(m.trust, '내 기록으로 보는 중 · 2일 전 기록 · 대표값 마지막 확인 1일 전');
    expect(m.notices.map((n) => n.title), contains('다른 사람들 기록과 달라요'));
    expect(m.showSwitch, isTrue);
    expect(m.switchOn, isFalse);
  });

  test('스위치 켬 → 대표값 (D-053)', () {
    final m = timerModelFromView(view(mine: myRec, displaySource: 'aggregate'), now: now, inMySignals: true);
    expect(m.params!.phase, 4.8);
    expect(m.switchOn, isTrue);
    expect(m.trust, startsWith('대표값으로 보는 중 · '));
  });

  test('신호 변경 자동 전환 안내 (FR-02-F-04, D-062 문구)', () {
    final m = timerModelFromView(view(mine: myRec, displaySource: 'aggregate', replaced: true), now: now, inMySignals: true);
    expect(m.notices.first.title, '신호가 바뀐 것 같아 대표값으로 보여드려요');
    expect(m.notices.first.body, '스위치를 끄면 내 기록으로 볼 수 있어요');
    expect(m.switchOn, isTrue);
  });

  test('오래됨: 숫자·바·상태 모두 숨김, 내 기록 보기에도 적용 (D-061, FR-02-F-06)', () {
    final m = timerModelFromView(view(infoLevel: 'stale', mine: myRec, displaySource: 'mine'), now: now, inMySignals: true);
    expect(m.params, isNull);
    expect(m.notices.first.title, '정보가 맞지 않을 수 있어요');
  });

  test('만료·정보 없음 (FR-02-C-04)', () {
    for (final l in ['expired', 'nodata']) {
      final m = timerModelFromView(view(infoLevel: l, aggregate: null), now: now, inMySignals: true);
      expect(m.params, isNull);
      expect(m.emptyTitle, '이 시간대 기록이 없어요');
    }
  });

  test('버튼식: 타이머·기록 진입 없음 (FR-02-C-06, D-042)', () {
    final c = timerModelFromView(view(button: 'confirmed'), now: now, inMySignals: true);
    expect(c.params, isNull);
    expect(c.emptyTitle, '버튼을 눌러야 켜지는 신호예요');
    expect(c.canRecord, isFalse);
    expect(timerModelFromView(view(button: 'unverified'), now: now, inMySignals: true).emptyTitle, '버튼식 신호일 수 있어요');
  });

  test('별칭이 있으면 별칭 먼저, 공유 이름 함께 (FR-01-D-08)', () {
    final m = timerModelFromView(view(alias: '회사 앞'), now: now, inMySignals: true);
    expect(m.title, '회사 앞');
    expect(m.subtitle, '역삼역 3번 출구 앞 · 북쪽 횡단보도');
  });

  test('가져오기는 내 신호등에 없을 때만 (FR-01-D-02·D-03)', () {
    expect(timerModelFromView(view(), now: now, inMySignals: false).canImport, isTrue);
    expect(timerModelFromView(view(), now: now, inMySignals: true).canImport, isFalse);
  });

  test('어떤 상태에서도 지시 문구 없음 (D-059·D-060)', () {
    final all = [
      view(),
      view(mine: myRec, displaySource: 'mine'),
      view(infoLevel: 'stale'),
      view(infoLevel: 'expired', aggregate: null),
      view(button: 'confirmed'),
      view(replaced: true, mine: myRec),
    ];
    for (final v in all) {
      final m = timerModelFromView(v, now: now, inMySignals: true);
      final text = [m.trust, m.emptyTitle, m.emptyBody, ...m.notices.expand((n) => [n.title, n.body])].join(' ');
      expect(text.contains('건너'), isFalse);
      expect(text.contains('기다려'), isFalse);
    }
  });
}
