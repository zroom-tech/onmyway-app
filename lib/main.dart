import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/config.dart';

Future<void> main() async {
  if (!AppConfig.useFake) {
    WidgetsFlutterBinding.ensureInitialized();
    // 로그인 유지·토큰 갱신·로그인 후 앱 복귀 주소 처리를 Supabase가 맡는다 (D-065)
    await Supabase.initialize(url: AppConfig.supabaseUrl, publishableKey: AppConfig.supabasePublishableKey);
  }
  runApp(const ProviderScope(child: OnmywayApp()));
}
