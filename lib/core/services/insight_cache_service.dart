import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ai_insight.dart';
import '../models/expense.dart';
import '../models/user_profile.dart';
import '../services/cache_service.dart';

// Insight Cache Service - handles caching and scheduling of AI insights
class InsightCacheService {
  final CacheService _cacheService;
  
  // Cache duration constants
  static const Duration _ruleBasedCacheDuration = Duration(hours: 1);
  static const Duration _aiInsightCacheDuration = Duration(hours: 6);
  
  // Cache keys
  static const String _ruleBasedInsightsKey = 'cached_rule_based_insights';
  static const String _aiInsightKey = 'cached_ai_insight';
  static const String _lastGeneratedKey = 'last_insight_generation_time';
  
  InsightCacheService(this._cacheService);
  
  // Check if cached insights are still valid
  bool _isCacheValid(String cacheKey, Duration duration) {
    final lastGenerated = _cacheService.getString(_lastGeneratedKey);
    if (lastGenerated == null) return false;
    
    try {
      final lastGeneratedTime = DateTime.parse(lastGenerated);
      final now = DateTime.now();
      return now.difference(lastGeneratedTime) < duration;
    } catch (e) {
      return false;
    }
  }
  
  // Get cached rule-based insights
  List<AIInsight>? getCachedRuleBasedInsights() {
    if (!_isCacheValid(_ruleBasedInsightsKey, _ruleBasedCacheDuration)) {
      return null;
    }
    
    final cached = _cacheService.getString(_ruleBasedInsightsKey);
    if (cached == null) return null;
    
    try {
      // In a real app, you'd deserialize from JSON
      // For now, return null to force regeneration
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // Cache rule-based insights
  Future<void> cacheRuleBasedInsights(List<AIInsight> insights) async {
    // In a real app, you'd serialize to JSON
    // For now, just update the timestamp
    await _cacheService.setString(_lastGeneratedKey, DateTime.now().toIso8601String());
  }
  
  // Get cached AI insight
  AIInsight? getCachedAIInsight() {
    if (!_isCacheValid(_aiInsightKey, _aiInsightCacheDuration)) {
      return null;
    }
    
    final cached = _cacheService.getString(_aiInsightKey);
    if (cached == null) return null;
    
    try {
      // In a real app, you'd deserialize from JSON
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // Cache AI insight
  Future<void> cacheAIInsight(AIInsight insight) async {
    // In a real app, you'd serialize to JSON
    await _cacheService.setString(_lastGeneratedKey, DateTime.now().toIso8601String());
  }
  
  // Clear all insight caches
  Future<void> clearCache() async {
    await _cacheService.remove(_ruleBasedInsightsKey);
    await _cacheService.remove(_aiInsightKey);
    await _cacheService.remove(_lastGeneratedKey);
  }
}

// Insight Scheduler - handles periodic insight generation
class InsightScheduler {
  final InsightCacheService _cacheService;
  Timer? _timer;
  
  InsightScheduler(this._cacheService);
  
  // Start periodic insight generation
  void startScheduler({
    required Duration interval,
    required Future<void> Function() onGenerate,
  }) {
    stopScheduler(); // Stop any existing timer
    
    _timer = Timer.periodic(interval, (_) async {
      try {
        await onGenerate();
      } catch (e) {
        // Log error but don't stop the scheduler
        print('Error generating insights: $e');
      }
    });
  }
  
  // Stop the scheduler
  void stopScheduler() {
    _timer?.cancel();
    _timer = null;
  }
  
  // Check if scheduler is running
  bool get isRunning => _timer != null && _timer!.isActive;
  
  // Dispose
  void dispose() {
    stopScheduler();
  }
}

// Providers
final insightCacheServiceProvider = Provider<InsightCacheService>((ref) {
  return InsightCacheService(ref.watch(cacheServiceProvider));
});

final insightSchedulerProvider = Provider<InsightScheduler>((ref) {
  return InsightScheduler(ref.watch(insightCacheServiceProvider));
});

// Insight generation state
final insightGenerationStateProvider = Provider<ValueNotifier<bool>>((ref) {
  return ValueNotifier<bool>(false);
});

// Last insight generation time
final lastInsightGenerationProvider = Provider<ValueNotifier<DateTime?>>((ref) {
  return ValueNotifier<DateTime?>(null);
});
