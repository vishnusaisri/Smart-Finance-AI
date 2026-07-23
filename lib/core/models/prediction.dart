import '../utils/validation_utils.dart';

class FinancialPrediction {
  final String id;
  final String userId;
  final PredictionType type;
  final double predictedValue;
  final double confidence;
  final DateTime predictionDate;
  final DateTime targetDate;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  FinancialPrediction({
    required this.id,
    required this.userId,
    required this.type,
    required this.predictedValue,
    this.confidence = 0.0,
    required this.predictionDate,
    required this.targetDate,
    this.metadata,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type.name,
      'predictedValue': predictedValue,
      'confidence': confidence,
      'predictionDate': predictionDate.toIso8601String(),
      'targetDate': targetDate.toIso8601String(),
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FinancialPrediction.fromMap(Map<String, dynamic> map) {
    return FinancialPrediction(
      id: map['id'] as String,
      userId: map['userId'] as String,
      type: PredictionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => PredictionType.expense,
      ),
      predictedValue: safeDouble(map['predictedValue']),
      confidence: safeDouble(map['confidence']),
      predictionDate: DateTime.parse(map['predictionDate'] as String),
      targetDate: DateTime.parse(map['targetDate'] as String),
      metadata: map['metadata'] as Map<String, dynamic>?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
    );
  }
}

enum PredictionType {
  expense,
  savings,
  goalAchievement,
  trend,
  investment,
}
