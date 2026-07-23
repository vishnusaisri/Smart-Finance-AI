import '../utils/validation_utils.dart';

class Budget {
  final String id;
  final String userId;
  final String category;
  final double amount; // Changed from limit to amount to match Firebase rules
  final double spent;
  final BudgetPeriod period;
  final bool rollover;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Budget({
    required this.id,
    required this.userId,
    required this.category,
    required this.amount,
    this.spent = 0,
    this.period = BudgetPeriod.monthly,
    this.rollover = false,
    required this.startDate,
    this.endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  double get remaining => amount - spent;
  double get percentageUsed => amount > 0 ? (spent / amount) * 100 : 0;
  bool get isOverBudget => spent > amount;
  bool get isWarning => percentageUsed >= 75 && !isOverBudget;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'category': category,
      'amount': amount, // Changed from limit to amount to match Firebase rules
      'spent': spent,
      'period': period.name,
      'rollover': rollover,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] as String,
      userId: map['userId'] as String,
      category: map['category'] as String,
      amount: safeDouble(map['amount'] ?? map['limit']), // Support both amount and limit for backward compatibility
      spent: safeDouble(map['spent']),
      period: BudgetPeriod.values.firstWhere(
        (e) => e.name == map['period'],
        orElse: () => BudgetPeriod.monthly,
      ),
      rollover: map['rollover'] as bool? ?? false,
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: map['endDate'] != null
          ? DateTime.parse(map['endDate'] as String)
          : null,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  Budget copyWith({
    String? id,
    String? userId,
    String? category,
    double? amount,
    double? spent,
    BudgetPeriod? period,
    bool? rollover,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Budget(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      spent: spent ?? this.spent,
      period: period ?? this.period,
      rollover: rollover ?? this.rollover,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum BudgetPeriod { weekly, monthly, yearly }
