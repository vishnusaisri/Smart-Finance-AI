import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/text_styles.dart';
import '../../profile/providers/profile_providers.dart';
import '../../expense/controllers/expense_controller.dart';
import '../services/ai_intent_analyzer.dart';

class AIAssistantScreen extends ConsumerStatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  ConsumerState<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends ConsumerState<AIAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "👋 Hi! I'm your Smart Finance AI — your personal financial advisor, available 24/7.",
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(seconds: 12)),
    ),
    ChatMessage(
      text: "📊 I've already analyzed your financial data. I can help you:\n\n• Track where your money is going\n• Find ways to save more each month\n• Give you personalized budget tips\n• Analyze your spending patterns",
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(seconds: 8)),
    ),
    ChatMessage(
      text: "💡 Did you know? People who track their expenses save on average 20% more than those who don't. You're already on the right path!",
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(seconds: 4)),
    ),
    ChatMessage(
      text: "🤖 Ask me anything about your finances — or tap a quick suggestion below to get started!",
      isUser: false,
      timestamp: DateTime.now(),
    ),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _generateSmartResponse(String question, Map<String, dynamic> ctx) {
    final intentResult = AIIntentAnalyzer.analyze(question);
    if (intentResult.response != null) {
      return intentResult.response!;
    }

    final q = question.toLowerCase();
    final income = ctx['income'] as double;
    final totalExpenses = ctx['totalExpenses'] as double;
    final savings = income - totalExpenses;
    final savingsRate = income > 0 ? (savings / income * 100) : 0.0;
    final topCategory = ctx['topCategory'] as String;
    final categoryCount = ctx['categoryCount'] as int;

    // Saving related
    if (q.contains('save') || q.contains('saving') || q.contains('savings')) {
      if (savingsRate < 0) {
        return "⚠️ Based on your data, you're currently spending more than you earn — you're in a deficit of ₹${savings.abs().toStringAsFixed(0)}.\n\n📌 Action Plan:\n• Review your \"$topCategory\" expenses first — that's your biggest category.\n• Try the 50/30/20 rule: 50% needs, 30% wants, 20% savings.\n• Cut non-essential subscriptions and dining out by 30%.\n\nWould you like a custom budget breakdown?";
      } else if (savingsRate < 20) {
        return "📊 You're currently saving ${savingsRate.toStringAsFixed(1)}% of your income, which is ₹${savings.toStringAsFixed(0)} per month.\n\n💡 Financial experts recommend saving at least 20%. Here's how to get there:\n\n• Automate a fixed transfer to savings on payday.\n• Reduce \"$topCategory\" spending by 15% — that alone could push you past 20%.\n• Track every expense for 7 days — awareness alone reduces spending by 10%.";
      } else {
        return "🎉 Excellent! You're saving ${savingsRate.toStringAsFixed(1)}% of your income — ₹${savings.toStringAsFixed(0)} per month. That's above the recommended 20%!\n\n🚀 Since you're doing great, consider:\n• Investing your savings in a SIP or mutual fund.\n• Building a 6-month emergency fund if you haven't already.\n• Reviewing your insurance coverage.";
      }
    }

    // Budget related
    if (q.contains('budget') || q.contains('plan') || q.contains('breakdown')) {
      return "📋 Based on your income of ₹${income.toStringAsFixed(0)}, here's your ideal budget using the 50/30/20 rule:\n\n✅ Needs (50%): ₹${(income * 0.5).toStringAsFixed(0)}\n   — Rent, food, utilities, transport\n\n🎯 Wants (30%): ₹${(income * 0.3).toStringAsFixed(0)}\n   — Entertainment, dining, shopping\n\n💰 Savings (20%): ₹${(income * 0.2).toStringAsFixed(0)}\n   — Emergency fund, investments, goals\n\nYou're currently spending ₹${totalExpenses.toStringAsFixed(0)}. ${totalExpenses > income * 0.8 ? "⚠️ That's quite high — try to cut back on $topCategory." : "✅ That's within a healthy range!"}";
    }

    // Expense/spending related
    if (q.contains('spend') || q.contains('expense') || q.contains('biggest') || q.contains('most')) {
      if (categoryCount == 0) {
        return "📊 You haven't added any expenses yet! Start by logging your daily expenses in the Expenses tab. The more you track, the more insights I can give you.\n\n💡 Tip: Even logging 3 days of expenses reveals powerful patterns about your spending habits!";
      }
      return "🔍 Analyzing your spending data...\n\nYour biggest expense category is **$topCategory**. This is your #1 opportunity for savings.\n\n📌 Smart strategies for $topCategory:\n• Set a monthly limit and stick to it.\n• Look for discounts or alternatives.\n• Review if all expenses here are truly necessary.\n\nYou have expenses across $categoryCount categories. Would you like tips for any specific one?";
    }

    // Income related
    if (q.contains('income') || q.contains('earn') || q.contains('salary')) {
      return "💼 Your recorded monthly income is ₹${income.toStringAsFixed(0)}.\n\n📊 Here's how it's being used:\n• Expenses: ₹${totalExpenses.toStringAsFixed(0)} (${income > 0 ? (totalExpenses / income * 100).toStringAsFixed(1) : 0}%)\n• Available: ₹${savings.toStringAsFixed(0)} (${savingsRate.toStringAsFixed(1)}%)\n\n💡 To increase financial security, consider diversifying with a side income stream or investing your surplus.";
    }

    // Investment related
    if (q.contains('invest') || q.contains('stock') || q.contains('mutual fund') || q.contains('sip')) {
      return "📈 Great question! Here's a beginner-friendly investment roadmap:\n\n1️⃣ Emergency Fund First — Save 3-6 months of expenses (₹${(totalExpenses * 4).toStringAsFixed(0)} recommended).\n2️⃣ SIP in Mutual Funds — Start with ₹500/month in a large-cap index fund.\n3️⃣ PPF/NPS — Tax-saving instruments with guaranteed returns.\n4️⃣ Stocks — Only invest what you can afford to lose.\n\nBased on your current savings of ₹${savings.toStringAsFixed(0)}/month, you could start a SIP immediately!";
    }

    // Debt related
    if (q.contains('debt') || q.contains('loan') || q.contains('emi') || q.contains('credit card')) {
      return "💳 Managing debt wisely is key to financial freedom. Here's my advice:\n\n🔴 High Priority — Pay off high-interest debt first (credit cards, personal loans).\n🟡 Medium Priority — EMIs for cars or appliances.\n🟢 Low Priority — Home loans (tax deductible).\n\n📌 The 'Debt Avalanche' strategy: Pay minimums on all debts, then throw extra money at the highest interest rate first. This saves the most money long-term!";
    }

    // Health score
    if (q.contains('health') || q.contains('score') || q.contains('status') || q.contains('how am i doing')) {
      String rating;
      String advice;
      if (savingsRate >= 20) {
        rating = "Excellent 🌟";
        advice = "Keep it up! Consider moving excess savings into investments.";
      } else if (savingsRate >= 10) {
        rating = "Good 👍";
        advice = "You're on the right track! Push savings above 20% to reach excellence.";
      } else if (savingsRate >= 0) {
        rating = "Needs Improvement ⚠️";
        advice = "Focus on reducing your top expense category: $topCategory.";
      } else {
        rating = "Critical 🚨";
        advice = "You're spending more than you earn. Review all expenses immediately.";
      }
      return "🏦 Your Financial Health Report:\n\nOverall Status: $rating\nSavings Rate: ${savingsRate.toStringAsFixed(1)}%\nMonthly Income: ₹${income.toStringAsFixed(0)}\nMonthly Expenses: ₹${totalExpenses.toStringAsFixed(0)}\nNet Savings: ₹${savings.toStringAsFixed(0)}\n\n📌 $advice";
    }

    // Tips
    if (q.contains('tip') || q.contains('advice') || q.contains('suggest') || q.contains('help') || q.contains('what should')) {
      return "💡 Here are my top 5 personalized financial tips for you:\n\n1. 🎯 Focus on \"$topCategory\" — it's your biggest expense.\n2. 💳 Avoid impulse purchases — wait 24 hours before buying.\n3. 📱 Use the Budgets tab to set monthly limits per category.\n4. 🔄 Automate savings on payday — pay yourself first!\n5. 📊 Review your expenses every Sunday — 10 minutes a week changes everything.\n\nWhich tip would you like me to expand on?";
    }

    // Emergency fund
    if (q.contains('emergency') || q.contains('fund')) {
      final target = totalExpenses * 6;
      return "🆘 Emergency Fund Guide:\n\nTarget Amount: ₹${target.toStringAsFixed(0)}\n(6 months of your expenses: ₹${totalExpenses.toStringAsFixed(0)} × 6)\n\n📌 How to build it:\n• Save ₹${(target / 12).toStringAsFixed(0)}/month for 12 months.\n• Keep it in a high-interest savings account.\n• Never touch it except for real emergencies.\n\nWith your current savings rate, you can reach this goal in ${savings > 0 ? (target / savings).ceil().toString() : 'N/A'} months!";
    }

    // Generic/fallback — still feels AI-like
    final responses = [
      "🤔 Great question! Based on your financial profile:\n\n• Monthly income: ₹${income.toStringAsFixed(0)}\n• Monthly expenses: ₹${totalExpenses.toStringAsFixed(0)}\n• Savings rate: ${savingsRate.toStringAsFixed(1)}%\n\nMy recommendation: Focus on your biggest spending area (\"$topCategory\") and try to reduce it by 10-15%. Even small cuts compound massively over time!\n\nAsk me about budgeting, savings, investments, or your spending analysis for more specific advice.",
      "📊 I've analyzed your data and here's what stands out:\n\nYou're spending ₹${totalExpenses.toStringAsFixed(0)}/month across $categoryCount categories. Your top category is \"$topCategory\".\n\n💡 My tip: Try the '1% rule' — reduce each category by just 1% this month. That's the easiest way to start saving more without feeling the pinch!\n\nWhat specific area would you like to dig deeper into?",
      "🧠 Financial planning is all about small, consistent actions. Here's what I'd suggest based on your data:\n\n1. Savings rate of ${savingsRate.toStringAsFixed(1)}% — ${savingsRate >= 20 ? 'excellent, keep it up!' : 'aim for 20%.'}\n2. Top spending: \"$topCategory\" — review this category weekly.\n3. Set a 90-day financial goal — what's one thing you want to achieve?\n\nI'm here to help you reach it! Ask me anything.",
    ];
    
    final index = question.length % responses.length;
    return responses[index];
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isTyping) return;

    setState(() {
      _messages.add(ChatMessage(text: message, isUser: true, timestamp: DateTime.now()));
      _isTyping = true;
      _messageController.clear();
    });

    _scrollToBottom();

    // Simulate thinking delay for realism
    final thinkTime = 1200 + (message.length * 20).clamp(0, 2000);
    await Future.delayed(Duration(milliseconds: thinkTime));

    final userProfile = ref.read(userProfileProvider);
    final stats = ref.read(expenseStatsProvider);

    String topCategory = 'General';
    if (stats.byCategory.isNotEmpty) {
      final sorted = stats.byCategory.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      topCategory = sorted.first.key;
    }

    final ctx = {
      'income': userProfile.monthlyIncome,
      'totalExpenses': stats.total,
      'topCategory': topCategory,
      'categoryCount': stats.byCategory.length,
    };

    final response = _generateSmartResponse(message, ctx);

    if (mounted) {
      setState(() {
        _messages.add(ChatMessage(text: response, isUser: false, timestamp: DateTime.now()));
        _isTyping = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: _messages.length + (_isTyping ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _messages.length && _isTyping) {
                return _buildTypingIndicator();
              }
              return _buildMessageBubble(_messages[index]);
            },
          ),
        ),

        // Quick suggestion chips
        if (_messages.length <= 5 && !_isTyping)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                _buildChip("💰 How to save more?"),
                _buildChip("📊 Analyze my spending"),
                _buildChip("🏦 My financial health"),
                _buildChip("💡 Give me a tip"),
                _buildChip("📈 Investment advice"),
              ],
            ),
          ),

        // Input bar
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: const BoxDecoration(
            color: Color(0x0DFFFFFF),
            border: Border(top: BorderSide(color: Color(0x1AFFFFFF), width: 1)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Ask me about your finances...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                    filled: true,
                    fillColor: const Color(0x1AFFFFFF),
                    contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                  maxLines: null,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              GestureDetector(
                onTap: _isTyping ? null : _sendMessage,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)]),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B5CF6).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _isTyping
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.send_rounded, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChip(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 12),
      child: ActionChip(
        label: Text(text, style: AppTextStyles.labelMedium),
        backgroundColor: const Color(0x1AFFFFFF),
        side: const BorderSide(color: Color(0x44FFFFFF)),
        onPressed: () {
          _messageController.text = text.replaceAll(RegExp(r'[^\w\s?]'), '').trim();
          _sendMessage();
        },
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 300),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: message.isUser ? const Color(0xFF8B5CF6) : const Color(0x1AFFFFFF),
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomLeft: message.isUser ? const Radius.circular(16) : Radius.zero,
                  bottomRight: message.isUser ? Radius.zero : const Radius.circular(16),
                ),
                border: message.isUser ? null : Border.all(color: const Color(0x22FFFFFF)),
              ),
              child: Text(
                message.text,
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white, height: 1.5),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: AppSpacing.sm),
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF10B981),
              child: const Icon(Icons.person_rounded, color: Colors.white, size: 18),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.08, end: 0);
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0x1AFFFFFF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x22FFFFFF)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) =>
                Padding(
                  padding: EdgeInsets.only(right: i < 2 ? 4 : 0),
                  child: Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(4)))
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(begin: const Offset(1, 1), end: const Offset(1.4, 1.4), duration: Duration(milliseconds: 500 + i * 150)),
                )
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, required this.timestamp});
}
