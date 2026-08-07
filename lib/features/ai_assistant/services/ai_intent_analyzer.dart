enum AIInputCategory {
  greeting,
  thanks,
  invalidOrGibberish,
  financialQuery,
}

class AIIntentResult {
  final AIInputCategory category;
  final String? response;

  AIIntentResult(this.category, {this.response});
}

class AIIntentAnalyzer {
  static const Set<String> _greetings = {
    'hi',
    'hello',
    'hey',
    'heya',
    'hallo',
    'good morning',
    'good afternoon',
    'good evening',
    'greetings',
    'howdy',
    'hi there',
    'hello there',
    'sup',
    'yo',
    'hi ai',
    'hello ai',
    'hey assistant',
    'hello assistant',
    'namaste',
    'hola',
  };

  static const Set<String> _thanks = {
    'thanks',
    'thank you',
    'thx',
    'thank u',
    'thanks a lot',
    'thank you so much',
  };

  static const Set<String> _financialKeywords = {
    'budget',
    'budgets',
    'save',
    'saving',
    'savings',
    'spend',
    'spending',
    'expense',
    'expenses',
    'money',
    'invest',
    'investing',
    'investment',
    'investments',
    'debt',
    'debts',
    'loan',
    'loans',
    'emi',
    'emis',
    'credit',
    'card',
    'cards',
    'income',
    'salary',
    'tax',
    'taxes',
    'fund',
    'funds',
    'bank',
    'banking',
    'cost',
    'costs',
    'price',
    'buy',
    'pay',
    'payment',
    'bill',
    'bills',
    'cash',
    'goal',
    'goals',
    'portfolio',
    'stock',
    'stocks',
    'mutual',
    'sip',
    'fd',
    'rd',
    'nps',
    'ppf',
    'return',
    'returns',
    'profit',
    'loss',
    'interest',
    'cibil',
    'financial',
    'finance',
    'wealth',
    'retire',
    'retirement',
    'emergency',
    'track',
    'tracker',
    'tracking',
    'account',
    'rupee',
    'rupees',
    'dollar',
    'dollars',
    'cashflow',
    'asset',
    'assets',
    'liability',
    'liabilities',
    'inflation',
    'deficit',
    'surplus',
    'balance'
  };

  static const Set<String> _commonQueryWords = {
    'what',
    'how',
    'why',
    'where',
    'when',
    'who',
    'which',
    'can',
    'could',
    'should',
    'would',
    'is',
    'are',
    'am',
    'do',
    'does',
    'did',
    'tell',
    'give',
    'show',
    'explain',
    'help',
    'need',
    'want',
    'tip',
    'tips',
    'advice',
    'suggest',
    'suggestion',
    'guide',
    'calculate',
    'analyze',
    'check',
    'report',
    'summary',
    'about',
    'recommend',
    'recommendation',
    'recommendations',
    'please'
  };

  /// Analyzes the user message and returns an [AIIntentResult].
  static AIIntentResult analyze(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return AIIntentResult(
        AIInputCategory.invalidOrGibberish,
        response: "Please enter a valid question or statement regarding your finances.",
      );
    }

    final lower = trimmed.toLowerCase();
    final cleanText = lower.replaceAll(RegExp(r'[^\w\s]'), '').trim();

    // 1. Check Greetings
    if (_greetings.contains(cleanText) ||
        _greetings.any((g) => cleanText.startsWith('$g ') || cleanText == g)) {
      return AIIntentResult(
        AIInputCategory.greeting,
        response: "Hello! 👋 How can I help you today? Please tell me what question or financial problem you would like assistance with.",
      );
    }

    // 2. Check Thanks
    if (_thanks.contains(cleanText) || _thanks.any((t) => cleanText.startsWith(t))) {
      return AIIntentResult(
        AIInputCategory.thanks,
        response: "You're welcome! 😊 Let me know if you have any more questions about your budget, savings, or investments.",
      );
    }

    // 3. Gibberish / Punctuation / Number-only checks
    // Pure punctuation/symbols
    if (RegExp(r'^[^\w\s]+$').hasMatch(trimmed)) {
      return AIIntentResult(
        AIInputCategory.invalidOrGibberish,
        response: "Please give a valid question or statement regarding your finances.",
      );
    }

    // Pure numbers without context
    if (RegExp(r'^\d+$').hasMatch(cleanText)) {
      return AIIntentResult(
        AIInputCategory.invalidOrGibberish,
        response: "Please give a valid question or statement regarding your finances.",
      );
    }

    // Repeating characters (e.g., "aaaaa", "zzzzzzz")
    if (RegExp(r'(.)\1{4,}').hasMatch(cleanText)) {
      return AIIntentResult(
        AIInputCategory.invalidOrGibberish,
        response: "This is not a valid statement. Please ask a valid question about your finances.",
      );
    }

    // Tokenize words
    final words = cleanText.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

    // Check for keyboard mashing or vowelless gibberish words > 3 chars
    int gibberishCount = 0;
    for (final word in words) {
      if (word.length >= 4 && !RegExp(r'[aeiouy]').hasMatch(word)) {
        gibberishCount++;
      } else if (['qwerty', 'asdfgh', 'zxcvbn', 'dfghj', 'fghjkl', 'lkjhgf'].contains(word)) {
        gibberishCount++;
      }
    }

    if (gibberishCount > 0 && gibberishCount >= (words.length / 2).ceil()) {
      return AIIntentResult(
        AIInputCategory.invalidOrGibberish,
        response: "This is not a valid statement. Please ask a valid question about your finances.",
      );
    }

    // 4. Financial / Query Relevance check
    final hasFinancialKeyword = words.any((w) => _financialKeywords.contains(w));
    final hasQueryWord = words.any((w) => _commonQueryWords.contains(w));

    // If no financial keywords AND no general query/assistance words are present,
    // mark as invalid/irrelevant statement.
    if (!hasFinancialKeyword && !hasQueryWord) {
      return AIIntentResult(
        AIInputCategory.invalidOrGibberish,
        response: "This is not a valid statement. Please ask a valid question regarding your budget, expenses, savings, investments, or financial tips.",
      );
    }

    // Valid financial or general inquiry
    return AIIntentResult(AIInputCategory.financialQuery);
  }
}
