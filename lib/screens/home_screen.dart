import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models/task_item.dart';
import '../services/task_store.dart';
import 'assistant_screen.dart';
import 'task_editor.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<TaskItem> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    setState(() {
      _tasks = TaskStore.getAllTasks();
      _isLoading = false;
    });
  }

  TaskItem? get _currentActiveTask {
    final now = DateTime.now();
    try {
      return _tasks.firstWhere(
        (task) => !task.isCompleted && task.startTime.isBefore(now) && task.endTime.isAfter(now),
      );
    } catch (_) {
      return null;
    }
  }

  TaskItem? get _upcomingTask {
    final now = DateTime.now();
    try {
      final upcoming = _tasks.where(
        (task) => !task.isCompleted && task.startTime.isAfter(now),
      ).toList();
      upcoming.sort((a, b) => a.startTime.compareTo(b.startTime));
      return upcoming.isNotEmpty ? upcoming.first : null;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('قوة الآن 💪'),
          actions: [
            IconButton(
              icon: const Icon(Icons.smart_toy_outlined),
              tooltip: 'المساعد',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AssistantScreen()),
                ).then((_) => _loadTasks());
              },
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () async => _loadTasks(),
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    _buildNowSection(),
                    const SizedBox(height: 16),
                    _buildUpcomingSection(),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'مهام اليوم (${_tasks.length})',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'المكتملة: ${_tasks.where((t) => t.isCompleted).length}',
                          style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(),
                    if (_tasks.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40.0),
                          child: Text(
                            'لا توجد مهام حالياً. ابدأ بإضافة مهمتك الأولى!',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ),
                      )
                    else
                      ..._tasks.map((task) => _buildTaskCard(task)),
                  ],
                ),
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TaskEditorScreen()),
            );
            if (result == true) _loadTasks();
          },
          label: const Text('إضافة مهمة'),
          icon: const Icon(Icons.add),
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildNowSection() {
    final active = _currentActiveTask;
    return Card(
      color: active != null ? const Color(0xFFE8F5E9) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: active != null ? Colors.green : Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bolt, color: active != null ? Colors.amber.shade800 : Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'ماذا أفعل الآن؟',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (active != null) ...[
              Text(
                active.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
              ),
              const SizedBox(height: 4),
              Text(
                'الانتهاء: ${_formatTime(active.endTime)}',
                style: const TextStyle(color: Colors.black87),
              ),
            ] else ...[
              const Text(
                'أنت متفرغ الآن! استغل هذا الوقت في التخطيط أو الراحة.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingSection() {
    final upcoming = _upcomingTask;
    if (upcoming == null) return const SizedBox.shrink();
    return Card(
      child: ListTile(
        leading: const Icon(Icons.access_time, color: Colors.blue),
        title: Text('المهمة القادمة: ${upcoming.title}'),
        subtitle: Text('البدء: ${_formatTime(upcoming.startTime)}'),
      ),
    );
  }

  Widget _buildTaskCard(TaskItem task) {
    return Card(
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          activeColor: const Color(0xFF2E7D32),
          onChanged: (val) async {
            task.isCompleted = val ?? false;
            await TaskStore.saveTask(task);
            _loadTasks();
          },
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text('${_formatTime(task.startTime)} - ${_formatTime(task.endTime)}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () async {
            await TaskStore.deleteTask(task.id);
            _loadTasks();
          },
        ),
        onTap: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TaskEditorScreen(task: task)),
          );
          if (res == true) _loadTasks();
        },
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
