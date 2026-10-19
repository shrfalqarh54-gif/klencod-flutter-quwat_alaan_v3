import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_item.dart';

class TaskStore {
  static const String _key = 'quwat_alaan_tasks_data';
  static SharedPreferences? _prefs;
  static List<TaskItem> _tasks = [];

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs?.getString(_key);
    if (raw != null && raw.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(raw);
        _tasks = decoded.map((e) => TaskItem.fromMap(Map<String, dynamic>.from(e))).toList();
      } catch (_) {
        _tasks = [];
      }
    }
  }

  static List<TaskItem> getAllTasks() {
    return List.unmodifiable(_tasks);
  }

  static Future<void> saveTask(TaskItem task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index >= 0) {
      _tasks[index] = task;
    } else {
      _tasks.add(task);
    }
    await _persist();
  }

  static Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    await _persist();
  }

  static Future<void> _persist() async {
    if (_prefs == null) _prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_tasks.map((t) => t.toMap()).toList());
    await _prefs?.setString(_key, data);
  }
}
