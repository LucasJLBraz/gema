import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

const _taskNightlySummary = 'gema.nightly_summary';
const _taskPhotoCleanup = 'gema.photo_cleanup';
const _taskQueueProcessor = 'gema.queue_processor';

final _notifications = FlutterLocalNotificationsPlugin();

/// Called by Workmanager in a background isolate — must be a top-level function.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    switch (taskName) {
      case _taskNightlySummary:
        await _runNightlySummary();
      case _taskPhotoCleanup:
        await _runPhotoCleanup();
      case _taskQueueProcessor:
        await _runQueueProcessor();
    }
    return true;
  });
}

/// Registers all periodic background tasks. Call once from main() after init.
Future<void> registerBackgroundTasks() async {
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

  // Nightly summary: runs ~daily at midnight
  await Workmanager().registerPeriodicTask(
    _taskNightlySummary,
    _taskNightlySummary,
    frequency: const Duration(hours: 24),
    initialDelay: _durationUntilMidnight(),
    constraints: Constraints(networkType: NetworkType.notRequired),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );

  // Photo cleanup: weekly, removes photos older than 30 days from deleted meals
  await Workmanager().registerPeriodicTask(
    _taskPhotoCleanup,
    _taskPhotoCleanup,
    frequency: const Duration(days: 7),
    constraints: Constraints(networkType: NetworkType.notRequired),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );

  // Queue processor: every 15 minutes to retry failed/queued AI jobs
  await Workmanager().registerPeriodicTask(
    _taskQueueProcessor,
    _taskQueueProcessor,
    frequency: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );
}

Duration _durationUntilMidnight() {
  final now = DateTime.now();
  final midnight = DateTime(now.year, now.month, now.day + 1);
  return midnight.difference(now);
}

Future<void> _runNightlySummary() async {
  // Placeholder — full implementation would compute DailySummary from today's meals
  // and persist it to Isar. Notifications are fired here if targets were hit.
  await _maybeFireMealReminder();
}

Future<void> _runPhotoCleanup() async {
  // Placeholder — scan app documents dir for photos whose meal was deleted
  // and delete files older than 30 days.
}

Future<void> _runQueueProcessor() async {
  // Placeholder — re-enqueue any Meal records in status=queued or status=error
  // with retryCount < 3.
}

Future<void> _maybeFireMealReminder() async {
  final now = DateTime.now();
  // Remind around lunch (12:00) and dinner (19:00) ± 30 min window
  final isLunch = now.hour == 12 && now.minute < 30;
  final isDinner = now.hour == 19 && now.minute < 30;
  if (!isLunch && !isDinner) return;

  final label = isLunch ? 'Almoço' : 'Jantar';
  await _notifications.show(
    isLunch ? 1 : 2,
    'Hora do $label 📸',
    'Registre sua refeição agora — abra o GEMA.',
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'gema_meals',
        'Lembretes de refeição',
        channelDescription: 'Lembretes adaptativos para registrar refeições',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
      ),
    ),
  );
}

/// Initializes the local notifications plugin. Call from main() on app start.
Future<void> initNotifications() async {
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const settings = InitializationSettings(android: androidSettings);
  await _notifications.initialize(settings);

  // Create notification channels
  final androidPlugin = _notifications
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();
  await androidPlugin?.createNotificationChannel(
    const AndroidNotificationChannel(
      'gema_meals',
      'Lembretes de refeição',
      description: 'Lembretes adaptativos para registrar refeições',
      importance: Importance.defaultImportance,
    ),
  );
  await androidPlugin?.createNotificationChannel(
    const AndroidNotificationChannel(
      'gema_system',
      'Notificações do sistema',
      description: 'Resumos diários e alertas',
      importance: Importance.low,
    ),
  );
}
