// 기기 DB v4 → v5 (끝점 NOT NULL 해제, traffic-signal D-074). 실제 v4 표를 만들어 두고 열어서 옮겨지는지 본다
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onmyway/features/signal/data/local_db.dart';

void main() {
  test('v4 기록이 남고, v5에서는 끝점 없이 저장할 수 있다', () async {
    final db = LocalDb(NativeDatabase.memory(setup: (raw) {
      raw.execute('''
        CREATE TABLE local_crosswalks (
          id TEXT NOT NULL PRIMARY KEY,
          a_lat REAL NOT NULL, a_lng REAL NOT NULL, b_lat REAL NOT NULL, b_lng REAL NOT NULL,
          name TEXT NOT NULL,
          group_id TEXT NOT NULL DEFAULT '',
          created_at INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
          scramble INTEGER NOT NULL DEFAULT 0 CHECK (scramble IN (0, 1)),
          button_marked INTEGER NOT NULL DEFAULT 0 CHECK (button_marked IN (0, 1))
        )''');
      raw.execute('''
        CREATE TABLE local_records (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          crosswalk_id TEXT NOT NULL REFERENCES local_crosswalks (id),
          cycle INTEGER NOT NULL, green INTEGER NOT NULL, phase REAL NOT NULL, at REAL NOT NULL,
          weekend INTEGER NOT NULL CHECK (weekend IN (0, 1)), hour INTEGER NOT NULL,
          taps_json TEXT NOT NULL DEFAULT '[]'
        )''');
      raw.execute("INSERT INTO local_crosswalks (id, a_lat, a_lng, b_lat, b_lng, name, group_id) VALUES ('c1', 37.5, 127.0, 37.5, 127.0002, '내가 기록한 횡단보도 1', 'c1')");
      raw.execute("INSERT INTO local_records (crosswalk_id, cycle, green, phase, at, weekend, hour) VALUES ('c1', 120, 30, 4.8, 1760569200.0, 0, 8)");
      raw.execute('PRAGMA user_version = 4');
    }));

    final cws = await db.select(db.localCrosswalks).get();
    expect(cws.single.aLat, 37.5);
    expect(cws.single.groupId, 'c1');
    expect(await db.select(db.localRecords).get(), hasLength(1));

    await db.into(db.localCrosswalks).insert(LocalCrosswalksCompanion.insert(id: 'p1', name: '회사 앞'));
    expect((await db.select(db.localCrosswalks).get()).firstWhere((c) => c.id == 'p1').aLat, isNull);
    await db.close();
  });
}
