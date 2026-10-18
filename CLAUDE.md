## 프로젝트
**onmyway-app** — onmyway(직장인 출근길 서비스)의 **모바일 앱** (Flutter, iOS·Android).
서버 API와 웹은 `../onmyway-next`(Next.js)가 맡는다.

- 기획 SoT: `../onmyway-planning` — 구현 전 해당 프로젝트의 `02-planning-spec.md`(또는 `03-prd.md`)와 `06-decisions.md`를 읽는다
- 아키텍처: `../onmyway-planning/knowledge/system-architecture.md`
- 디자인: `../onmyway-planning/knowledge/design-guide.md` — **토스 디자인 시스템(TDS)은 쓰지 않는다** (D-003)

## 스택
- Flutter 3.x / Dart 3, Material 3
- 패키지명 `onmyway`, 번들 ID `com.onmyway.onmyway` (iOS·Android)
- 상태 관리·라우팅·네트워크 패키지는 **아직 정하지 않았다.** 필요해지는 시점에 결정하고 기획 레포 `06-decisions.md`에 기록한 뒤 추가한다

## 구조 (feature-first)
```
lib/
  main.dart                 진입점
  app/app.dart              MaterialApp, 테마 연결
  core/theme/
    tokens.g.dart           생성 파일 — 직접 수정 금지 (../onmyway-next 에서 생성)
    app_theme.dart          토큰 → Material 3 ThemeData
    signal_colors.dart      신호 색 ThemeExtension
  features/<기능>/           기능별 화면·로직. 예: features/home/
assets/fonts/               Pretendard (OFL)
```
- 새 기능은 `lib/features/<기능>/` 아래에 만든다. 여러 기능이 같이 쓰는 것만 `lib/core/`로 올린다

## 규칙
- 색·글자 크기·간격·모서리는 **토큰만** 쓴다: `Theme.of(context).colorScheme`·`textTheme`, `TokenSpace`, `TokenRadius`. 임의 `Color(0x...)` 금지
- 신호 색은 `Theme.of(context).extension<SignalColors>()!`로 쓴다. **신호 표현에만** 쓰고, 신호 상태는 색 + 텍스트 + 형태로 표현한다
- 잔여시간 숫자는 `AppTheme.countdown`(고정폭 숫자)
- 토큰 변경: `../onmyway-next/design-tokens/tokens.json` 수정 → `cd ../onmyway-next && npm run tokens` → 생성된 `tokens.g.dart`를 이 저장소에 커밋
- UI 문구는 해요체·능동형·긍정형, 다이얼로그 왼쪽 버튼은 `닫기` (design-guide 5장)
- 위치 권한은 앱 실행 직후가 아니라 기능을 처음 쓸 때, 이유를 먼저 설명한 뒤 요청한다 (design-guide 6장 X6)
- 터치 영역 최소 48×48, Safe Area 안에 핵심 정보·버튼
- 다크 모드는 미정(DG-02) — 라이트 테마만

## 명령어
```bash
flutter pub get
flutter run                                        # 가짜 백엔드 (서버 없이 화면 확인)
flutter run --dart-define-from-file=env/prod.json  # 실서버 + Supabase 로그인. env/example.json을 복사해 채운다
flutter analyze
flutter test
```
