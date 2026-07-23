class AIInsight {
  final String id;
  final String userId;
  final String title;
  final String description;
  final InsightType type;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime timestamp;
  final DateTime createdAt;

  AIInsight({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    this.type = InsightType.info,
    this.data,
    this.isRead = false,
    required this.timestamp,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'type': type.name,
      'data': data,
      'isRead': isRead,
      'timestamp': timestamp.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AIInsight.fromMap(Map<String, dynamic> map) {
    return AIInsight(
      id: map['id'] as String,
      userId: map['userId'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      type: InsightType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => InsightType.info,
      ),
      data: map['data'] as Map<String, dynamic>?,
      isRead: map['isRead'] as bool? ?? false,
      timestamp: DateTime.parse(map['timestamp'] as String),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
    );
  }

  AIInsight copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    InsightType? type,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? timestamp,
    DateTime? createdAt,
  }) {
    return AIInsight(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      timestamp: timestamp ?? this.timestamp,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum InsightType { info, success, warning, danger, alert, tip, opportunity }
