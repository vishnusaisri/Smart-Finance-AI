double safeDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is int) {
    return value.toDouble();
  }
  if (value is double) {
    return value;
  }
  return double.tryParse(value.toString()) ?? 0.0;
}

class UserProfile {
  final String uid;
  final String email;
  final String fullName;
  final String? avatarUrl;
  final double monthlyIncome;
  final String currency;
  final List<FinancialGoal> goals;
  final Map<String, dynamic> preferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Added for compatibility with UI forms/settings:
  final String name;
  final double savingsGoal;
  final String locale;
  final bool notificationsEnabled;
  final bool budgetAlertsEnabled;
  final bool spendingLimitAlerts;
  final bool lowBalanceAlerts;
  final bool weeklyReports;
  final bool monthlyReports;
  final bool darkMode;

  UserProfile({
    required this.uid,
    required this.email,
    required this.fullName,
    this.avatarUrl,
    this.monthlyIncome = 0,
    this.currency = 'INR',
    this.goals = const [],
    this.preferences = const {},
    String? name,
    this.savingsGoal = 0,
    this.locale = 'en_IN',
    this.notificationsEnabled = true,
    this.budgetAlertsEnabled = true,
    this.spendingLimitAlerts = true,
    this.lowBalanceAlerts = true,
    this.weeklyReports = true,
    this.monthlyReports = true,
    this.darkMode = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : name = name ?? fullName,
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'avatarUrl': avatarUrl,
      'monthlyIncome': monthlyIncome,
      'currency': currency,
      'goals': goals.map((g) => g.toMap()).toList(),
      'preferences': preferences,
      'name': name,
      'savingsGoal': savingsGoal,
      'locale': locale,
      'notificationsEnabled': notificationsEnabled,
      'budgetAlertsEnabled': budgetAlertsEnabled,
      'spendingLimitAlerts': spendingLimitAlerts,
      'lowBalanceAlerts': lowBalanceAlerts,
      'weeklyReports': weeklyReports,
      'monthlyReports': monthlyReports,
      'darkMode': darkMode,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] as String? ?? '',
      email: map['email'] as String? ?? '',
      fullName: map['fullName'] as String? ?? map['name'] as String? ?? '',
      avatarUrl: map['avatarUrl'] as String?,
      monthlyIncome: safeDouble(map['monthlyIncome']),
      currency: map['currency'] as String? ?? 'INR',
      goals: map['goals'] != null
          ? (map['goals'] as List)
              .map((g) => FinancialGoal.fromMap(Map<String, dynamic>.from(g as Map)))
              .toList()
          : [],
      preferences: map['preferences'] != null ? Map<String, dynamic>.from(map['preferences'] as Map) : {},
      name: map['name'] as String? ?? map['fullName'] as String? ?? '',
      savingsGoal: safeDouble(map['savingsGoal']),
      locale: map['locale'] as String? ?? 'en_IN',
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
      budgetAlertsEnabled: map['budgetAlertsEnabled'] as bool? ?? true,
      spendingLimitAlerts: map['spendingLimitAlerts'] as bool? ?? true,
      lowBalanceAlerts: map['lowBalanceAlerts'] as bool? ?? true,
      weeklyReports: map['weeklyReports'] as bool? ?? true,
      monthlyReports: map['monthlyReports'] as bool? ?? true,
      darkMode: map['darkMode'] as bool? ?? true,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  UserProfile copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? avatarUrl,
    double? monthlyIncome,
    String? currency,
    List<FinancialGoal>? goals,
    Map<String, dynamic>? preferences,
    String? name,
    double? savingsGoal,
    String? locale,
    bool? notificationsEnabled,
    bool? budgetAlertsEnabled,
    bool? spendingLimitAlerts,
    bool? lowBalanceAlerts,
    bool? weeklyReports,
    bool? monthlyReports,
    bool? darkMode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      currency: currency ?? this.currency,
      goals: goals ?? this.goals,
      preferences: preferences ?? this.preferences,
      name: name ?? this.name,
      savingsGoal: savingsGoal ?? this.savingsGoal,
      locale: locale ?? this.locale,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      budgetAlertsEnabled: budgetAlertsEnabled ?? this.budgetAlertsEnabled,
      spendingLimitAlerts: spendingLimitAlerts ?? this.spendingLimitAlerts,
      lowBalanceAlerts: lowBalanceAlerts ?? this.lowBalanceAlerts,
      weeklyReports: weeklyReports ?? this.weeklyReports,
      monthlyReports: monthlyReports ?? this.monthlyReports,
      darkMode: darkMode ?? this.darkMode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class FinancialGoal {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime? targetDate;
  final String? icon;

  FinancialGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0,
    this.targetDate,
    this.icon,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'targetDate': targetDate?.toIso8601String(),
      'icon': icon,
    };
  }

  factory FinancialGoal.fromMap(Map<String, dynamic> map) {
    return FinancialGoal(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      targetAmount: safeDouble(map['targetAmount']),
      currentAmount: safeDouble(map['currentAmount']),
      targetDate: map['targetDate'] != null
          ? DateTime.parse(map['targetDate'] as String)
          : null,
      icon: map['icon'] as String?,
    );
  }

  double get progress =>
      targetAmount > 0 ? (currentAmount / targetAmount) * 100 : 0;
}
