import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/background/background_tasks.dart';
import 'core/db/database.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/meals/services/queue_processor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDatabase();
  await initializeDateFormatting('pt_BR');
  await initNotifications();
  await registerBackgroundTasks();
  QueueProcessor.instance.start();
  runApp(const ProviderScope(child: GemaApp()));
}

class GemaApp extends ConsumerWidget {
  const GemaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'gema',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(dark: false),
      darkTheme: buildTheme(dark: true),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
