class TaskItem {
  final String id;
  String title;
  String description;
  DateTime startTime;
  DateTime endTime;
  bool isCompleted;
  String category;

  TaskItem({
    required this.id,
    required this.title,
    this.description = '',
    required this.startTime,
    required this.endTime,
    this.isCompleted = false,
    this.category = 'عام',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
      'category': category,
    };
  }

  factory TaskItem.fromMap(Map<String, dynamic> map) {
    return TaskItem(
      id: map['id'] as String,
      title: map['title'] as String,
      description: (map['description'] as String?) ?? '',
      startTime: DateTime.parse(map['startTime'] as String),
      endTime: DateTime.parse(map['endTime'] as String),
      isCompleted: (map['isCompleted'] as int) == 1,
      category: (map['category'] as String?) ?? 'عام',
    );
  }
}
