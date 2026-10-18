import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/session.dart';
import '../../../core/config.dart';
import '../domain/record_sequence.dart';
import '../domain/signal_view.dart';
import 'fake_signal_repository.dart';

/// 서버 오류 코드 (onmyway-next `src/lib/http.ts`·서비스 오류 코드)
class ApiError implements Exception {
  const ApiError(this.code);
  final String code;
  @override
  String toString() => 'ApiError($code)';
}

class SignalsResult {
  const SignalsResult(this.serverTime, this.signals);
  final double serverTime;
  final List<SignalView> signals;
}

/// [lng, lat]
typedef LngLat = List<double>;

class RegisterOutcome {
  const RegisterOutcome.created(this.crosswalkId, {this.joinRejected = false}) : suggestions = const [];
  const RegisterOutcome.suggest(this.suggestions)
      : crosswalkId = null,
        joinRejected = false;
  final String? crosswalkId;
  final bool joinRejected;

  /// "이 횡단보도인가요?" 후보 (FR-03-B-01): (id, 공유 이름)
  final List<(String, String)> suggestions;
}

class UploadItem {
  const UploadItem(this.endA, this.endB, this.records, {required this.group, this.name, this.scramble = false, this.buttonType = false});

  /// null이면 나만 보기 신호등 — 서버에도 나만 보기로 올라간다 (D-074)
  final LngLat? endA;
  final LngLat? endB;

  /// 나만 보기 신호등 이름 (필수)
  final String? name;
  final List<List<Tap>> records;

  /// 기기 안 신호 그룹 키 — 같은 키끼리 서버에서도 같이 켜지는 횡단보도로 묶는다 (FR-03-D-05)
  final String group;
  final bool scramble;

  /// 기기에서 버튼식으로 표시함 (FR-04-D-02)
  final bool buttonType;

  Map<String, Object> toJson() => {
        'endA': ?endA,
        'endB': ?endB,
        'name': ?name,
        'records': [for (final r in records) r.map((t) => t.toJson()).toList()],
        'group': group,
        'scramble': scramble,
        'buttonType': buttonType,
      };
}

/// 로그인 사용자의 서버 기능 (traffic-signal F-01~F-08). 계약 기준: onmyway-next `src/app/api/**`
abstract interface class SignalRepository {
  Future<SignalsResult> mySignals();
  Future<SignalsResult> inBounds(double minLng, double minLat, double maxLng, double maxLat);
  Future<String> submitRecord(String crosswalkId, List<Tap> taps);
  /// [endA]·[endB]가 없으면 위치 없는 나만 보기 등록 — [name] 필수 (D-074)
  Future<RegisterOutcome> register({LngLat? endA, LngLat? endB, String? name, List<Tap>? taps, bool buttonType, bool skipSuggestion, String? joinCrosswalkId, bool scramble});

  /// 나만 보기 신호등에 위치 지정 → 공유 (FR-03-A-08). [mergeInto]: 중복 제안에서 고른 기존 횡단보도. 결과 id는 새 횡단보도
  Future<RegisterOutcome> setLocation(String crosswalkId, {required LngLat endA, required LngLat endB, bool skipSuggestion, String? joinCrosswalkId, bool scramble, String? mergeInto});
  Future<void> report(String crosswalkId, String kind);
  Future<void> importSignal(String crosswalkId);
  Future<void> removeSignal(String crosswalkId);
  Future<void> updateSignal(String crosswalkId, {String? alias, bool clearAlias, bool? showAggregate});
  Future<void> upload(List<UploadItem> items);
  Future<void> markButton(String crosswalkId);
}

class ApiSignalRepository implements SignalRepository {
  ApiSignalRepository(this._token) : _dio = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));
  final Dio _dio;
  final String? Function() _token;

  Future<Map<String, dynamic>> _call(String method, String path, {Object? data, Map<String, Object>? query}) async {
    try {
      final res = await _dio.request<Map<String, dynamic>>(
        path,
        data: data,
        queryParameters: query,
        options: Options(method: method, headers: {'Authorization': 'Bearer ${_token() ?? ''}'}),
      );
      return res.data ?? const {};
    } on DioException catch (e) {
      final body = e.response?.data;
      throw ApiError(body is Map && body['error'] is String ? body['error'] as String : 'network');
    }
  }

  SignalsResult _signals(Map<String, dynamic> j) => SignalsResult(
        (j['serverTime'] as num).toDouble(),
        [for (final s in j['signals'] as List) SignalView.fromJson(s as Map<String, dynamic>)],
      );

  @override
  Future<SignalsResult> mySignals() async => _signals(await _call('GET', '/api/signals', query: {'mine': '1'}));

  @override
  Future<SignalsResult> inBounds(double minLng, double minLat, double maxLng, double maxLat) async =>
      _signals(await _call('GET', '/api/signals', query: {'bbox': '$minLng,$minLat,$maxLng,$maxLat'}));

  @override
  Future<String> submitRecord(String crosswalkId, List<Tap> taps) async =>
      (await _call('POST', '/api/records', data: {'crosswalkId': crosswalkId, 'taps': taps.map((t) => t.toJson()).toList()}))['outcome'] as String;

  @override
  Future<RegisterOutcome> register({
    LngLat? endA,
    LngLat? endB,
    String? name,
    List<Tap>? taps,
    bool buttonType = false,
    bool skipSuggestion = false,
    String? joinCrosswalkId,
    bool scramble = false,
  }) async {
    final j = await _call('POST', '/api/crosswalks', data: {
      'endA': ?endA,
      'endB': ?endB,
      'name': ?name,
      'taps': ?taps?.map((t) => t.toJson()).toList(),
      'buttonType': buttonType,
      'skipSuggestion': skipSuggestion,
      'joinCrosswalkId': ?joinCrosswalkId,
      'scramble': scramble,
    });
    return _outcome(j);
  }

  @override
  Future<RegisterOutcome> setLocation(String crosswalkId, {required LngLat endA, required LngLat endB, bool skipSuggestion = false, String? joinCrosswalkId, bool scramble = false, String? mergeInto}) async =>
      _outcome(await _call('POST', '/api/crosswalks/$crosswalkId/location', data: {
        'endA': endA,
        'endB': endB,
        'skipSuggestion': skipSuggestion,
        'joinCrosswalkId': ?joinCrosswalkId,
        'scramble': scramble,
        'mergeInto': ?mergeInto,
      }));

  RegisterOutcome _outcome(Map<String, dynamic> j) {
    if (j['status'] == 'suggest_existing') {
      return RegisterOutcome.suggest([for (final c in j['suggestions'] as List) ((c as Map)['id'] as String, c['sharedName'] as String)]);
    }
    return RegisterOutcome.created((j['crosswalk'] as Map)['id'] as String, joinRejected: j['joinRejected'] == true);
  }

  @override
  Future<void> report(String crosswalkId, String kind) => _call('POST', '/api/reports', data: {'crosswalkId': crosswalkId, 'kind': kind});
  @override
  Future<void> importSignal(String crosswalkId) => _call('POST', '/api/my-signals', data: {'crosswalkId': crosswalkId});
  @override
  Future<void> removeSignal(String crosswalkId) => _call('DELETE', '/api/my-signals/$crosswalkId');
  @override
  Future<void> updateSignal(String crosswalkId, {String? alias, bool clearAlias = false, bool? showAggregate}) =>
      _call('PATCH', '/api/my-signals/$crosswalkId', data: {
        if (alias != null || clearAlias) 'alias': clearAlias ? null : alias,
        'showAggregate': ?showAggregate,
      });
  @override
  Future<void> upload(List<UploadItem> items) => _call('POST', '/api/uploads', data: {'items': items.map((i) => i.toJson()).toList()});
  @override
  Future<void> markButton(String crosswalkId) => _call('POST', '/api/button-marks', data: {'crosswalkId': crosswalkId});
}

final signalRepositoryProvider = Provider<SignalRepository>((ref) {
  if (AppConfig.useFake) return FakeSignalRepository();
  return ApiSignalRepository(() => ref.read(authGatewayProvider).accessToken);
});
