import 'package:flutter/material.dart';
import 'dart:io';
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
import 'package:nexxpharma/services/device_state_manager.dart';
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

  // Suppress PDF font Unicode warnings from dart_pdf library
  final originalDebugPrint = debugPrint;
  debugPrint = (String? message, {int? wrapWidth}) {
    if (message != null &&
        (message.contains('has no Unicode support') ||
         message.contains('Fonts-Management'))) {
      return;
    }
    originalDebugPrint(message, wrapWidth: wrapWidth);
  };

  final hasInstanceLock = await _acquireSingleInstanceLock();
  if (!hasInstanceLock) {
    exit(0);
  }

  final database = AppDatabase();
  final prefs = await SharedPreferences.getInstance();

  final userService = UserService(database);
  final authService = AuthService(userService, prefs);
  final settingsService = SettingsService(prefs);
  final syncService = SyncService(database, settingsService);
  final stockInService = StockInService(database, settingsService);
  final stockOutService = StockOutService(database, settingsService);
  final notificationService = NotificationService();
  final autoUpdateService = AutoUpdateService();
  final activationService = ActivationService(
    database,
    settingsService,
    notificationService,
    authService: authService,
  );
  final connectivityService = ConnectivityService();
  
  // Initialize connectivity monitoring
  connectivityService.initialize();

  // Create device state manager to consolidate device configuration changes
  final deviceStateManager = DeviceStateManager(
    database,
    settingsService,
    activationService,
  );

  // Configure release checks and updates
  if (Platform.isWindows) {
    autoUpdateService.configure(
      owner: 'Genocadio',
      repo: 'PharmacyApp',
    );
    
    // Initialize automatic update checks
    // Checks every 5 hours and performs initial check 10 seconds after startup
    autoUpdateService.initialize(
      autoCheck: true,
      checkInterval: const Duration(hours: 5),
      checkImmediately: true,
    );
  } else if (Platform.isAndroid) {
    autoUpdateService.configure(
      owner: 'Genocadio',
      repo: 'PharmacyApp',
    );

    autoUpdateService.addListener(() {
      final announcement = autoUpdateService.takePendingAnnouncementMessage();
      if (announcement != null) {
        notificationService.showInfo(announcement);
      }
    });

    autoUpdateService.initialize(
      autoCheck: true,
      checkInterval: const Duration(hours: 6),
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
      deviceStateManager: deviceStateManager,
    ),
  );
}

RandomAccessFile? _instanceLockFile;

Future<bool> _acquireSingleInstanceLock() async {
  if (!(Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
    return true;
  }

  final lockFile = File('${Directory.systemTemp.path}/nexxpharma.lock');
  try {
    final raf = await lockFile.open(mode: FileMode.write);
    await raf.lock(FileLock.exclusive);
    _instanceLockFile = raf;
    return true;
  } on FileSystemException {
    return false;
  }
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
  final DeviceStateManager deviceStateManager;

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
    required this.deviceStateManager,
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
        deviceStateManager,
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
                                    deviceStateManager: deviceStateManager,
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
  final DeviceStateManager deviceStateManager;

  const _MainScreenWithSync({
    required this.database,
    required this.stockInService,
    required this.stockOutService,
    required this.authService,
    required this.settingsService,
    required this.syncService,
    required this.activationService,
    required this.backgroundSyncManager,
    required this.deviceStateManager,
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
    
    // Listen to auth service changes (including session warnings)
    widget.authService.addListener(_onAuthServiceChange);
  }

  void _onAuthServiceChange() {
    // Show warning if session is about to expire
    if (widget.authService.shouldShowSessionWarning) {
      final timeRemaining = widget.authService.sessionTimeRemaining ?? 0;
      final minutesRemaining = (timeRemaining / 60).ceil();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Your session will expire in $minutesRemaining minute${minutesRemaining > 1 ? 's' : ''}. '
            'Click any button or interact with the app to extend your session.',
          ),
          duration: const Duration(seconds: 6),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    widget.authService.removeListener(_onAuthServiceChange);
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
      deviceStateManager: widget.deviceStateManager,
    );
  }
}
