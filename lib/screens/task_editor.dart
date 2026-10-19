import 'package:flutter/material.dart';
import '../models/task_item.dart';
import '../services/task_store.dart';
import '../services/notification_service.dart';

class TaskEditorScreen extends StatefulWidget {
  final TaskItem? task;

  const TaskEditorScreen({super.key, this.task});

  @override
  State<TaskEditorScreen> createState() => _TaskEditorScreenState();
}

class _TaskEditorScreenState extends State<TaskEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late DateTime _startTime;
  late DateTime _endTime;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descController = TextEditingController(text: widget.task?.description ?? '');
    _startTime = widget.task?.startTime ?? now.add(const Duration(minutes: 5));
    _endTime = widget.task?.endTime ?? now.add(const Duration(hours: 1));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickTime(bool isStart) async {
    final initial = isStart ? _startTime : _endTime;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time != null) {
      setState(() {
        final now = DateTime.now();
        final selected = DateTime(now.year, now.month, now.day, time.hour, time.minute);
        if (isStart) {
          _startTime = selected;
          if (_endTime.isBefore(_startTime)) {
            _endTime = _startTime.add(const Duration(hours: 1));
          }
        } else {
          _endTime = selected;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final item = TaskItem(
      id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      startTime: _startTime,
      endTime: _endTime,
      isCompleted: widget.task?.isCompleted ?? false,
    );

    await TaskStore.saveTask(item);
    await NotificationService.scheduleTaskNotification(item);

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'إضافة مهمة جديدة' : 'تعديل المهمة'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'عنوان المهمة',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'يرجى كتابة العنوان' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'تفاصيل إضافية (اختياري)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                title: const Text('وقت البدء'),
                subtitle: Text('${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}'),
                trailing: const Icon(Icons.access_time),
                onTap: () => _pickTime(true),
              ),
              ListTile(
                title: const Text('وقت الانتهاء'),
                subtitle: Text('${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}'),
                trailing: const Icon(Icons.access_time_filled),
                onTap: () => _pickTime(false),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('حفظ المهمة', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
