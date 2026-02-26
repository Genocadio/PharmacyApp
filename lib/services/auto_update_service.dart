import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as path;

/// GitHub Release Information
class GitHubRelease {
  final String tagName;
  final String name;
  final String body;
  final bool prerelease;
  final bool draft;
  final DateTime publishedAt;
  final List<GitHubAsset> assets;

  GitHubRelease({
    required this.tagName,
    required this.name,
    required this.body,
    required this.prerelease,
    required this.draft,
    required this.publishedAt,
    required this.assets,
  });

  factory GitHubRelease.fromJson(Map<String, dynamic> json) {
    return GitHubRelease(
      tagName: json['tag_name'] as String,
      name: json['name'] as String,
      body: json['body'] as String? ?? '',
      prerelease: json['prerelease'] as bool,
      draft: json['draft'] as bool,
      publishedAt: DateTime.parse(json['published_at'] as String),
      assets: (json['assets'] as List<dynamic>)
          .map((asset) => GitHubAsset.fromJson(asset as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Get version without 'v' prefix (e.g., "v1.0.0" -> "1.0.0")
  String get version => tagName.startsWith('v') ? tagName.substring(1) : tagName;
}

class GitHubAsset {
  final String name;
  final String downloadUrl;
  final int size;
  final String contentType;

  GitHubAsset({
    required this.name,
    required this.downloadUrl,
    required this.size,
    required this.contentType,
  });

  factory GitHubAsset.fromJson(Map<String, dynamic> json) {
    return GitHubAsset(
      name: json['name'] as String,
      downloadUrl: json['browser_download_url'] as String,
      size: json['size'] as int,
      contentType: json['content_type'] as String? ?? 'application/octet-stream',
    );
  }
}

/// Update status
enum UpdateStatus {
  checking,
  available,
  downloading,
  readyToInstall,
  installing,
  upToDate,
  error,
  noConnection,
}

/// Service to handle release checks and updates.
/// - Windows: check + download + install
/// - Android: check + announce only
class AutoUpdateService extends ChangeNotifier {
  static final AutoUpdateService _instance = AutoUpdateService._internal();
  factory AutoUpdateService() => _instance;
  AutoUpdateService._internal();

  // GitHub repository info
  String _githubOwner = 'Genocadio';
  String _githubRepo = 'PharmacyApp';

  UpdateStatus _status = UpdateStatus.upToDate;
  String? _errorMessage;
  GitHubRelease? _latestRelease;
  String? _currentVersion;
  double _downloadProgress = 0.0;
  String? _downloadedZipPath;
  Timer? _checkTimer;
  bool _autoCheckEnabled = true;
  Duration _checkInterval = const Duration(hours: 5);  // Check every 5 hours by default
  DateTime? _lastCheckTime;
  String? _pendingAnnouncementMessage;
  String? _lastAnnouncedVersion;

  UpdateStatus get status => _status;
  String? get errorMessage => _errorMessage;
  GitHubRelease? get latestRelease => _latestRelease;
  String? get currentVersion => _currentVersion;
  double get downloadProgress => _downloadProgress;
  bool get isUpdateAvailable => _latestRelease != null && _isNewerVersion(_latestRelease!.version);
  bool get autoCheckEnabled => _autoCheckEnabled;
  Duration get checkInterval => _checkInterval;
  DateTime? get lastCheckTime => _lastCheckTime;

  String? takePendingAnnouncementMessage() {
    final message = _pendingAnnouncementMessage;
    _pendingAnnouncementMessage = null;
    return message;
  }

  /// Configure GitHub repository
  void configure({required String owner, required String repo}) {
    _githubOwner = owner;
    _githubRepo = repo;
  }

  /// Initialize automatic update checks
  void initialize({
    bool autoCheck = true,
    Duration checkInterval = const Duration(hours: 6),
    bool checkImmediately = false,
  }) {
    _autoCheckEnabled = autoCheck;
    _checkInterval = checkInterval;

    if (!(Platform.isWindows || Platform.isAndroid)) {
      debugPrint('Release checks are supported on Windows and Android only');
      return;
    }

    if (_autoCheckEnabled) {
      debugPrint('Initializing release checks with ${checkInterval.inHours}h interval');
      
      // Check immediately on startup if requested
      if (checkImmediately) {
        Future.delayed(const Duration(seconds: 10), () {
          checkForUpdates(silent: true);
        });
      }

      // Start periodic checks
      _checkTimer?.cancel();
      _checkTimer = Timer.periodic(checkInterval, (_) {
        checkForUpdates(silent: true);
      });
    }
  }

  /// Stop automatic update checks
  void stopAutoCheck() {
    _checkTimer?.cancel();
    _checkTimer = null;
    _autoCheckEnabled = false;
    debugPrint('Auto-update checks stopped');
  }

  /// Enable/disable automatic checks
  void setAutoCheckEnabled(bool enabled) {
    if (enabled && !_autoCheckEnabled) {
      initialize(autoCheck: true, checkInterval: _checkInterval);
    } else if (!enabled && _autoCheckEnabled) {
      stopAutoCheck();
    }
    notifyListeners();
  }

  /// Update check interval
  void setCheckInterval(Duration interval) {
    _checkInterval = interval;
    if (_autoCheckEnabled) {
      // Restart timer with new interval
      initialize(autoCheck: true, checkInterval: interval);
    }
    notifyListeners();
  }

  /// Check for updates
  Future<void> checkForUpdates({bool silent = false}) async {
    if (!(Platform.isWindows || Platform.isAndroid)) {
      debugPrint('Release checks are supported on Windows and Android only');
      return;
    }

    _lastCheckTime = DateTime.now();

    if (!silent) {
      _status = UpdateStatus.checking;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      // Get current version
      final packageInfo = await PackageInfo.fromPlatform();
      _currentVersion = packageInfo.version;

      // Fetch latest release from GitHub
      final url = 'https://api.github.com/repos/$_githubOwner/$_githubRepo/releases/latest';
      debugPrint('Checking for updates at: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        _latestRelease = GitHubRelease.fromJson(json);

        debugPrint('Current version: $_currentVersion');
        debugPrint('Latest version: ${_latestRelease!.version}');

        if (_isNewerVersion(_latestRelease!.version)) {
          _status = UpdateStatus.available;
          debugPrint('Update available!');

          if (Platform.isAndroid &&
              _lastAnnouncedVersion != _latestRelease!.version) {
            _pendingAnnouncementMessage =
                'New Android release ${_latestRelease!.version} is available.';
            _lastAnnouncedVersion = _latestRelease!.version;
          }
        } else {
          _status = UpdateStatus.upToDate;
          debugPrint('Already up to date');
        }
      } else {
        throw Exception('Failed to check for updates: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error checking for updates: $e');
      _status = UpdateStatus.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  /// Download the update
  Future<bool> downloadUpdate() async {
    if (!Platform.isWindows) {
      _errorMessage = 'Download/install is only supported on Windows';
      return false;
    }

    if (_latestRelease == null) {
      _errorMessage = 'No update available';
      return false;
    }

    // Find the zip asset (nexxpharma-VERSION.zip)
    final zipAsset = _latestRelease!.assets.firstWhere(
      (asset) => asset.name.endsWith('.zip') && asset.name.contains('nexxpharma'),
      orElse: () => throw Exception('Update zip file not found in release'),
    );

    _status = UpdateStatus.downloading;
    _downloadProgress = 0.0;
    _errorMessage = null;
    notifyListeners();

    try {
      // Download zip file
      final client = http.Client();
      final request = http.Request('GET', Uri.parse(zipAsset.downloadUrl));
      final response = await client.send(request);

      if (response.statusCode != 200) {
        throw Exception('Failed to download update: ${response.statusCode}');
      }

      // Save to temp directory
      final tempDir = Directory.systemTemp;
      final zipFileName = 'nexxpharma_update_${_latestRelease!.version}.zip';
      final zipFile = File(path.join(tempDir.path, zipFileName));

      final sink = zipFile.openWrite();
      final contentLength = response.contentLength ?? 0;
      int downloadedBytes = 0;

      await for (final chunk in response.stream) {
        sink.add(chunk);
        downloadedBytes += chunk.length;

        if (contentLength > 0) {
          _downloadProgress = downloadedBytes / contentLength;
          notifyListeners();
        }
      }

      await sink.close();
      client.close();

      _downloadedZipPath = zipFile.path;
      _status = UpdateStatus.readyToInstall;
      _downloadProgress = 1.0;
      notifyListeners();

      debugPrint('Update downloaded to: $_downloadedZipPath');
      return true;
    } catch (e) {
      debugPrint('Error downloading update: $e');
      _status = UpdateStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Install the update (launches PowerShell updater script)
  Future<bool> installUpdate() async {
    if (!Platform.isWindows) {
      _errorMessage = 'Download/install is only supported on Windows';
      return false;
    }

    if (_downloadedZipPath == null || !File(_downloadedZipPath!).existsSync()) {
      _errorMessage = 'Update file not found';
      return false;
    }

    _status = UpdateStatus.installing;
    notifyListeners();

    try {
      // Get installation directory (where the exe is running from)
      final exePath = Platform.resolvedExecutable;
      final installDir = path.dirname(exePath);
      final exeName = path.basename(exePath);

      // Check if PowerShell is available
      final psTestResult = await Process.run('powershell', ['-Command', 'Write-Host "test"']);
      if (psTestResult.exitCode != 0) {
        throw Exception('PowerShell is not available on this system');
      }

      // Get updater script path
      final updaterScript = path.join(installDir, 'update.ps1');
      
      if (!File(updaterScript).existsSync()) {
        throw Exception('Updater script not found at: $updaterScript');
      }

      // Get current process ID
      final processId = pid;

      // Launch updater script
      debugPrint('Launching updater script...');
      debugPrint('  Script: $updaterScript');
      debugPrint('  Zip: $_downloadedZipPath');
      debugPrint('  Install Dir: $installDir');
      debugPrint('  Process ID: $processId');

      await Process.start(
        'powershell',
        [
          '-NoProfile',
          '-ExecutionPolicy', 'Bypass',
          '-File', updaterScript,
          '-ZipPath', _downloadedZipPath!,
          '-InstallPath', installDir,
          '-ProcessId', processId.toString(),
          '-AppExeName', exeName,
        ],
        mode: ProcessStartMode.detached,
      );

      // Wait a moment to ensure the updater has started
      await Future.delayed(const Duration(milliseconds: 500));

      debugPrint('Updater script launched successfully. App will now exit.');
      
      // The updater will kill this process and relaunch after update
      // Exit the app - this never returns
      exit(0);
    } catch (e) {
      debugPrint('Error installing update: $e');
      _status = UpdateStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Check, download, and install update automatically
  Future<void> autoUpdate() async {
    await checkForUpdates(silent: true);
    
    if (isUpdateAvailable) {
      debugPrint('Auto-update: New version available, downloading...');
      final downloaded = await downloadUpdate();
      
      if (downloaded) {
        debugPrint('Auto-update: Download complete, installing...');
        // Note: User confirmation might be needed before calling installUpdate()
        // For now, we just download and notify
      }
    }
  }

  /// Compare version strings (supports semantic versioning)
  bool _isNewerVersion(String remoteVersion) {
    if (_currentVersion == null) return false;

    try {
      final current = _parseVersion(_currentVersion!);
      final remote = _parseVersion(remoteVersion);

      // Compare major.minor.patch
      for (int i = 0; i < 3; i++) {
        if (remote[i] > current[i]) return true;
        if (remote[i] < current[i]) return false;
      }

      // If we get here, major.minor.patch are equal
      // Compare build number if present
      if (remote.length > 3 && current.length > 3) {
        return remote[3] > current[3];
      }

      return false;
    } catch (e) {
      debugPrint('Error comparing versions: $e');
      return false;
    }
  }

  /// Parse version string into list of integers [major, minor, patch, build]
  List<int> _parseVersion(String version) {
    // Remove 'v' prefix if present
    version = version.startsWith('v') ? version.substring(1) : version;

    // Split by '+' to separate version from build number
    final parts = version.split('+');
    final versionPart = parts[0];
    final buildPart = parts.length > 1 ? parts[1] : '0';

    // Parse version numbers
    final versionNumbers = versionPart.split('.').map(int.parse).toList();
    
    // Ensure we have at least 3 numbers
    while (versionNumbers.length < 3) {
      versionNumbers.add(0);
    }

    // Add build number
    versionNumbers.add(int.parse(buildPart));

    return versionNumbers;
  }

  /// Reset the service state
  void reset() {
    _status = UpdateStatus.upToDate;
    _errorMessage = null;
    _latestRelease = null;
    _downloadProgress = 0.0;
    _downloadedZipPath = null;
    _pendingAnnouncementMessage = null;
    notifyListeners();
  }

  /// Cleanup when service is disposed
  @override
  void dispose() {
    _checkTimer?.cancel();
    super.dispose();
  }
}
