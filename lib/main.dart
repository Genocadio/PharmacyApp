import 'package:flutter/material.dart';
import 'package:nexxpharma/data/database.dart';
import 'package:nexxpharma/services/auth_service.dart';
import 'package:nexxpharma/services/settings_service.dart';
import 'package:nexxpharma/services/user_service.dart';
import 'package:nexxpharma/services/sync_service.dart';
import 'package:nexxpharma/services/stock_in_service.dart';
import 'package:nexxpharma/services/stock_out_service.dart';
import 'package:nexxpharma/services/notification_service.dart';
import 'package:nexxpharma/ui/screens/login_screen.dart';
import 'package:nexxpharma/ui/screens/stock_in_out_screen.dart';
import 'package:nexxpharma/ui/screens/activation_screen.dart';
import 'package:nexxpharma/services/activation_service.dart';
import 'package:nexxpharma/ui/screens/initial_sync_screen.dart';
import 'package:nexxpharma/ui/widgets/toast_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stack_trace/stack_trace.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.demangleStackTrace = (StackTrace stack) {
    if (stack is Trace) {
      return stack.vmTrace;
    }
    if (stack is Chain) {
      return stack.toTrace().vmTrace;
    }
    return stack;
  };

  final database = AppDatabase();
  final prefs = await SharedPreferences.getInstance();

  final userService = UserService(database);
  final authService = AuthService(userService);
  final settingsService = SettingsService(prefs);
  final syncService = SyncService(database, settingsService);
  final stockInService = StockInService(database);
  final stockOutService = StockOutService(database);
  final activationService = ActivationService(database, settingsService);
  final notificationService = NotificationService();

  runApp(
    MyApp(
      database: database,
      authService: authService,
      settingsService: settingsService,
      syncService: syncService,
      stockInService: stockInService,
      stockOutService: stockOutService,
      activationService: activationService,
      notificationService: notificationService,
    ),
  );
}

class MyApp extends StatelessWidget {
  final AppDatabase database;
  final AuthService authService;
  final SettingsService settingsService;
  final SyncService syncService;
  final StockInService stockInService;
  final StockOutService stockOutService;
  final ActivationService activationService;
  final NotificationService notificationService;

  const MyApp({
    super.key,
    required this.database,
    required this.authService,
    required this.settingsService,
    required this.syncService,
    required this.stockInService,
    required this.stockOutService,
    required this.activationService,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        authService,
        settingsService,
        syncService,
        activationService,
      ]),
      builder: (context, child) {
        const accentColor = Color(0xFF121827);
        const lightBg = Color(0xFFFAF3EF);

        return MaterialApp(
          title: 'NexxMed',
          debugShowCheckedModeBanner: false,
          themeMode: settingsService.themeMode,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: accentColor,
              primary: accentColor,
              surface: Colors.white,
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: lightBg,
            appBarTheme: const AppBarTheme(
              backgroundColor: lightBg,
              foregroundColor: accentColor,
              elevation: 0,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: lightBg,
              primary: lightBg,
              onPrimary: accentColor,
              surface: accentColor,
              onSurface: lightBg,
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: accentColor,
            appBarTheme: const AppBarTheme(
              backgroundColor: accentColor,
              foregroundColor: lightBg,
              elevation: 0,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: lightBg,
                foregroundColor: accentColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          builder: (context, child) {
            return ToastOverlay(
              notificationService: notificationService,
              child: child ?? const SizedBox.shrink(),
            );
          },
          home:
              activationService.activationState == null ||
                  authService.hasUsers == null
              ? const Scaffold(body: Center(child: CircularProgressIndicator()))
              : (activationService.activationState == true
                    ? (authService.hasUsers == true
                          ? (authService.isAuthenticated
                                ? (settingsService.hasCompletedInitialSync
                                        ? StockInOutScreen(
                                          database: database,
                                          stockInService: stockInService,
                                          stockOutService: stockOutService,
                                          authService: authService,
                                          settingsService: settingsService,
                                          syncService: syncService,
                                          activationService: activationService,
                                        )
                                      : InitialSyncScreen(
                                          syncService: syncService,
                                        ))
                                : LoginScreen(authService: authService))
                          : ActivationScreen(
                              activationService: activationService,
                              authService: authService,
                              onActivated:
                                  () {}, // Handled by ListenableBuilder
                            ))
                    : ActivationScreen(
                        activationService: activationService,
                        authService: authService,
                        onActivated: () {}, // Handled by ListenableBuilder
                      )),
        );
      },
    );
  }
}
