# Smart Finance AI - Premium Fintech Platform

A modern, AI-powered personal finance intelligence system built with Flutter Web, featuring rule-based behavioral analysis engines combined with Gemini AI for financial insights, predictions, and coaching.

## 🚀 Features

- **Smart Dashboard** - Real-time financial overview with interactive charts
- **Expense Management** - Track, categorize, and analyze spending
- **Budget System** - Create and monitor budgets with leak detection
- **Spending Analytics** - Deep insights into spending behavior
- **Impulse Purchase Detector** - Identify and reduce impulsive spending
- **Financial Predictions** - AI-powered expense and savings forecasting
- **Financial Twin Simulator** - Compare current vs optimized financial behavior
- **AI Finance Assistant** - Gemini-powered financial coaching
- **Premium Dark UI** - Glassmorphism design inspired by Stripe, Revolut, CRED

## 🏗️ Architecture

Feature-first clean architecture with:
- **State Management**: Riverpod (Notifier pattern)
- **Routing**: GoRouter with shell routes
- **Charts**: FL Chart
- **AI**: Rule-based engines + Gemini API
- **Backend**: Firebase (Auth + Firestore) with mock mode

## 📦 Tech Stack

- Flutter Web
- Firebase Authentication
- Cloud Firestore
- Riverpod State Management
- GoRouter Navigation
- FL Chart
- Google Fonts
- Gemini API
- Responsive Desktop-first Design

## 🛠️ Setup Instructions

### Prerequisites
- Flutter SDK 3.12+ 
- Dart 3.12+
- IDE (VS Code, Android Studio, or IntelliJ)

### Installation

1. **Navigate to project directory**:
```bash
cd "smart_finance_ai"
```

2. **Install dependencies**:
```bash
flutter pub get
```

3. **Firebase Setup** (Optional - App works in mock mode without Firebase):

   a. Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
   
   b. Enable Authentication (Email/Password)
   
   c. Enable Cloud Firestore
   
   d. Download `google-services.json` (Android) and/or `GoogleService-Info.plist` (iOS)
   
   e. Place config files in appropriate directories
   
   f. Update Firebase initialization in `lib/main.dart` if needed

4. **Gemini AI Setup** (Optional):

   a. Get API key from [Google AI Studio](https://makersuite.google.com)
   
   b. Add API key to environment variables or create `lib/core/constants/api_keys.dart`:
   ```dart
   class ApiKeys {
     static const String geminiApiKey = 'YOUR_API_KEY_HERE';
   }
   ```

5. **Run the app**:
```bash
flutter run -d chrome
```

The app will run in **mock mode** by default with realistic demo data if Firebase is not configured.

## 📁 Project Structure

```
lib/
├── core/                      # Core utilities and shared code
│   ├── constants/             # App colors, strings, constants
│   ├── models/                # Data models (Expense, Budget, etc.)
│   ├── services/              # Shared services (Firebase, AI, etc.)
│   ├── theme/                 # Theme system (colors, typography, spacing)
│   ├── utils/                 # Utilities and helpers
│   └── widgets/               # Reusable UI components
│
├── features/                  # Feature modules
│   ├── auth/                  # Authentication
│   ├── dashboard/             # Main dashboard
│   ├── expense/               # Expense management
│   ├── budget/                # Budget system
│   ├── analytics/             # Spending analytics
│   ├── impulse_detector/      # Impulse purchase detection
│   ├── prediction/            # Financial predictions
│   ├── financial_twin/        # Twin simulator
│   └── profile/               # User profile & settings
│
├── routes/                    # GoRouter configuration
│   └── app_routes.dart
│
└── main.dart                  # App entry point
```

## 🎨 Design System

### Colors
- Background: `#0F172A` (Slate 900)
- Surface: `#1E293B` (Slate 800)
- Primary: `#3B82F6` (Blue 500)
- Secondary: `#8B5CF6` (Purple 500)
- Accent: `#06B6D4` (Cyan 500)
- Success: `#10B981` (Emerald 500)
- Warning: `#F59E0B` (Amber 500)
- Danger: `#EF4444` (Red 500)

### Typography
- Font Family: Inter (via Google Fonts)
- Scale: Display (48px) → H1 (32px) → H6 (16px) → Body (14px) → Caption (12px)

### Spacing
- Base unit: 4px
- Scale: 4, 8, 12, 16, 24, 32, 48, 64, 80

## 🔧 Configuration

### Running in Mock Mode (Default)
The app automatically runs in mock mode if Firebase is not configured. This includes:
- Mock authentication
- Sample expenses (90 days)
- Sample budgets
- AI insights
- Financial health score

### Running with Firebase
1. Complete Firebase setup steps above
2. Set `useMockMode = false` in service providers
3. Run the app

## 📊 Key Algorithms

### Financial Health Score
- Savings Rate: 30% weight
- Budget Adherence: 25% weight
- Expense Diversity: 15% weight
- Impulse Control: 20% weight
- Consistency: 10% weight

### Expense Prediction
```
predicted_expense = (month_1 * 0.5 + month_2 * 0.3 + month_3 * 0.2) * seasonal_factor
```

### Impulse Detection
- Amount deviation: 30%
- Frequency spike: 25%
- Time pattern: 20%
- Category risk: 15%
- User reports: 10%

## 🚀 Development

### Adding New Features
1. Create feature folder in `lib/features/`
2. Add models in `lib/core/models/`
3. Create screens, widgets, controllers, services
4. Add route in `lib/routes/app_routes.dart`
5. Register providers with Riverpod

### State Management Pattern
```dart
// Service
final expenseServiceProvider = Provider<ExpenseService>((ref) {
  return ExpenseService();
});

// Controller
final expensesProvider = NotifierProvider<ExpenseController, List<Expense>>((ref) {
  return ExpenseController();
});

// Computed
final filteredExpensesProvider = Provider<List<Expense>>((ref) {
  final expenses = ref.watch(expensesProvider);
  return expenses.where((e) => !e.isImpulse).toList();
});
```

## 📱 Responsive Design

### Breakpoints
- Desktop: > 1024px (primary target)
- Tablet: 600px - 1024px
- Mobile: < 600px

### Layout Strategy
- Desktop: Sidebar + multi-column grid
- Tablet: Collapsible sidebar + 2-column
- Mobile: Bottom nav + single column

## 🤝 Contributing

This is a production-grade fintech application. When contributing:
1. Follow the feature-first architecture
2. Use Riverpod for state management
3. Keep UI components reusable
4. Write clean, documented code
5. Test with both mock and real Firebase

## 📝 License

Private project - All rights reserved

## 🎯 Roadmap

- [x] Core foundation and theme system
- [x] Reusable widget library
- [x] Routing and navigation
- [x] Data models
- [x] Mock data generator
- [ ] Authentication screens (in progress)
- [ ] Dashboard with analytics
- [ ] Expense management
- [ ] Budget system
- [ ] Spending analytics
- [ ] Impulse detector
- [ ] Financial predictions
- [ ] Twin simulator
- [ ] AI assistant
- [ ] Profile & settings
- [ ] Firebase integration
- [ ] Testing & optimization

## 💡 Tips

1. **For best experience**: Run on Chrome with desktop viewport
2. **Mock data**: Refreshes on each app restart
3. **Firebase**: Optional but recommended for production
4. **AI features**: Require Gemini API key for full functionality
5. **Performance**: Use `--release` mode for production builds

## 🐛 Troubleshooting

**Firebase initialization error:**
- Normal if Firebase not configured
- App will run in mock mode automatically

**Charts not rendering:**
- Ensure FL Chart is properly imported
- Check data format matches chart requirements

**Routing issues:**
- Verify route names in `app_routes.dart`
- Check GoRouter configuration

**Build errors:**
- Run `flutter clean`
- Run `flutter pub get`
- Restart IDE

---

Built with ❤️ using Flutter & Firebase
