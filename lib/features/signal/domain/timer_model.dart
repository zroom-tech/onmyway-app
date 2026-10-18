/// 타이머 화면에 무엇을 보여줄지 정하는 규칙 (traffic-signal F-02). 화면과 분리해 테스트한다.
/// 문구는 PRD §정책성 문구. 건너라·기다리라는 지시를 쓰지 않는다 (D-059·D-060).
library;

import 'signal_view.dart';

class Notice {
  const Notice(this.title, this.body);
  final String title;
  final String body;
}

class TimerModel {
  const TimerModel({
    required this.title,
    required this.subtitle,
    required this.params,
    required this.trust,
    required this.notices,
    required this.emptyTitle,
    required this.emptyBody,
    required this.showSwitch,
    required this.switchOn,
    required this.canRecord,
    required this.canReport,
    required this.canImport,
    required this.inMySignals,
  });

  final String title;
  final String? subtitle;

  /// null이면 숫자·바·신호 상태를 모두 숨긴다
  final SignalParams? params;
  final String trust;
  final List<Notice> notices;
  final String emptyTitle;
  final String emptyBody;
  final bool showSwitch;
  final bool switchOn;
  final bool canRecord;
  final bool canReport;
  final bool canImport;
  final bool inMySignals;
}

String daysAgo(double at, double now) {
  final d = ((now - at) / 86400).floor();
  return d <= 0 ? '오늘' : '$d일 전';
}

/// 로그인 사용자 — 서버 신호 정보 (FR-02-A~F)
TimerModel timerModelFromView(SignalView v, {required double now, required bool inMySignals}) {
  final title = v.displayName;
  // 나만 보기는 공유 이름이 없다 (D-074)
  final subtitle = v.isPrivate ? '나만 보기' : (v.alias == null ? null : v.sharedName);
  final hasMine = v.mine != null;
  final showingMine = hasMine && v.displaySource == 'mine';
  final freshness = v.lastMatchAt == null ? '' : '마지막 확인 ${daysAgo(v.lastMatchAt!, now)}';
  final verification = v.verification == 'confirmed' ? '확인됨 · ${v.recordCount}명 기록' : '검증 전 · ${v.recordCount}명 기록';

  final notices = <Notice>[];
  SignalParams? params;
  var emptyTitle = '';
  var emptyBody = '';
  var canRecord = true;

  if (v.buttonType != 'none') {
    // FR-02-C-06, D-042
    emptyTitle = v.buttonType == 'confirmed' ? '버튼을 눌러야 켜지는 신호예요' : '버튼식 신호일 수 있어요';
    canRecord = v.buttonType != 'confirmed';
  } else if (v.infoLevel == 'expired' || v.infoLevel == 'nodata') {
    emptyTitle = '이 시간대 기록이 없어요';
    emptyBody = v.isPrivate ? '' : '기록을 남기면 다른 사람도 볼 수 있어요'; // 나만 보기는 공유되지 않는다
  } else if (v.infoLevel == 'stale') {
    // 오래됨: 상태도 숨김 (D-061), 내 기록 보기에도 같이 (FR-02-F-06)
    notices.add(const Notice('정보가 맞지 않을 수 있어요', '시간이 다르다는 알림이 있었어요. 신호를 직접 확인해 주세요'));
  } else {
    params = showingMine ? v.mine : v.aggregate;
  }

  if (v.replacedBySignalChange && hasMine && !showingMine) {
    notices.insert(0, const Notice('신호가 바뀐 것 같아 대표값으로 보여드려요', '스위치를 끄면 내 기록으로 볼 수 있어요'));
  }
  if (showingMine && v.verification == 'confirmed' && !v.mine!.matchesAggregate) {
    notices.add(const Notice('다른 사람들 기록과 달라요', '대표값으로 바꿔 볼 수 있어요')); // FR-02-F-03, D-062
  }

  final trust = v.isPrivate
      ? '내 기록 · 나만 보기${hasMine ? ' · ${daysAgo(v.mine!.at, now)} 기록' : ''}' // 집계 = 내 기록뿐 (FR-03-A-07)
      : showingMine
      ? '내 기록으로 보는 중 · ${daysAgo(v.mine!.at, now)} 기록${freshness.isEmpty ? '' : ' · 대표값 $freshness'}' // D-057
      : [if (hasMine) '대표값으로 보는 중', verification, if (freshness.isNotEmpty) freshness].join(' · ');

  return TimerModel(
    title: title,
    subtitle: subtitle,
    params: params,
    trust: trust,
    notices: notices,
    emptyTitle: emptyTitle,
    emptyBody: emptyBody,
    showSwitch: hasMine && !v.isPrivate, // 현재 구간에 내 기록이 있을 때만 (FR-02-F-02). 나만 보기는 대표값이 곧 내 기록
    switchOn: hasMine && !showingMine,
    canRecord: canRecord,
    canReport: !v.isPrivate, // 나만 보기는 신고 대상이 아니다 (D-074)
    canImport: !inMySignals && !v.isPrivate,
    inMySignals: inMySignals,
  );
}
