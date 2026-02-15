import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:nexxpharma/data/database.dart';
import 'package:nexxpharma/services/auth_service.dart';
import 'package:nexxpharma/services/auto_update_service.dart';
import 'package:nexxpharma/services/settings_service.dart';
import 'package:nexxpharma/services/user_service.dart';
import 'package:nexxpharma/services/sync_service.dart';
import 'package:nexxpharma/services/stock_in_service.dart';
import 'package:nexxpharma/services/stock_out_service.dart';
import 'package:nexxpharma/services/notification_service.dart';
import 'package:nexxpharma/services/connectivity_service.dart';
import 'package:nexxpharma/services/background_sync_manager.dart';
import 'package:nexxpharma/ui/screens/login_screen.dart';
import 'package:nexxpharma/ui/screens/stock_in_out_screen.dart';
import 'package:nexxpharma/ui/screens/activation_screen.dart';
import 'package:nexxpharma/services/activation_service.dart';
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
  final authService = AuthService(userService, prefs);
  final settingsService = SettingsService(prefs);
  final syncService = SyncService(database, settingsService);
  final stockInService = StockInService(database);
  final stockOutService = StockOutService(database);
  final notificationService = NotificationService();
  final activationService = ActivationService(
    database,
    settingsService,
    notificationService,
    authService: authService,
  );
  final connectivityService = ConnectivityService();
  
  // Initialize connectivity monitoring
  connectivityService.initialize();

  // Configure auto-update service (Windows only)
  if (Platform.isWindows) {
    AutoUpdateService().configure(
      owner: 'Genocadio',
      repo: 'PharmacyApp',
    );
    
    // Initialize automatic update checks
    // Checks every 5 hours and performs initial check 10 seconds after startup
    AutoUpdateService().initialize(
      autoCheck: true,
      checkInterval: const Duration(hours: 5),
      checkImmediately: true,
    );
  }

  // Create background sync manager
  final backgroundSyncManager = BackgroundSyncManager(
    syncService: syncService,
    activationService: activationService,
    connectivityService: connectivityService,
    settingsService: settingsService,
  );

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
      connectivityService: connectivityService,
      backgroundSyncManager: backgroundSyncManager,
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
  final ConnectivityService connectivityService;
  final BackgroundSyncManager backgroundSyncManager;

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
    required this.connectivityService,
    required this.backgroundSyncManager,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        authService,
        settingsService,
        syncService,
        activationService,
        backgroundSyncManager,
        connectivityService,
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
                                ? _MainScreenWithSync(
                                    database: database,
                                    stockInService: stockInService,
                                    stockOutService: stockOutService,
                                    authService: authService,
                                    settingsService: settingsService,
                                    syncService: syncService,
                                    activationService: activationService,
                                    backgroundSyncManager: backgroundSyncManager,
                                  )
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

/// Wrapper widget that initializes background sync and displays main screen
class _MainScreenWithSync extends StatefulWidget {
  final AppDatabase database;
  final StockInService stockInService;
  final StockOutService stockOutService;
  final AuthService authService;
  final SettingsService settingsService;
  final SyncService syncService;
  final ActivationService activationService;
  final BackgroundSyncManager backgroundSyncManager;

  const _MainScreenWithSync({
    required this.database,
    required this.stockInService,
    required this.stockOutService,
    required this.authService,
    required this.settingsService,
    required this.syncService,
    required this.activationService,
    required this.backgroundSyncManager,
  });

  @override
  State<_MainScreenWithSync> createState() => _MainScreenWithSyncState();
}

class _MainScreenWithSyncState extends State<_MainScreenWithSync> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // Initialize background sync manager when reaching main screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.backgroundSyncManager.initialize();
    });
    // Add lifecycle observer
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        // App came back to foreground - check if session is still valid
        widget.authService.checkSessionValidity().then((isValid) {
          if (!isValid) {
            // Session expired, user will be automatically logged out
            // The UI will rebuild and show login screen
            debugPrint('Session expired due to inactivity');
          }
        });
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // App went to background or is closing - session time is preserved
        // No action needed, user stays logged in
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StockInOutScreen(
      database: widget.database,
      stockInService: widget.stockInService,
      stockOutService: widget.stockOutService,
      authService: widget.authService,
      settingsService: widget.settingsService,
      syncService: widget.syncService,
      activationService: widget.activationService,
    );
  }
}
