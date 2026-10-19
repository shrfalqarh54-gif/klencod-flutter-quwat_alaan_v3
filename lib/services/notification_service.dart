import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/task_item.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> scheduleTaskNotification(TaskItem task) async {
    if (task.startTime.isBefore(DateTime.now())) return;

    final androidDetails = const AndroidNotificationDetails(
      'task_channel_id',
      'تنبيهات المهام',
      channelDescription: 'قناة إشعارات بدء وانتهاء المهام',
      importance: Importance.max,
      priority: Priority.high,
    );

    final details = NotificationDetails(android: androidDetails);

    try {
      await _notificationsPlugin.zonedSchedule(
        task.id.hashCode,
        'حان موعد المهمة 💪',
        task.title,
        tz.TZDateTime.from(task.startTime, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {}
  }

  static Future<void> cancelNotification(String taskId) async {
    await _notificationsPlugin.cancel(taskId.hashCode);
  }
}
