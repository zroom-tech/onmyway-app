import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'local_db.g.dart';

/// 로그인 전 기기 기록 저장소 (traffic-signal D-048, D-066). 서버로 보내지 않는다.
/// 사용자 현재 위치는 저장하지 않는다 — 횡단보도 끝점과 탭으로 잰 값만 둔다.
class LocalCrosswalks extends Table {
  TextColumn get id => text()();
  /// 끝점. 비어 있으면 위치 없는 나만 보기 신호등 (D-074). v5부터 비울 수 있다
  RealColumn get aLat => real().nullable()();
  RealColumn get aLng => real().nullable()();
  RealColumn get bLat => real().nullable()();
  RealColumn get bLng => real().nullable()();
  TextColumn get name => text()();

  /// 신호 그룹 (FR-03-D-05). v3에서 추가 — 기존 행은 자기 id
  TextColumn get groupId => text().withDefault(const Constant(''))();

  /// 전방향 동시 보행으로 묶인 그룹 (FR-03-C-03). 업로드 때 서버에 그대로 전한다. v4에서 추가
  BoolColumn get scramble => boolean().withDefault(const Constant(false))();

  /// 버튼식 표시 (FR-04-D-02, D-042). 기기 기록은 사용자 1명이라 늘 "검증 전". v4에서 추가
  BoolColumn get buttonMarked => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get crosswalkId => text().references(LocalCrosswalks, #id)();
  IntColumn get cycle => integer()();
  IntColumn get green => integer()();
  RealColumn get phase => real()();

  /// 기준 시점 (epoch 초)
  RealColumn get at => real()();
  BoolColumn get weekend => boolean()();
  IntColumn get hour => integer()();

  /// 탭 3회 원본 JSON — 로그인 후 업로드에 쓴다 (FR-08-D-02). v2에서 추가
  TextColumn get tapsJson => text().withDefault(const Constant('[]'))();
}

@DriftDatabase(tables: [LocalCrosswalks, LocalRecords])
class LocalDb extends _$LocalDb {
  LocalDb([QueryExecutor? executor]) : super(executor ?? driftDatabase(name: 'onmyway_local'));

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) await m.addColumn(localRecords, localRecords.tapsJson);
          if (from < 3) {
            await m.addColumn(localCrosswalks, localCrosswalks.groupId);
            await customStatement('UPDATE local_crosswalks SET group_id = id WHERE group_id = \'\'');
          }
          if (from < 4) {
            await m.addColumn(localCrosswalks, localCrosswalks.scramble);
            await m.addColumn(localCrosswalks, localCrosswalks.buttonMarked);
          }
          // 끝점 열 NOT NULL 해제 — SQLite는 열 제약을 못 바꿔서 표를 다시 만들고 옮긴다
          if (from < 5) await m.alterTable(TableMigration(localCrosswalks));
        },
      );
}

final localDbProvider = Provider<LocalDb>((ref) {
  final db = LocalDb();
  ref.onDispose(db.close);
  return db;
});
