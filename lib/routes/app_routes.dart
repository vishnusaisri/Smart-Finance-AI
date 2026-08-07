import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/expense/screens/expense_history_screen.dart';
import '../features/expense/screens/add_expense_screen.dart';
import '../features/expense/screens/expense_detail_screen.dart';
import '../features/expense/screens/edit_expense_screen.dart';
import '../core/widgets/sidebar.dart';
import '../core/widgets/mobile_drawer.dart';
import '../core/widgets/bottom_navigation.dart';
import '../core/widgets/topbar.dart';
import '../core/constants/app_strings.dart';
import '../features/budget/screens/budget_screen.dart';
import '../features/financial_twin/screens/financial_twin_screen.dart';
import '../core/widgets/global_error_screen.dart';
import '../features/profile/screens/profile_setup_screen.dart';
import '../features/profile/screens/profile_settings_screen.dart';
import '../features/profile/screens/financial_setup_wizard.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import '../features/ai_assistant/screens/ai_assistant_screen.dart';
import '../features/analytics/screens/analytics_screen.dart';
import '../features/impulse/screens/impulse_screen.dart';
import '../features/predictions/screens/predictions_screen.dart';
import '../core/services/cache_service.dart';

// Route Names
class RouteNames {
  static const String splash = '/';
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String forgotPassword = '/auth/forgot-password';
  static const String profileSetup = '/auth/profile-setup';
  static const String financialSetup = '/auth/financial-setup';
  static const String onboarding = '/onboarding';
  static const String dashboard = '/dashboard';
  static const String expenses = '/expenses';
  static const String addExpense = '/expenses/add';
  static const String expenseDetail = '/expenses/:id';
  static const String budgets = '/budgets';
  static const String twinSimulator = '/twin-simulator';
  static const String aiAssistant = '/ai-assistant';
  static const String analytics = '/analytics';
  static const String impulse = '/impulse';
  static const String predictions = '/predictions';
  static const String profile = '/profile';
}

// Shell route for authenticated pages with sidebar
final _shellNavigatorKey = GlobalKey<NavigatorState>();

// GoRouter provider
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: GlobalKey<NavigatorState>(),
    initialLocation: RouteNames.splash,
    errorBuilder: (context, state) => GlobalErrorScreen(error: state.error),
    routes: [
      // Public Routes
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreenPlaceholder(),
      ),
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.signup,
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RouteNames.profileSetup,
        name: 'profileSetup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: RouteNames.financialSetup,
        name: 'financialSetup',
        builder: (context, state) => const FinancialSetupWizard(),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Authenticated Routes with Shell (Sidebar)
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return AuthenticatedShell(child: child);
        },
        routes: [
          GoRoute(
            path: RouteNames.dashboard,
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: RouteNames.expenses,
            name: 'expenses',
            builder: (context, state) => const ExpenseHistoryScreen(),
            routes: [
              GoRoute(
                path: 'add',
                name: 'addExpense',
                builder: (context, state) => const AddExpenseScreen(),
              ),
              GoRoute(
                path: ':id',
                name: 'expenseDetail',
                builder: (context, state) => ExpenseDetailScreen(
                  expenseId: state.pathParameters['id']!,
                ),
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: 'editExpense',
                    builder: (context, state) => EditExpenseScreen(
                      expenseId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: RouteNames.budgets,
            name: 'budgets',
            builder: (context, state) => const BudgetScreen(),
          ),
          GoRoute(
            path: RouteNames.twinSimulator,
            name: 'twinSimulator',
            builder: (context, state) => const FinancialTwinScreen(),
          ),
          GoRoute(
            path: RouteNames.aiAssistant,
            name: 'aiAssistant',
            builder: (context, state) => const AIAssistantScreen(),
          ),
          GoRoute(
            path: RouteNames.analytics,
            name: 'analytics',
            builder: (context, state) => const AnalyticsScreen(),
          ),
          GoRoute(
            path: RouteNames.impulse,
            name: 'impulse',
            builder: (context, state) => const ImpulseScreen(),
          ),
          GoRoute(
            path: RouteNames.predictions,
            name: 'predictions',
            builder: (context, state) => const PredictionsScreen(),
          ),
          GoRoute(
            path: RouteNames.profile,
            name: 'profile',
            builder: (context, state) => const ProfileSettingsScreen(),
          ),
        ],
      ),
    ],
  );
});

// Splash Screen with Firebase initialization
class SplashScreenPlaceholder extends ConsumerStatefulWidget {
  const SplashScreenPlaceholder({super.key});

  @override
  ConsumerState<SplashScreenPlaceholder> createState() =>
      _SplashScreenPlaceholderState();
}

class _SplashScreenPlaceholderState
    extends ConsumerState<SplashScreenPlaceholder> {

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Premium splash delay
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    try {
      // Check onboarding status first
      final cacheService = ref.read(cacheServiceProvider);
      final isOnboardingComplete = cacheService.isOnboardingComplete();

      if (!isOnboardingComplete) {
        context.go(RouteNames.onboarding);
        return;
      }

      // Check Firebase auth state
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        // Check if financial setup is complete
        final isFinancialSetupComplete = cacheService.isFinancialSetupComplete();
        if (!isFinancialSetupComplete) {
          context.go(RouteNames.financialSetup);
          return;
        }
        context.go(RouteNames.dashboard);
      } else {
        context.go(RouteNames.login);
      }
    } catch (e) {
      // Firebase not initialized, go to login
      context.go(RouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071120),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_balance_wallet_rounded,
              size: 72,
              color: Color(0xFF3B82F6),
            ),
            const SizedBox(height: 24),
            Text(
              AppStrings.appName,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 40),
            const SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Color(0xFF3B82F6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Authenticated Shell with Sidebar
class AuthenticatedShell extends StatefulWidget {
  final Widget child;
  const AuthenticatedShell({super.key, required this.child});

  @override
  State<AuthenticatedShell> createState() => _AuthenticatedShellState();
}

class _AuthenticatedShellState extends State<AuthenticatedShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    // Get current route for sidebar active state
    final currentRoute = GoRouterState.of(context).uri.path;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    if (isMobile) {
      return Scaffold(
        key: _scaffoldKey,
        drawer: MobileDrawer(currentRoute: currentRoute),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Mobile TopBar with menu button
              TopBar(
                title: _getPageTitle(currentRoute),
                showSearch: false,
                showMenuButton: true,
                onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              // Main Content
              Expanded(
                child: widget.child,
              ),
              // Bottom Navigation
              BottomNavigation(currentRoute: currentRoute),
            ],
          ),
        ),
      );
    }

    if (isTablet) {
      return Scaffold(
        body: Row(
          children: [
            // Collapsible Sidebar for tablet
            Sidebar(currentRoute: currentRoute),
            Expanded(
              child: Column(
                children: [
                  // TopBar
                  TopBar(
                    title: _getPageTitle(currentRoute),
                    showSearch: true,
                  ),
                  // Main Content
                  Expanded(
                    child: widget.child,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Desktop layout
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Sidebar(currentRoute: currentRoute),
          Expanded(
            child: Column(
              children: [
                // TopBar
                TopBar(
                  title: _getPageTitle(currentRoute),
                  showSearch: true,
                ),
                // Main Content
                Expanded(
                  child: widget.child,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getPageTitle(String route) {
    if (route.startsWith('/dashboard')) return AppStrings.dashboard;
    if (route.startsWith('/expenses')) return AppStrings.expenses;
    if (route.startsWith('/budgets')) return AppStrings.budgets;
    if (route.startsWith('/analytics')) return AppStrings.analytics;
    if (route.startsWith('/impulse')) return AppStrings.impulseDetector;
    if (route.startsWith('/predictions')) return AppStrings.predictions;
    if (route.startsWith('/twin-simulator')) return AppStrings.twinSimulator;
    if (route.startsWith('/ai-assistant')) return AppStrings.aiAssistant;
    if (route.startsWith('/profile')) return AppStrings.profile;
    return AppStrings.appName;
  }
}
