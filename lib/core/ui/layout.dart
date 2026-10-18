import 'package:flutter/material.dart';

import '../theme/tokens.g.dart';

/// `NavBar` — 상단 뒤로 가기 + 제목 (design-guide 2장·4-1). 그림자·색 바뀜 없이 흰 면
class NavBar extends StatelessWidget implements PreferredSizeWidget {
  const NavBar({super.key, this.title});
  final String? title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => AppBar(title: title == null ? null : Text(title!, maxLines: 1, overflow: TextOverflow.ellipsis));
}

/// `ScreenHeader` — 화면 상단 큰 제목 + 설명. 토스풍: 굵은 제목 하나, 설명은 회색 한 단계 아래
class ScreenHeader extends StatelessWidget {
  const ScreenHeader(this.title, {super.key, this.description});
  final String title;
  final String? description;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: TokenSpace.s6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TokenTypography.title1.copyWith(color: TokenColors.textPrimary)),
          if (description != null) ...[
            const SizedBox(height: TokenSpace.s2),
            Text(description!, style: TokenTypography.body1.copyWith(color: TokenColors.textSecondary)),
          ],
        ]),
      );
}

/// `SectionHeader` — 리스트 구획 제목
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.first = false});
  final String title;

  /// 화면 첫 구획이면 위 여백 없음
  final bool first;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(top: first ? 0 : TokenSpace.s8, bottom: TokenSpace.s3),
        child: Text(title, style: TokenTypography.title2.copyWith(color: TokenColors.textPrimary, fontWeight: FontWeight.w700)),
      );
}

/// `BottomAction` — 화면 하단에 고정한 주요 행동 영역 (design-guide 2장 "주요 행동은 하나, 하단 고정")
class BottomAction extends StatelessWidget {
  const BottomAction({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: TokenColors.bgDefault,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(TokenSpace.s5, TokenSpace.s3, TokenSpace.s5, TokenSpace.s4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (i, c) in children.indexed) ...[if (i > 0) const SizedBox(height: TokenSpace.s2), c],
              ],
            ),
          ),
        ),
      );
}

/// 화면 기본 틀: NavBar + 스크롤 본문(좌우 20) + 하단 고정 행동
class ScreenScaffold extends StatelessWidget {
  const ScreenScaffold({super.key, this.title, required this.children, this.actions = const []});
  final String? title;
  final List<Widget> children;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: NavBar(title: title),
        body: SafeArea(
          bottom: actions.isEmpty,
          child: ListView(padding: const EdgeInsets.fromLTRB(TokenSpace.s5, TokenSpace.s2, TokenSpace.s5, TokenSpace.s6), children: children),
        ),
        // 키보드가 올라오면 주요 행동도 함께 올린다 — 가려지면 입력 후 누를 버튼이 없다
        bottomNavigationBar: actions.isEmpty
            ? null
            : Padding(padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom), child: BottomAction(children: actions)),
      );
}
