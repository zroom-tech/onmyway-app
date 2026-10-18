import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'router.dart';

class OnmywayApp extends StatelessWidget {
  const OnmywayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'onmyway',
      theme: AppTheme.light(),
      routerConfig: router,
    );
  }
}
