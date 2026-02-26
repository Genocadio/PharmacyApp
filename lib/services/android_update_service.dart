import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';

enum AndroidUpdateStatus {
  idle,
  checking,
  available,
  downloading,
  installed,
  upToDate,
  failed,
}

class AndroidUpdateService extends ChangeNotifier {
  static final AndroidUpdateService _instance = AndroidUpdateService._internal();
  factory AndroidUpdateService() => _instance;
  AndroidUpdateService._internal();

  AndroidUpdateStatus _status = AndroidUpdateStatus.idle;
  String? _error;
  AppUpdateInfo? _updateInfo;
  Timer? _checkTimer;

  AndroidUpdateStatus get status => _status;
  String? get error => _error;
  bool get isUpdateAvailable =>
      _updateInfo?.updateAvailability == UpdateAvailability.updateAvailable;

  void initialize({
    bool autoCheck = true,
    Duration checkInterval = const Duration(hours: 6),
    bool checkImmediately = false,
  }) {
    if (!Platform.isAndroid) return;

    if (checkImmediately) {
      Future.delayed(const Duration(seconds: 10), () {
        checkForUpdates(silent: true);
      });
    }

    if (autoCheck) {
      _checkTimer?.cancel();
      _checkTimer = Timer.periodic(checkInterval, (_) {
        checkForUpdates(silent: true);
      });
    }
  }

  Future<void> checkForUpdates({bool silent = false}) async {
    if (!Platform.isAndroid) return;

    if (!silent) {
      _status = AndroidUpdateStatus.checking;
      _error = null;
      notifyListeners();
    }

    try {
      _updateInfo = await InAppUpdate.checkForUpdate();

      if (_updateInfo?.updateAvailability == UpdateAvailability.updateAvailable) {
        _status = AndroidUpdateStatus.available;
      } else {
        _status = AndroidUpdateStatus.upToDate;
      }
    } catch (e) {
      _status = AndroidUpdateStatus.failed;
      _error = e.toString();
      debugPrint('Android update check failed: $e');
    }

    notifyListeners();
  }

  Future<bool> performImmediateUpdate() async {
    if (!Platform.isAndroid) return false;

    try {
      _status = AndroidUpdateStatus.downloading;
      _error = null;
      notifyListeners();

      await InAppUpdate.performImmediateUpdate();
      _status = AndroidUpdateStatus.installed;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AndroidUpdateStatus.failed;
      _error = e.toString();
      notifyListeners();
      debugPrint('Android immediate update failed: $e');
      return false;
    }
  }

  Future<bool> startFlexibleUpdate() async {
    if (!Platform.isAndroid) return false;

    try {
      _status = AndroidUpdateStatus.downloading;
      _error = null;
      notifyListeners();

      await InAppUpdate.startFlexibleUpdate();
      await InAppUpdate.completeFlexibleUpdate();

      _status = AndroidUpdateStatus.installed;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AndroidUpdateStatus.failed;
      _error = e.toString();
      notifyListeners();
      debugPrint('Android flexible update failed: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    super.dispose();
  }
}
