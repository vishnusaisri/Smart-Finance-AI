import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/gemini_service.dart';
import '../../../core/models/expense.dart';
import '../../../core/models/user_profile.dart';
import '../../expense/controllers/expense_controller.dart';
import '../../auth/providers/profile_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final bool isLoading;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.isLoading = false,
  });

  ChatMessage copyWith({
    String? id,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    bool? isLoading,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ChatService {
  final GeminiService _geminiService;
  final StreamController<List<ChatMessage>> _messagesController;
  final StreamController<bool> _typingController;
  final Ref _ref;

  ChatService(this._geminiService, this._ref)
      : _messagesController = StreamController<List<ChatMessage>>.broadcast(),
        _typingController = StreamController<bool>.broadcast();

  Stream<List<ChatMessage>> get messagesStream => _messagesController.stream;
  Stream<bool> get typingStream => _typingController.stream;

  List<ChatMessage> _messages = [];
  bool _isTyping = false;

  void initialize() {
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    final welcomeMessage = ChatMessage(
      id: 'welcome',
      content: '''Hello! I'm your AI Finance Assistant. I can help you with:

💰 Budget planning and management
📊 Spending analysis and insights
🎯 Financial goal setting
🔄 Investment strategies
📈 Expense tracking optimization
🧠 Financial education
📱 Money-saving tips

What would you like to know about your finances today?''',
      isUser: false,
      timestamp: DateTime.now(),
    );

    _messages.add(welcomeMessage);
    _messagesController.add(List.from(_messages));
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Add user message
    final userMessage = ChatMessage(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      content: message,
      isUser: true,
      timestamp: DateTime.now(),
    );

    _messages.add(userMessage);
    _messagesController.add(List.from(_messages));

    // Show typing indicator
    _setTyping(true);

    try {
      // Get AI response
      final aiResponse = await _getAIResponse(message);
      
      // Add AI response
      final aiMessage = ChatMessage(
        id: 'ai-${DateTime.now().millisecondsSinceEpoch}',
        content: aiResponse,
        isUser: false,
        timestamp: DateTime.now(),
      );

      _messages.add(aiMessage);
      _messagesController.add(List.from(_messages));
    } catch (e) {
      // Add error message
      final errorMessage = ChatMessage(
        id: 'error-${DateTime.now().millisecondsSinceEpoch}',
        content: 'I apologize, but I encountered an error. Please try asking your question again.',
        isUser: false,
        timestamp: DateTime.now(),
      );

      _messages.add(errorMessage);
      _messagesController.add(List.from(_messages));
    } finally {
      _setTyping(false);
    }
  }

  Future<String> _getAIResponse(String message) async {
    // Get real user context from Firebase
    final auth = FirebaseAuth.instance.currentUser;
    if (auth == null) {
      return 'Please login to use the AI assistant.';
    }

    final userProfile = _ref.read(userProfileProvider);
    final expenses = _ref.read(expensesProvider);

    final monthlyIncome = userProfile?.monthlyIncome ?? 0.0;
    final savingsGoal = userProfile?.savingsGoal ?? 0.0;
    final expenseList = expenses ?? [];
    final totalExpenses = expenseList.fold<double>(0, (sum, e) => sum + e.amount);

    // Determine question type and route to appropriate AI service
    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('budget') || lowerMessage.contains('spend')) {
      return await _geminiService.answerBudgetQuestion(
        question: message,
        userContext: {
          'monthlyIncome': monthlyIncome,
          'savingsGoal': savingsGoal,
          'recentExpenses': expenseList.map((e) => e.toMap()).toList(),
        },
      );
    } else if (lowerMessage.contains('save') || lowerMessage.contains('savings')) {
      return await _geminiService.answerSavingsQuestion(
        question: message,
        userContext: {
          'monthlyIncome': monthlyIncome,
          'currentSavings': savingsGoal,
        },
      );
    } else if (lowerMessage.contains('invest') || lowerMessage.contains('investment')) {
      return await _geminiService.answerInvestmentQuestion(
        question: message,
        userContext: {
          'riskTolerance': 'moderate',
          'investmentHorizon': 'long-term',
        },
      );
    } else {
      // Find top spending category
      final categoryBreakdown = <String, double>{};
      for (final expense in expenseList) {
        categoryBreakdown[expense.category] = (categoryBreakdown[expense.category] ?? 0) + expense.amount;
      }
      final topCategory = categoryBreakdown.isEmpty
          ? 'None'
          : categoryBreakdown.entries.reduce((a, b) => a.value > b.value ? a : b).key;

      return await _geminiService.answerFinancialQuestion(
        question: message,
        userContext: {
          'monthlyIncome': monthlyIncome,
          'totalExpenses': totalExpenses,
          'savingsRate': monthlyIncome > 0 ? (savingsGoal / monthlyIncome) * 100 : 0,
          'topCategory': topCategory,
        },
      );
    }
  }

  void _setTyping(bool isTyping) {
    _isTyping = isTyping;
    _typingController.add(isTyping);
  }

  void clearChat() {
    _messages.clear();
    _addWelcomeMessage();
  }

  void dispose() {
    _messagesController.close();
    _typingController.close();
  }

  // Get suggested questions
  List<String> getSuggestedQuestions() {
    return [
      'How can I improve my savings rate?',
      'What\'s a good budget for my income?',
      'How do I reduce impulse spending?',
      'Should I invest my savings?',
      'What\'s the 50/30/20 rule?',
      'How to build an emergency fund?',
      'Best ways to track expenses?',
    ];
  }

  // Get chat history
  List<ChatMessage> getChatHistory() {
    return List.from(_messages);
  }

  // Export chat history
  String exportChatHistory() {
    final buffer = StringBuffer();
    buffer.writeln('=== AI Finance Assistant Chat History ===');
    buffer.writeln('Exported on: ${DateTime.now().toIso8601String()}');
    buffer.writeln('');

    for (final message in _messages) {
      buffer.writeln('${message.isUser ? 'USER' : 'AI'} (${message.timestamp.toIso8601String()}):');
      buffer.writeln(message.content);
      buffer.writeln('');
    }

    return buffer.toString();
  }
}