/// 빌드 설정. `--dart-define`(또는 `--dart-define-from-file=env/prod.json`)으로 바꾼다.
///   BACKEND=fake  서버 없이 화면을 확인하는 개발용 가짜 백엔드 (기본)
///   BACKEND=api   onmyway-next API + Supabase 로그인
abstract final class AppConfig {
  static const backend = String.fromEnvironment('BACKEND', defaultValue: 'fake');
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:3000');
  static bool get useFake => backend == 'fake';

  /// Supabase Auth (D-065). 공개 키(publishable)만 넣는다 — 서비스 키는 서버 전용
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabasePublishableKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  /// Apple 로그인은 Supabase 공급자 설정 후 켠다
  static const appleLogin = bool.fromEnvironment('APPLE_LOGIN');
}
