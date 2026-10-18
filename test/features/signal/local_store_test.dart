// 로그인 전 기기 기록이 앱을 다시 켜도 남는지 (traffic-signal D-048, D-066)
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:onmyway/features/signal/data/local_db.dart';
import 'package:onmyway/features/signal/data/local_signal_store.dart';
import 'package:onmyway/features/signal/domain/record_sequence.dart';

void main() {
  late LocalDb db;
  setUp(() => db = LocalDb(NativeDatabase.memory()));
  tearDown(() => db.close());

  ProviderContainer container() => ProviderContainer(overrides: [localDbProvider.overrideWithValue(db)]);
  const result = RecordResult.ok(cycle: 120, green: 30, t0: 1760569200.0); // 2025-10-16 08:00 KST

  test('등록 + 기록이 저장소에 남고, 새로 불러와도 그대로다', () async {
    final c1 = container();
    final store = c1.read(localSignalStoreProvider.notifier);
    await store.ready;
    final id = await store.register(const LatLng(37.5, 127.0), const LatLng(37.5001, 127.0), result);
    await store.addRecord(id, const RecordResult.ok(cycle: 120, green: 31, t0: 1760569320.0));
    c1.dispose();

    final c2 = container();
    await c2.read(localSignalStoreProvider.notifier).ready;
    final list = c2.read(localSignalStoreProvider);
    expect(list, hasLength(1));
    expect(list.first.name, '내가 기록한 횡단보도 1'); // D-067 임시 이름
    expect(list.first.records, hasLength(2));
    expect(list.first.latestIn(Slot.of(1760569320.0))!.green, 31); // 구간마다 최근 1건 (FR-02-E-01)
    c2.dispose();
  });

  test('위상 = 기준 시점 mod 주기', () async {
    final c = container();
    final store = c.read(localSignalStoreProvider.notifier);
    await store.ready;
    await store.register(const LatLng(37.5, 127.0), const LatLng(37.5001, 127.0), result);
    expect(c.read(localSignalStoreProvider).first.records.first.phase, closeTo(1760569200.0 % 120, 1e-9));
    c.dispose();
  });

  test('clear는 기기 기록을 모두 지운다 (로그아웃·업로드 거절, FR-08-B-01·D-03)', () async {
    final c = container();
    final store = c.read(localSignalStoreProvider.notifier);
    await store.ready;
    await store.register(const LatLng(37.5, 127.0), const LatLng(37.5001, 127.0), result);
    await store.clear();
    expect(c.read(localSignalStoreProvider), isEmpty);
    c.dispose();
    final c2 = container();
    await c2.read(localSignalStoreProvider.notifier).ready;
    expect(c2.read(localSignalStoreProvider), isEmpty);
    c2.dispose();
  });

  test('같이 켜지는 횡단보도로 합류하면 그룹 기록을 함께 쓴다 (FR-03-C-04, FR-03-D-05)', () async {
    final c = container();
    final store = c.read(localSignalStoreProvider.notifier);
    await store.ready;
    final a = await store.register(const LatLng(37.5, 127.0), const LatLng(37.5, 127.0002), result);
    final b = await store.register(const LatLng(37.4999, 127.0003), const LatLng(37.5001, 127.0003),
        const RecordResult.ok(cycle: 120, green: 30, t0: 1760569320.0), joinCrosswalkId: a);
    final list = c.read(localSignalStoreProvider);
    expect(list.firstWhere((x) => x.id == b).groupId, list.firstWhere((x) => x.id == a).groupId);
    // a의 타이머도 b에서 잰 최근 기록을 쓴다
    expect(store.latestForGroup(list.firstWhere((x) => x.id == a).groupId, Slot.of(1760569320.0))!.at, 1760569320.0);
    c.dispose();
  });

  test('전방향 동시 보행: 40m 안 내 횡단보도 전부 한 그룹 (FR-03-C-03)', () async {
    final c = container();
    final store = c.read(localSignalStoreProvider.notifier);
    await store.ready;
    final a = await store.register(const LatLng(37.5, 127.0), const LatLng(37.5, 127.0002), result);
    final far = await store.register(const LatLng(37.51, 127.0), const LatLng(37.51, 127.0002), result);
    final d = await store.register(const LatLng(37.4999, 127.0), const LatLng(37.5001, 127.0002), result, scramble: true);
    final list = c.read(localSignalStoreProvider);
    String g(String id) => list.firstWhere((x) => x.id == id).groupId;
    expect(g(a), g(d));
    expect(g(far), isNot(g(d)));
    c.dispose();
  });

  test('버튼식 표시: 첫 단계 등록·기존 횡단보도 표시 모두 그룹 단위로 남는다 (FR-04-D-02, D-042)', () async {
    final c = container();
    final store = c.read(localSignalStoreProvider.notifier);
    await store.ready;
    final a = await store.register(const LatLng(37.5, 127.0), const LatLng(37.5, 127.0002), null); // 첫 단계에서 버튼식
    final b = await store.register(const LatLng(37.51, 127.0), const LatLng(37.51, 127.0002), result);
    var list = c.read(localSignalStoreProvider);
    expect(list.firstWhere((x) => x.id == a).records, isEmpty);
    expect(store.groupButtonMarked(list.firstWhere((x) => x.id == a).groupId), isTrue);
    expect(store.groupButtonMarked(list.firstWhere((x) => x.id == b).groupId), isFalse);
    await store.markButton(b);
    list = c.read(localSignalStoreProvider);
    expect(list.firstWhere((x) => x.id == b).buttonMarked, isTrue);
    c.dispose();
  });

  test('전방향 동시 보행 그룹은 표시가 남아 업로드 때 전한다 (FR-03-C-03)', () async {
    final c = container();
    final store = c.read(localSignalStoreProvider.notifier);
    await store.ready;
    final a = await store.register(const LatLng(37.5, 127.0), const LatLng(37.5, 127.0002), result);
    final d = await store.register(const LatLng(37.4999, 127.0), const LatLng(37.5001, 127.0002), result, scramble: true);
    final e = await store.register(const LatLng(37.4999, 127.0003), const LatLng(37.5001, 127.0003), result, joinCrosswalkId: d);
    final list = c.read(localSignalStoreProvider);
    for (final id in [a, d, e]) {
      expect(list.firstWhere((x) => x.id == id).scramble, isTrue, reason: id);
    }
    c.dispose();
  });

  test('위치 없이 이름만으로 등록 = 나만 보기, 등록 후보가 아니다 (D-074, FR-03-A-07)', () async {
    final c = container();
    final store = c.read(localSignalStoreProvider.notifier);
    await store.ready;
    final id = await store.register(null, null, result, name: '회사 앞 사거리');
    final cw = c.read(localSignalStoreProvider).single;
    expect(cw.id, id);
    expect(cw.name, '회사 앞 사거리');
    expect(cw.located, isFalse);
    expect(cw.toCandidate(), isNull);
    expect(cw.records, hasLength(1));
    c.dispose();
  });

  test('나만 보기에 위치를 지정하면 기록은 그대로, 위치가 생긴다 (FR-03-A-08)', () async {
    final c = container();
    final store = c.read(localSignalStoreProvider.notifier);
    await store.ready;
    final id = await store.register(null, null, result, name: '집 앞');
    final out = await store.setLocation(id, const LatLng(37.5, 127.0), const LatLng(37.5, 127.0002));
    final cw = c.read(localSignalStoreProvider).single;
    expect(out, id);
    expect(cw.located, isTrue);
    expect(cw.name, '집 앞');
    expect(cw.records, hasLength(1));
    c.dispose();
  });

  test('위치 지정 중 기존 횡단보도를 고르면 기록을 옮기고 나만 보기는 지운다 (F-03 E-11)', () async {
    final c = container();
    final store = c.read(localSignalStoreProvider.notifier);
    await store.ready;
    final shared = await store.register(const LatLng(37.5, 127.0), const LatLng(37.5, 127.0002), result);
    final mine = await store.register(null, null, const RecordResult.ok(cycle: 120, green: 30, t0: 1760569320.0), name: '집 앞');
    final out = await store.setLocation(mine, const LatLng(37.5, 127.0), const LatLng(37.5, 127.0002), mergeInto: shared);
    final list = c.read(localSignalStoreProvider);
    expect(out, shared);
    expect(list.map((x) => x.id), [shared]);
    expect(list.single.records, hasLength(2));
    c.dispose();
  });

  test('위치 있는 신호등과 나만 보기가 함께 저장되고 다시 불러와진다', () async {
    final c = container();
    final store = c.read(localSignalStoreProvider.notifier);
    await store.ready;
    await store.register(const LatLng(37.5, 127.0), const LatLng(37.5, 127.0002), result);
    await store.register(null, null, result, name: '이름');
    final c2 = container();
    await c2.read(localSignalStoreProvider.notifier).ready;
    expect(c2.read(localSignalStoreProvider).map((x) => x.located), [true, false]);
    c.dispose();
    c2.dispose();
  });
}
