import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:async';
import '../models/ai_insight.dart';
import '../../features/profile/providers/profile_providers.dart';
import '../../features/expense/controllers/expense_controller.dart';
import '../../features/ai_assistant/services/ai_intent_analyzer.dart';

// Gemini API Key provider
final geminiApiKeyProvider = Provider<String>((ref) {
  return ''; // API disabled - using local AI engine
});

// Gemini Service Provider
final geminiServiceProvider = Provider<GeminiService>((ref) {
  final apiKey = ref.watch(geminiApiKeyProvider);
  return GeminiService(apiKey: apiKey);
});

// AI Coaching Provider - Generates coaching insights with retry and caching
final aiCoachingProvider = FutureProvider<List<AIInsight>>((ref) async {
  final geminiService = ref.watch(geminiServiceProvider);
  
  // Get real user data from providers
  final userProfile = ref.watch(userProfileProvider);
  final expensesAsync = ref.watch(expensesProvider);
  
  return expensesAsync.when(
    loading: () => [],
    error: (_, __) => [],
    data: (expenses) async {
      final monthlyIncome = userProfile.monthlyIncome;
      final totalExpenses = expenses.fold<double>(0, (sum, e) => sum + e.amount);
      final savingsRate = monthlyIncome > 0 ? ((monthlyIncome - totalExpenses) / monthlyIncome) * 100 : 0.0;
      
      // Calculate category breakdown
      final categoryBreakdown = <String, double>{};
      for (final expense in expenses) {
        categoryBreakdown[expense.category] = (categoryBreakdown[expense.category] ?? 0) + expense.amount;
      }
      
      // Calculate health score
      final healthScore = _calculateHealthScore(savingsRate, totalExpenses, monthlyIncome);
      
      // Get top 3 categories
      final topCategories = categoryBreakdown.entries
        .toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final top3Categories = Map.fromEntries(topCategories.take(3));
      
      // Try to get insights with retry mechanism
      return await geminiService.generateCoachingInsightsWithRetry(
        monthlyIncome: monthlyIncome,
        expenses: expenses.map((e) => e.toMap()).toList(),
        totalExpenses: totalExpenses,
        savingsRate: savingsRate.toDouble(),
        topCategories: top3Categories,
        healthScore: healthScore,
      );
    },
  );
});

double _calculateHealthScore(double savingsRate, double totalExpenses, double monthlyIncome) {
  if (monthlyIncome == 0) return 50.0;
  
  double score = 50.0;
  
  // Savings rate contribution (up to 30 points)
  if (savingsRate >= 20) score += 30;
  else if (savingsRate >= 15) score += 25;
  else if (savingsRate >= 10) score += 20;
  else if (savingsRate >= 5) score += 10;
  else if (savingsRate < 0) score -= 10;
  
  // Expense ratio contribution (up to 20 points)
  final expenseRatio = monthlyIncome > 0 ? (totalExpenses / monthlyIncome) * 100 : 100;
  if (expenseRatio <= 70) score += 20;
  else if (expenseRatio <= 80) score += 15;
  else if (expenseRatio <= 90) score += 10;
  else if (expenseRatio > 100) score -= 10;
  
  return score.clamp(0.0, 100.0);
}

class GeminiService {
  final String apiKey;
  GenerativeModel? _model;
  bool get isMock => apiKey.isEmpty;
  
  // Cache for AI responses
  final Map<String, List<AIInsight>> _insightsCache = {};
  final Map<String, String> _summaryCache = {};
  final Map<String, String> _answerCache = {};
  
  // Rate limiting
  DateTime? _lastRequestTime;
  static const _minRequestInterval = Duration(milliseconds: 500);

  GeminiService({required this.apiKey}) {
    if (!isMock) {
      _model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
      );
    }
  }

  /// Generate AI coaching insights with retry mechanism
  Future<List<AIInsight>> generateCoachingInsightsWithRetry({
    required double monthlyIncome,
    required List<Map<String, dynamic>> expenses,
    required double totalExpenses,
    required double savingsRate,
    required Map<String, double> topCategories,
    required double healthScore,
    int maxRetries = 3,
  }) async {
    // Generate cache key
    final cacheKey = '${monthlyIncome}_${totalExpenses}_${savingsRate}_${healthScore}';
    
    // Check cache first
    if (_insightsCache.containsKey(cacheKey)) {
      final cachedTime = DateTime.now().subtract(const Duration(minutes: 5));
      // Cache is valid for 5 minutes
      if (cachedTime.isBefore(DateTime.now())) {
        return _insightsCache[cacheKey]!;
      } else {
        _insightsCache.remove(cacheKey);
      }
    }
    
    // Rate limiting
    if (_lastRequestTime != null) {
      final timeSinceLastRequest = DateTime.now().difference(_lastRequestTime!);
      if (timeSinceLastRequest < _minRequestInterval) {
        await Future.delayed(_minRequestInterval - timeSinceLastRequest);
      }
    }
    
    // Retry mechanism
    int retryCount = 0;
    while (retryCount < maxRetries) {
      try {
        _lastRequestTime = DateTime.now();
        
        final insights = await generateCoachingInsights(
          monthlyIncome: monthlyIncome,
          expenses: expenses,
          totalExpenses: totalExpenses,
          savingsRate: savingsRate,
          topCategories: topCategories,
          healthScore: healthScore,
        );
        
        // Cache successful response
        _insightsCache[cacheKey] = insights;
        return insights;
        
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) {
          // Fallback to local insights after all retries fail
          return _generateMockInsights(
            monthlyIncome: monthlyIncome,
            totalExpenses: totalExpenses,
            savingsRate: savingsRate,
            topCategories: topCategories,
            healthScore: healthScore,
          );
        }
        
        // Exponential backoff
        final delay = Duration(milliseconds: 1000 * (1 << retryCount));
        await Future.delayed(delay);
      }
    }
    
    // Should never reach here, but fallback just in case
    return _generateMockInsights(
      monthlyIncome: monthlyIncome,
      totalExpenses: totalExpenses,
      savingsRate: savingsRate,
      topCategories: topCategories,
      healthScore: healthScore,
    );
  }

  /// Generate AI coaching insights based on user's financial data
  Future<List<AIInsight>> generateCoachingInsights({
    required double monthlyIncome,
    required List<Map<String, dynamic>> expenses,
    required double totalExpenses,
    required double savingsRate,
    required Map<String, double> topCategories,
    required double healthScore,
  }) async {
    if (isMock) {
      return _generateMockInsights(
        monthlyIncome: monthlyIncome,
        totalExpenses: totalExpenses,
        savingsRate: savingsRate,
        topCategories: topCategories,
        healthScore: healthScore,
      );
    }

    try {
      final prompt = _buildCoachingPrompt(
        monthlyIncome: monthlyIncome,
        totalExpenses: totalExpenses,
        savingsRate: savingsRate,
        topCategories: topCategories,
        healthScore: healthScore,
      );

      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      final text = response.text ?? '';

      return _parseInsightsFromResponse(text);
    } catch (e, st) {
      print('Gemini generateCoachingInsights Error: $e');
      print(st);
      // Fallback to mock insights on error
      return _generateMockInsights(
        monthlyIncome: monthlyIncome,
        totalExpenses: totalExpenses,
        savingsRate: savingsRate,
        topCategories: topCategories,
        healthScore: healthScore,
      );
    }
  }

  /// Generate financial summary for dashboard
  Future<String> generateFinancialSummary({
    required double monthlyIncome,
    required double totalExpenses,
    required double savingsRate,
    required int transactionCount,
  }) async {
    if (isMock) {
      return _generateMockSummary(
        monthlyIncome: monthlyIncome,
        totalExpenses: totalExpenses,
        savingsRate: savingsRate,
        transactionCount: transactionCount,
      );
    }

    try {
      final prompt = '''
You are a financial advisor. Provide a concise 2-3 sentence summary of this user's financial health:

- Monthly Income: \$${monthlyIncome.toStringAsFixed(0)}
- Monthly Expenses: \$${totalExpenses.toStringAsFixed(0)}
- Savings Rate: ${savingsRate.toStringAsFixed(1)}%
- Transactions: $transactionCount

Keep it encouraging, specific, and actionable.
''';

      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      return response.text ?? _generateMockSummary(
        monthlyIncome: monthlyIncome,
        totalExpenses: totalExpenses,
        savingsRate: savingsRate,
        transactionCount: transactionCount,
      );
    } catch (e, st) {
      print('Gemini generateFinancialSummary Error: $e');
      print(st);
      return _generateMockSummary(
        monthlyIncome: monthlyIncome,
        totalExpenses: totalExpenses,
        savingsRate: savingsRate,
        transactionCount: transactionCount,
      );
    }
  }

  /// Answer financial questions (chatbot)
  Future<String> answerFinancialQuestion({
    required String question,
    required Map<String, dynamic> userContext,
  }) async {
    if (isMock) {
      return _generateMockAnswer(question);
    }

    try {
      final prompt = '''
You are an expert, empathetic financial advisor AI assistant for the Smart Finance app.
Your goal is to provide highly personalized, conversational, and actionable financial advice based on the user's live data.

USER'S CURRENT FINANCIAL DATA:
- Monthly Income: \$${userContext['monthlyIncome']}
- Total Monthly Expenses: \$${userContext['totalExpenses']}
- Savings Rate: ${userContext['savingsRate'].toStringAsFixed(1)}%
- Top Spending Category: ${userContext['topCategory']}
- Financial Health Score: ${userContext['healthScore']}/100

USER QUESTION: $question

INSTRUCTIONS:
1. Speak in a friendly, conversational, and professional tone (like a real human advisor).
2. Directly reference their actual financial data in your answer to make it highly personalized.
3. Keep your response concise (3-4 sentences max). Use bullet points if listing multiple items.
4. Always provide one clear, actionable recommendation they can apply today.
''';

      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      return response.text ?? _generateMockAnswer(question);
    } catch (e, st) {
      print('Gemini answerFinancialQuestion Error: $e');
      print(st);
      return 'Error connecting to AI: $e\n\nPlease check your API key and internet connection.';
    }
  }

  /// Answer budget specific questions
  Future<String> answerBudgetQuestion({
    required String question,
    required Map<String, dynamic> userContext,
  }) async {
    final specializedContext = Map<String, dynamic>.from(userContext);
    specializedContext['focus'] = 'Budget optimization, category limits, and spending leaks';
    return answerFinancialQuestion(question: question, userContext: specializedContext);
  }

  /// Answer savings specific questions
  Future<String> answerSavingsQuestion({
    required String question,
    required Map<String, dynamic> userContext,
  }) async {
    final specializedContext = Map<String, dynamic>.from(userContext);
    specializedContext['focus'] = 'Savings rate improvement, emergency funds, and automated goal setting';
    return answerFinancialQuestion(question: question, userContext: specializedContext);
  }

  /// Answer investment specific questions
  Future<String> answerInvestmentQuestion({
    required String question,
    required Map<String, dynamic> userContext,
  }) async {
    final specializedContext = Map<String, dynamic>.from(userContext);
    specializedContext['focus'] = 'Asset allocation, compound interest, index funds, and risk management';
    return answerFinancialQuestion(question: question, userContext: specializedContext);
  }

  /// Build coaching prompt for Gemini
  String _buildCoachingPrompt({
    required double monthlyIncome,
    required double totalExpenses,
    required double savingsRate,
    required Map<String, double> topCategories,
    required double healthScore,
  }) {
    final top3Categories = topCategories.entries
        .toList()
        ..sort((a, b) => b.value.compareTo(a.value));
    final top3Text = top3Categories.take(3).map((e) => '- ${e.key}: \$${e.value.toStringAsFixed(0)}').join('\n');

    return '''
You are an expert financial coach analyzing a user's spending behavior. Based on the data below, generate exactly 5 actionable insights.

FINANCIAL DATA:
- Monthly Income: \$${monthlyIncome.toStringAsFixed(0)}
- Total Monthly Expenses: \$${totalExpenses.toStringAsFixed(0)}
- Savings Rate: ${savingsRate.toStringAsFixed(1)}%
- Financial Health Score: ${healthScore.toStringAsFixed(0)}/100

TOP SPENDING CATEGORIES:
$top3Text

Generate 5 insights in this exact format (one per line):
[TYPE] Title | Description

Where TYPE is one of: warning, success, tip, alert, opportunity

Rules:
1. Be specific to the data (mention actual amounts/categories)
2. Be encouraging but honest about problems
3. Provide actionable recommendations
4. Keep descriptions under 150 characters
5. Mix of warnings, tips, and opportunities

Example:
[warning] High Food Spending | Food & Dining at \$1,200 is 40% above average. Consider meal planning to save \$300/month.
[tip] Great Savings Rate | Your 25% savings rate is excellent! Keep prioritizing emergency fund growth.
''';
  }

  /// Parse insights from Gemini response
  List<AIInsight> _parseInsightsFromResponse(String response) {
    final insights = <AIInsight>[];
    final lines = response.split('\n').where((line) => line.trim().isNotEmpty);

    for (final line in lines) {
      final match = RegExp(r'\[(\w+)\]\s+([^|]+)\|\s+(.+)').firstMatch(line.trim());
      if (match != null) {
        final typeStr = match.group(1)?.toLowerCase() ?? 'info';
        final title = match.group(2)?.trim() ?? '';
        final description = match.group(3)?.trim() ?? '';

        if (title.isNotEmpty && description.isNotEmpty) {
          insights.add(AIInsight(
            id: 'gemini-${DateTime.now().millisecondsSinceEpoch}-${insights.length}',
            userId: 'current-user',
            title: title,
            description: description,
            type: _parseInsightType(typeStr),
            timestamp: DateTime.now(),
          ));
        }
      }
    }

    return insights.take(5).toList();
  }

  /// Parse insight type from string
  InsightType _parseInsightType(String type) {
    switch (type) {
      case 'warning':
        return InsightType.warning;
      case 'success':
        return InsightType.success;
      case 'alert':
        return InsightType.alert;
      case 'tip':
        return InsightType.tip;
      case 'opportunity':
        return InsightType.opportunity;
      default:
        return InsightType.info;
    }
  }

  /// Generate mock insights (fallback) - uses real data parameters
  List<AIInsight> _generateMockInsights({
    required double monthlyIncome,
    required double totalExpenses,
    required double savingsRate,
    required Map<String, double> topCategories,
    required double healthScore,
  }) {
    final insights = <AIInsight>[];
    final topCategory = topCategories.entries.isNotEmpty ? topCategories.entries.first : null;
    final topCategoryName = topCategory?.key ?? 'Uncategorized';
    final topCategoryAmount = topCategory?.value ?? 0.0;
    final categoryPercentage = monthlyIncome > 0 ? (topCategoryAmount / monthlyIncome) * 100 : 0.0;

    // Insight 1: Top category spending
    if (categoryPercentage > 15) {
      insights.add(AIInsight(
        id: 'mock-1',
        userId: 'current-user',
        title: 'High $topCategoryName Spending',
        description: '$topCategoryName at \$${topCategoryAmount.toStringAsFixed(0)} is ${categoryPercentage.toStringAsFixed(0)}% of income. Consider reducing by 10% to save \$${(topCategoryAmount * 0.1).toStringAsFixed(0)}/month.',
        type: InsightType.warning,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ));
    }

    // Insight 2: Savings rate
    if (savingsRate >= 20) {
      insights.add(AIInsight(
        id: 'mock-2',
        userId: 'current-user',
        title: 'Excellent Savings Rate!',
        description: 'Your ${savingsRate.toStringAsFixed(1)}% savings rate is excellent! Keep building your emergency fund.',
        type: InsightType.success,
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      ));
    } else if (savingsRate < 10) {
      insights.add(AIInsight(
        id: 'mock-2',
        userId: 'current-user',
        title: 'Low Savings Rate',
        description: 'Your ${savingsRate.toStringAsFixed(1)}% savings rate is below recommended 20%. Aim to save at least \$${(monthlyIncome * 0.2).toStringAsFixed(0)}/month.',
        type: InsightType.alert,
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      ));
    }

    // Insight 3: Health score
    if (healthScore >= 80) {
      insights.add(AIInsight(
        id: 'mock-3',
        userId: 'current-user',
        title: 'Strong Financial Health',
        description: 'Your health score of ${healthScore.toStringAsFixed(0)}/100 shows great financial management. Consider increasing investments.',
        type: InsightType.success,
        timestamp: DateTime.now().subtract(const Duration(hours: 8)),
      ));
    } else if (healthScore < 50) {
      insights.add(AIInsight(
        id: 'mock-3',
        userId: 'current-user',
        title: 'Financial Health Alert',
        description: 'Your health score of ${healthScore.toStringAsFixed(0)}/100 needs attention. Focus on reducing expenses and increasing savings.',
        type: InsightType.alert,
        timestamp: DateTime.now().subtract(const Duration(hours: 8)),
      ));
    }

    // Insight 4: Investment opportunity
    if (savingsRate > 15) {
      insights.add(AIInsight(
        id: 'mock-4',
        userId: 'current-user',
        title: 'Investment Opportunity',
        description: 'With your ${savingsRate.toStringAsFixed(1)}% savings rate, you could invest \$${(monthlyIncome * savingsRate / 100).toStringAsFixed(0)}/month in index funds.',
        type: InsightType.opportunity,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ));
    }

    // Insight 5: General tip
    insights.add(AIInsight(
      id: 'mock-5',
      userId: 'current-user',
      title: 'Track Your Spending',
      description: 'Continue tracking expenses in $topCategoryName to identify patterns and optimize your budget.',
      type: InsightType.tip,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ));

    return insights.take(5).toList();
  }

  /// Generate mock summary
  String _generateMockSummary({
    required double monthlyIncome,
    required double totalExpenses,
    required double savingsRate,
    required int transactionCount,
  }) {
    return 'You\'re doing great! With a ${savingsRate.toStringAsFixed(1)}% savings rate and \$${monthlyIncome.toStringAsFixed(0)} monthly income, you\'re on track to meet your financial goals. Consider optimizing your top spending categories to save even more.';
  }

  /// Generate mock answer
  String _generateMockAnswer(String question) {
    final intent = AIIntentAnalyzer.analyze(question);
    if (intent.response != null) {
      return intent.response!;
    }
    return 'Based on your financial data, I recommend focusing on reducing discretionary spending by 15% and increasing your emergency fund to cover 6 months of expenses. Would you like specific recommendations for your top spending categories?';
  }
}
