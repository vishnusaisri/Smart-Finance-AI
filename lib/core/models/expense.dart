import '../utils/validation_utils.dart';

class Expense {
  final String id;
  final String userId;
  final double amount;
  final String category;
  final String description;
  final DateTime date;
  final String? receiptUrl;
  final Map<String, dynamic>? metadata;
  final bool isImpulse;
  final DateTime createdAt;
  final DateTime updatedAt;

  Expense({
    required this.id,
    required this.userId,
    required this.amount,
    required this.category,
    this.description = '',
    required this.date,
    this.receiptUrl,
    this.metadata,
    this.isImpulse = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'category': category,
      'description': description,
      'date': date.toIso8601String(),
      'receiptUrl': receiptUrl,
      'metadata': metadata,
      'isImpulse': isImpulse,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as String,
      userId: map['userId'] as String,
      amount: safeDouble(map['amount']),
      category: map['category'] as String,
      description: map['description'] as String? ?? '',
      date: DateTime.parse(map['date'] as String),
      receiptUrl: map['receiptUrl'] as String?,
      metadata: map['metadata'] as Map<String, dynamic>?,
      isImpulse: map['isImpulse'] as bool? ?? false,
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt'] as String) 
          : null,
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt'] as String) 
          : null,
    );
  }

  Expense copyWith({
    String? id,
    String? userId,
    double? amount,
    String? category,
    String? description,
    DateTime? date,
    String? receiptUrl,
    Map<String, dynamic>? metadata,
    bool? isImpulse,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      description: description ?? this.description,
      date: date ?? this.date,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      metadata: metadata ?? this.metadata,
      isImpulse: isImpulse ?? this.isImpulse,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
