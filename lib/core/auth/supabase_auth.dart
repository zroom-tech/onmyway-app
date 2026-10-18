import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import 'session.dart';

/// Supabase Auth 브라우저 로그인 (D-065). 브라우저에서 로그인 → [redirect]로 앱이 다시 열리며 세션을 받는다.
/// [redirect]는 Supabase 대시보드 Redirect URLs, AndroidManifest·Info.plist 스킴과 같아야 한다
class SupabaseAuthGateway implements AuthGateway {
  static const redirect = 'com.onmyway.onmyway://login-callback';

  /// 브라우저를 닫고 돌아온 뒤 이만큼 세션이 안 오면 취소로 본다
  static const _cancelGrace = Duration(seconds: 5);

  sb.GoTrueClient get _auth => sb.Supabase.instance.client.auth;

  Session _toSession(sb.Session s) => Session.loggedIn(s.user.id, s.user.appMetadata['provider'] as String? ?? 'google');

  @override
  Session current() {
    final s = _auth.currentSession;
    return s == null ? const Session.loggedOut() : _toSession(s);
  }

  @override
  String? get accessToken => _auth.currentSession?.accessToken;

  @override
  Stream<Session> get changes => _auth.onAuthStateChange.map((e) => e.session == null ? const Session.loggedOut() : _toSession(e.session!));

  @override
  Future<Session?> signIn(String provider) async {
    final done = Completer<Session?>();
    final sub = _auth.onAuthStateChange.listen((e) {
      if (e.event == sb.AuthChangeEvent.signedIn && e.session != null && !done.isCompleted) done.complete(_toSession(e.session!));
    });
    final lifecycle = AppLifecycleListener(
      onResume: () => Future.delayed(_cancelGrace, () {
        if (!done.isCompleted) done.complete(null);
      }),
    );
    try {
      final launched = await _auth.signInWithOAuth(
        provider == 'apple' ? sb.OAuthProvider.apple : sb.OAuthProvider.google,
        redirectTo: redirect,
        authScreenLaunchMode: sb.LaunchMode.externalApplication,
      );
      if (!launched) return null;
      return await done.future;
    } finally {
      await sub.cancel();
      lifecycle.dispose();
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();
}
