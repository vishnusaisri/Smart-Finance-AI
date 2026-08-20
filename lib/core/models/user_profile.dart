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
    DateTime? parseDate(dynamic d) {
      if (d == null) return null;
      if (d is int) return DateTime.fromMillisecondsSinceEpoch(d);
      return DateTime.tryParse(d.toString());
    }

    final rawGoals = map['goals'];
    List<FinancialGoal> parsedGoals = [];
    if (rawGoals is List) {
      for (final g in rawGoals) {
        if (g is Map) {
          try {
            parsedGoals.add(FinancialGoal.fromMap(Map<String, dynamic>.from(g)));
          } catch (_) {}
        }
      }
    }

    return UserProfile(
      uid: map['uid']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      fullName: map['fullName']?.toString() ?? map['name']?.toString() ?? '',
      avatarUrl: map['avatarUrl']?.toString(),
      monthlyIncome: safeDouble(map['monthlyIncome']),
      currency: map['currency']?.toString() ?? 'INR',
      goals: parsedGoals,
      preferences: map['preferences'] is Map ? Map<String, dynamic>.from(map['preferences'] as Map) : {},
      name: map['name']?.toString() ?? map['fullName']?.toString() ?? '',
      savingsGoal: safeDouble(map['savingsGoal']),
      locale: map['locale']?.toString() ?? 'en_IN',
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
      budgetAlertsEnabled: map['budgetAlertsEnabled'] as bool? ?? true,
      spendingLimitAlerts: map['spendingLimitAlerts'] as bool? ?? true,
      lowBalanceAlerts: map['lowBalanceAlerts'] as bool? ?? true,
      weeklyReports: map['weeklyReports'] as bool? ?? true,
      monthlyReports: map['monthlyReports'] as bool? ?? true,
      darkMode: map['darkMode'] as bool? ?? true,
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
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

  String getCurrencySymbol() {
    switch (currency.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'INR':
        return '₹';
      case 'JPY':
        return '¥';
      case 'AUD':
        return 'A\$';
      case 'CAD':
        return 'C\$';
      default:
        return '₹';
    }
  }

  double getSavingsRate() {
    if (monthlyIncome <= 0) return 0.0;
    return (savingsGoal / monthlyIncome) * 100;
  }

  String formatCurrency(double amount) {
    final symbol = getCurrencySymbol();
    final isNegative = amount < 0;
    final formattedAmount = amount.abs().toStringAsFixed(2);
    return isNegative ? '-$symbol$formattedAmount' : '$symbol$formattedAmount';
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
    DateTime? parseDate(dynamic d) {
      if (d == null) return null;
      if (d is int) return DateTime.fromMillisecondsSinceEpoch(d);
      return DateTime.tryParse(d.toString());
    }

    return FinancialGoal(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      targetAmount: safeDouble(map['targetAmount']),
      currentAmount: safeDouble(map['currentAmount']),
      targetDate: parseDate(map['targetDate']),
      icon: map['icon']?.toString(),
    );
  }

  double get progress =>
      targetAmount > 0 ? (currentAmount / targetAmount) * 100 : 0;
}
