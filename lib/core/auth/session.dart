import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config.dart';
import 'supabase_auth.dart';

/// 로그인 상태 (traffic-signal D-041·D-047). 로그인 전에는 서버와 통신하지 않는다.
class Session {
  const Session._(this.userId, this.provider);
  const Session.loggedOut() : this._(null, null);
  const Session.loggedIn(String userId, String provider) : this._(userId, provider);

  final String? userId;

  /// google | apple
  final String? provider;
  bool get loggedIn => userId != null;
}

/// 로그인 수단. 실제 구현은 Supabase Auth (D-065)
abstract interface class AuthGateway {
  /// 앱을 다시 켰을 때 남아 있는 로그인
  Session current();

  /// 서버 호출용. 만료 전에 알아서 갱신된 값을 준다
  String? get accessToken;

  /// 다른 경로로 로그인이 바뀔 때 (토큰 갱신 실패로 로그아웃 등)
  Stream<Session> get changes;

  /// null = 사용자가 취소함
  Future<Session?> signIn(String provider);
  Future<void> signOut();
}

/// 개발용: 서버 없이 로그인 이후 화면을 확인한다
class FakeAuthGateway implements AuthGateway {
  bool _in = false;
  @override
  Session current() => const Session.loggedOut();
  @override
  String? get accessToken => _in ? 'dev-token' : null;
  @override
  Stream<Session> get changes => const Stream.empty();
  @override
  Future<Session?> signIn(String provider) async {
    _in = true;
    return Session.loggedIn('dev-user', provider);
  }

  @override
  Future<void> signOut() async => _in = false;
}

final authGatewayProvider = Provider<AuthGateway>((_) => AppConfig.useFake ? FakeAuthGateway() : SupabaseAuthGateway());

class SessionNotifier extends Notifier<Session> {
  @override
  Session build() {
    final gateway = ref.watch(authGatewayProvider);
    final sub = gateway.changes.listen((s) => state = s);
    ref.onDispose(sub.cancel);
    return gateway.current();
  }

  Future<bool> signIn(String provider) async {
    final s = await ref.read(authGatewayProvider).signIn(provider);
    if (s == null) return false; // 로그인 취소 → 원래 화면 (F-08 E-03)
    state = s;
    return true;
  }

  Future<void> signOut() async {
    await ref.read(authGatewayProvider).signOut();
    state = const Session.loggedOut();
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, Session>(SessionNotifier.new);
