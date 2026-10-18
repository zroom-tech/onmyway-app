# onmyway-app

onmyway의 모바일 앱 (Flutter, iOS·Android).

```bash
flutter pub get
flutter run                                        # 가짜 백엔드 (서버 없이 화면 확인)
flutter run --dart-define-from-file=env/prod.json  # 실서버 + Supabase 로그인. env/example.json을 복사해 채운다
flutter test
```

- 디자인 토큰: `lib/core/theme/tokens.g.dart`는 생성 파일. `../onmyway-next`에서 `npm run tokens`로 갱신
- 개발 규칙: `CLAUDE.md`
- 기획 문서: `../onmyway-planning`
