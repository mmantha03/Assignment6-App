class JournalEntry {
  final String id;
  final String title;
  final String text;
  final String category;
  final String notes;
  final bool completed;
  final DateTime createdAt;
  final DateTime updatedAt;

  JournalEntry({
    required this.id,
    required this.title,
    required this.text,
    required this.category,
    required this.notes,
    required this.completed,
    required this.createdAt,
    required this.updatedAt,
  });

  JournalEntry copyWith({
    String? title,
    String? text,
    String? category,
    String? notes,
    bool? completed,
    DateTime? updatedAt,
  }) {
    return JournalEntry(
      id: id,
      title: title ?? this.title,
      text: text ?? this.text,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      completed: completed ?? this.completed,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'text': text,
      'category': category,
      'notes': notes,
      'completed': completed,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    final createdAt = DateTime.parse(map['createdAt'] as String);

    return JournalEntry(
      id: map['id'] as String,
      title: (map['title'] as String?) ?? 'Scanned note',
      text: map['text'] as String,
      category: (map['category'] as String?) ?? 'General',
      notes: (map['notes'] as String?) ?? '',
      completed: (map['completed'] as bool?) ?? false,
      createdAt: createdAt,
      updatedAt: DateTime.tryParse((map['updatedAt'] as String?) ?? '') ??
          createdAt,
    );
  }
}
