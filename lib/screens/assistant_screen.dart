import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models/task_item.dart';
import '../services/task_store.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      'role': 'assistant',
      'text': 'أهلاً بك في "قوة الآن" 💪. أنا مساعدك المحلي. اسألني عن جدولك اليوم أو ماذا تفعل الآن!'
    }
  ];

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _controller.clear();
    });

    _processAssistantResponse(text);
  }

  void _processAssistantResponse(String query) {
    final tasks = TaskStore.getAllTasks();
    final now = DateTime.now();
    String response = '';

    final lower = query.toLowerCase();

    if (lower.contains('مرحبا') || lower.contains('السلام') || lower.contains('أهلا') || lower.contains('اهلا')) {
      response = 'أهلاً وسهلاً بك! كيف يمكنني مساعدتك في إدارة وقتك اليوم؟';
    } else if (lower.contains('الآن') || lower.contains('افعل') || lower.contains('سوي')) {
      try {
        final active = tasks.firstWhere(
          (t) => !t.isCompleted && t.startTime.isBefore(now) && t.endTime.isAfter(now),
        );
        response = 'مهمتك الحالية هي: "${active.title}". تنتهي في تمام الساعة ${_formatTime(active.endTime)}. ركز وأنجزها!';
      } catch (_) {
        response = 'ليس لديك مهمة جارية في هذه اللحظة. يمكنك أخذ استراحة أو مراجعة جدولك القادم.';
      }
    } else if (lower.contains('القادمة') || lower.contains('بعد') || lower.contains('الجاي')) {
      final upcoming = tasks.where((t) => !t.isCompleted && t.startTime.isAfter(now)).toList();
      upcoming.sort((a, b) => a.startTime.compareTo(b.startTime));
      if (upcoming.isNotEmpty) {
        response = 'مهمتك القادمة هي "${upcoming.first.title}" وتبدأ في الساعة ${_formatTime(upcoming.first.startTime)}.';
      } else {
        response = 'لا توجد مهام قادمة مجدولة لباقي اليوم.';
      }
    } else if (lower.contains('كم') || lower.contains('عدد') || lower.contains('مهام') || lower.contains('اليوم')) {
      final completed = tasks.where((t) => t.isCompleted).length;
      response = 'إجمالي المهام المسجلة: ${tasks.length} مهام.\nتم إنجاز: $completed منها.';
    } else {
      response = 'يمكنني إخبارك بما يجب فعله الآن، أو ما هي مهمتك القادمة، أو عدد المهام المتبقية. جرب أن تسأل: "ماذا أفعل الآن؟"';
    }

    setState(() {
      _messages.add({'role': 'assistant', 'text': response});
    });
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المساعد الذكي (محلي)'),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg['role'] == 'user';
                  return Align(
                    alignment: isUser ? Alignment.centerLeft : Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isUser ? const Color(0xFF2E7D32) : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        msg['text']!,
                        style: TextStyle(
                          color: isUser ? Colors.white : Colors.black87,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'اكتب سؤالك هنا...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onSubmitted: (_) => _handleSend(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFF2E7D32)),
                    onPressed: _handleSend,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
