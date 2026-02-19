import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nexxpharma/data/database.dart';
import 'package:nexxpharma/data/tables.dart';
import 'package:nexxpharma/services/stock_in_service.dart';
import 'package:nexxpharma/services/stock_out_service.dart';
import 'package:printing/printing.dart';
import 'package:nexxpharma/services/invoice_service.dart';
import 'package:nexxpharma/services/dto/stock_out_dto.dart';
import 'package:nexxpharma/ui/widgets/compact_date_range_picker.dart';
import 'package:nexxpharma/services/dto/stock_in_dto.dart';
import 'package:nexxpharma/services/auth_service.dart';
import 'package:nexxpharma/services/settings_service.dart';
import 'package:nexxpharma/services/sync_service.dart';
import 'package:nexxpharma/services/activation_service.dart';
import 'package:nexxpharma/services/device_state_manager.dart';
import 'package:nexxpharma/ui/screens/stock_request_screen.dart';
import 'package:nexxpharma/ui/screens/catalog_screen.dart';
import 'package:nexxpharma/ui/screens/profile_screen.dart';
import 'package:nexxpharma/ui/screens/settings_screen.dart';
import 'package:nexxpharma/ui/screens/user_management_screen.dart';
import 'package:nexxpharma/ui/widgets/toast.dart';
import 'dart:typed_data';
import 'dart:ui';

class StockInOutScreen extends StatefulWidget {
  final AppDatabase database;
  final StockInService stockInService;
  final StockOutService stockOutService;
  final AuthService authService;
  final SettingsService settingsService;
  final SyncService syncService;
  final ActivationService activationService;
  final DeviceStateManager deviceStateManager;

  const StockInOutScreen({
    super.key,
    required this.database,
    required this.stockInService,
    required this.stockOutService,
    required this.authService,
    required this.settingsService,
    required this.syncService,
    required this.activationService,
    required this.deviceStateManager,
  });

  @override
  State<StockInOutScreen> createState() => _StockInOutScreenState();
}

class _StockInOutScreenState extends State<StockInOutScreen> {
  // Stock In Search State
  final TextEditingController _stockInSearchController =
      TextEditingController();
  String _stockInSearchQuery = '';
  List<StockInDTO> _allStockIn = [];
  bool _isLoading = true;
  bool _showStockInCombinedView =
      false; // Toggle between individual and combined view
  String _stockInSortColumn = 'none'; // 'none', 'stock', 'expiry'
  bool _stockInSortAscending = true; // Sort direction

  // Stock Out Search State
  final TextEditingController _stockOutSearchController =
      TextEditingController();
  String _stockOutSearchQuery = '';

  bool _isTextInputFocused() {
    final focus = FocusManager.instance.primaryFocus;
    final focusContext = focus?.context;
    if (focusContext == null) return false;
    return focusContext.widget is EditableText;
  }

  Future<ModuleInfo?> _loadModuleInfo() async {
    final moduleData = await widget.database.getModule();
    if (moduleData == null) return null;

    final paymentMethods =
        await widget.database.getPaymentMethodsByModule(moduleData.id);

    return ModuleInfo(
      name: moduleData.name,
      phone: moduleData.phone,
      email: moduleData.email,
      province: moduleData.province,
      district: moduleData.district,
      sector: moduleData.sector,
      logoUrl: moduleData.logoUrl,
      paymentMethods: paymentMethods
          .map(
            (method) => ModulePaymentMethodInfo(
              type: method.type,
              account: method.account,
              currency: method.currency,
            ),
          )
          .toList(),
    );
  }

  Future<Uint8List> _buildInvoicePdf(StockOutDTO stockOut) async {
    final moduleInfo = await _loadModuleInfo();
    return InvoiceService.generateInvoice(
      stockOut,
      widget.settingsService.invoicePaperSize,
      moduleInfo: moduleInfo,
      isWholesale:
          widget.settingsService.deviceType == DeviceType.PHARMACY_WHOLESALE,
    );
  }

  /// Check if the device supports multi-user mode
  Future<bool> _checkMultiUserSupport() async {
    try {
      final device = await widget.database.getDevice();
      return device?.supportMultiUsers ?? false;
    } catch (e) {
      debugPrint('Error checking multi-user support: $e');
      return false;
    }
  }

  Future<void> _loadStockIn() async {
    setState(() => _isLoading = true);
    try {
      final stockIn = await widget.stockInService.getAllStockIns();
      if (mounted) {
        setState(() {
          _allStockIn = stockIn;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading stock: $e')));
      }
    }
  }

  List<StockInDTO> get _filteredStockIn {
    var filtered = _allStockIn;
    if (_stockInSearchQuery.isNotEmpty) {
      filtered = _allStockIn
          .where(
            (s) =>
                s.productName.toLowerCase().contains(
                  _stockInSearchQuery.toLowerCase(),
                ) ||
                (s.batchNumber?.toLowerCase().contains(
                      _stockInSearchQuery.toLowerCase(),
                    ) ??
                    false),
          )
          .toList();
    }

    // Apply sorting based on selected column
    if (_stockInSortColumn == 'stock') {
      filtered.sort((a, b) {
        final compare = a.quantity.compareTo(b.quantity);
        return _stockInSortAscending ? compare : -compare;
      });
    } else if (_stockInSortColumn == 'expiry') {
      filtered.sort((a, b) {
        if (a.expiryDate == null && b.expiryDate == null) return 0;
        if (a.expiryDate == null) return _stockInSortAscending ? 1 : -1;
        if (b.expiryDate == null) return _stockInSortAscending ? -1 : 1;
        final compare = a.expiryDate!.compareTo(b.expiryDate!);
        return _stockInSortAscending ? compare : -compare;
      });
    }

    return filtered;
  }

  final ScrollController _horizontalHeaderScrollController = ScrollController();
  final ScrollController _horizontalBodyScrollController = ScrollController();

  // Stock Out State
  List<StockOutDTO> _stockOuts = [];
  bool _isLoadingStockOuts = false;
  bool _showStockOutNamesView = false; // Toggle between summary and names view

  // Filters
  DateTime? _stockOutFilterStartDate;
  DateTime? _stockOutFilterEndDate;
  String? _stockOutFilterInsuranceId;
  final ScrollController _stockOutHorizontalHeaderScrollController =
      ScrollController();
  final ScrollController _stockOutHorizontalBodyScrollController =
      ScrollController();

  @override
  void initState() {
    super.initState();
    _loadStockIn();
    _loadStockOuts();

    // Listen for device type, activation status, and other setting changes
    _setupChangeListeners();
    
    // Listen for session expiration to force logout
    widget.authService.addListener(_onAuthChanged);

    _horizontalHeaderScrollController.addListener(() {
      if (_horizontalHeaderScrollController.offset !=
          _horizontalBodyScrollController.offset) {
        _horizontalBodyScrollController.jumpTo(
          _horizontalHeaderScrollController.offset,
        );
      }
    });
    _horizontalBodyScrollController.addListener(() {
      if (_horizontalBodyScrollController.offset !=
          _horizontalHeaderScrollController.offset) {
        _horizontalHeaderScrollController.jumpTo(
          _horizontalBodyScrollController.offset,
        );
      }
    });

    _stockOutHorizontalHeaderScrollController.addListener(() {
      if (_stockOutHorizontalHeaderScrollController.offset !=
          _stockOutHorizontalBodyScrollController.offset) {
        _stockOutHorizontalBodyScrollController.jumpTo(
          _stockOutHorizontalHeaderScrollController.offset,
        );
      }
    });
    _stockOutHorizontalBodyScrollController.addListener(() {
      if (_stockOutHorizontalBodyScrollController.offset !=
          _stockOutHorizontalHeaderScrollController.offset) {
        _stockOutHorizontalHeaderScrollController.jumpTo(
          _stockOutHorizontalBodyScrollController.offset,
        );
      }
    });
  }

  /// Setup listeners for device configuration changes (type, activation, subtype, etc.)
  void _setupChangeListeners() {
    // Listen for device configuration changes (type, activation, subtype, etc.)
    widget.deviceStateManager.addListener(_onDeviceStateChanged);
  }

  /// Called when device state changes (type, activation status, module subtype, etc.)
  void _onDeviceStateChanged() {
    if (mounted) {
      setState(() {
        // Rebuild UI with new device state
      });
    }
  }

  /// Called when authentication state changes (session expiration)
  void _onAuthChanged() {
    if (mounted && !widget.authService.isAuthenticated) {
      // Session expired, close any open dialogs and return to login
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Future<void> _loadStockOuts() async {
    setState(() => _isLoadingStockOuts = true);
    try {
      final stockOuts = await widget.stockOutService.getAllStockOuts();
      setState(() => _stockOuts = stockOuts);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading stock outs: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoadingStockOuts = false);
    }
  }

  String _getRelativeExpiry(DateTime? expiryDate) {
    if (expiryDate == null) return '';
    final now = DateTime.now();
    final difference = expiryDate.difference(now);
    final days = difference.inDays;

    if (difference.isNegative) {
      if (days.abs() < 1) return 'Expired today';
      if (days.abs() < 30) return 'Expired ${days.abs()} days ago';
      final months = (days.abs() / 30).floor();
      if (months < 12) return 'Expired $months months ago';
      return 'Expired ${(months / 12).floor()} years ago';
    } else {
      if (days == 0) return 'Expires today';
      if (days == 1) return 'Expires tomorrow';
      if (days < 30) return 'In $days days';
      final months = (days / 30).floor();
      if (months < 12) return 'In $months months';
      final years = (months / 12).floor();
      final remainingMonths = months % 12;
      if (years >= 1) {
        return 'In $years year${years > 1 ? 's' : ''}${remainingMonths > 0 ? " $remainingMonths month${remainingMonths > 1 ? 's' : ''}" : ""}';
      }
      return 'In $months months';
    }
  }

  /// Format date contextually based on how recent it is
  String _formatContextualDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final difference = today.difference(dateOnly).inDays;

    if (difference == 0) {
      // Today - show time only
      return DateFormat('HH:mm').format(date);
    } else if (difference == 1) {
      // Yesterday - show relative hours
      final hoursDiff = now.difference(date).inHours;
      return '$hoursDiff hrs ago';
    } else if (difference >= 2 && difference <= 6) {
      // This week - show day name
      return DateFormat('EEEE').format(date);
    } else {
      // Older - show date
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }

  /// Format time contextually for secondary display
  String _formatContextualTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final difference = today.difference(dateOnly).inDays;

    if (difference == 0) {
      // Today - show "Today"
      return 'Today';
    } else if (difference == 1) {
      // Yesterday - show time
      return DateFormat('HH:mm').format(date);
    } else if (difference >= 2 && difference <= 6) {
      // This week - show time
      return DateFormat('HH:mm').format(date);
    } else {
      // Older - show time
      return DateFormat('HH:mm').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.primary;

    return GestureDetector(
      onTap: () => widget.authService.updateActivity(),
      onPanUpdate: (_) => widget.authService.updateActivity(),
      child: DefaultTabController(
        length: 2,
        child: Builder(
          builder: (context) {
            final tabController = DefaultTabController.of(context);
            return Focus(
              autofocus: true,
              onKeyEvent: (node, event) {
                if (_isTextInputFocused()) {
                  return KeyEventResult.ignored;
                }
                if (event.logicalKey == LogicalKeyboardKey.arrowLeft &&
                    event is KeyDownEvent) {
                  final nextIndex = (tabController.index) - 1;
                  if (nextIndex >= 0) {
                    tabController.animateTo(nextIndex);
                    return KeyEventResult.handled;
                  }
                }
                if (event.logicalKey == LogicalKeyboardKey.arrowRight &&
                    event is KeyDownEvent) {
                  final nextIndex = (tabController.index) + 1;
                  if (nextIndex <= 1) {
                    tabController.animateTo(nextIndex);
                    return KeyEventResult.handled;
                  }
                }
                return KeyEventResult.ignored;
              },
              child: Scaffold(
                body: SafeArea(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: theme.brightness == Brightness.light
                              ? theme.scaffoldBackgroundColor
                              : theme.cardColor,
                          border: Border(
                            bottom: BorderSide(
                              color: theme.dividerColor.withOpacity(0.1),
                            ),
                          ),
                        ),
                        child: TabBar(
                          indicator: UnderlineTabIndicator(
                            borderSide: BorderSide(
                              color: accentColor,
                              width: 3,
                            ),
                          ),
                          labelColor: accentColor,
                          unselectedLabelColor: theme.brightness == Brightness.light
                              ? Colors.grey.shade600
                              : Colors.grey.shade400,
                          tabs: [
                            Tab(
                              text: 'Stock In',
                              icon: Padding(
                                padding: EdgeInsets.only(bottom: 4),
                                child: Icon(Icons.inventory_2, size: 20),
                              ),
                            ),
                            Tab(
                              text: 'Stock Out',
                              icon: Padding(
                                padding: EdgeInsets.only(bottom: 4),
                                child: Icon(Icons.receipt_long, size: 20),
                              ),
                            ),
                          ],
                          labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildStockInTab(theme, accentColor),
                            _buildStockOutTab(theme, accentColor),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
                floatingActionButton: _buildMacDock(theme, accentColor),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStockInTab(ThemeData theme, Color accentColor) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 80), // Space for dock
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // View Toggle Button
                      IconButton(
                        icon: Icon(
                          _showStockInCombinedView
                              ? Icons.list
                              : Icons.view_compact,
                          size: 20,
                        ),
                        tooltip: _showStockInCombinedView
                            ? 'Individual View'
                            : 'Combined View',
                        onPressed: () => setState(
                          () => _showStockInCombinedView =
                              !_showStockInCombinedView,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 300),
                        child: TextField(
                          controller: _stockInSearchController,
                          decoration: InputDecoration(
                            hintText: 'Search products...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _stockInSearchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _stockInSearchController.clear();
                                      setState(() => _stockInSearchQuery = '');
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: theme.brightness == Brightness.light
                                ? Colors.black.withOpacity(0.04)
                                : Colors.white.withOpacity(0.04),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          onChanged: (value) =>
                              setState(() => _stockInSearchQuery = value),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_filteredStockIn.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: theme.dividerColor.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _stockInSearchQuery.isEmpty
                              ? 'No stock in items found.'
                              : 'No matches for "$_stockInSearchQuery"',
                          style: TextStyle(color: theme.dividerColor),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_showStockInCombinedView)
                _buildStockInCombinedView(theme, accentColor, constraints)
              else ...[
                // Fixed Header
                SingleChildScrollView(
                  controller: _horizontalHeaderScrollController,
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: Theme(
                      data: theme.copyWith(dividerColor: Colors.transparent),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: theme.dividerColor.withOpacity(0.2),
                              width: 2,
                            ),
                          ),
                        ),
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(
                            theme.brightness == Brightness.light
                                ? Colors.grey.shade100
                                : Colors.grey.shade800,
                          ),
                          columnSpacing: 16,
                          horizontalMargin: 16,
                          dataRowColor: MaterialStateProperty.all(
                            Colors.transparent,
                          ),
                          columns: _buildColumns(),
                          rows: const [],
                        ),
                      ),
                    ),
                  ),
                ),
                // Scrollable Body
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      controller: _horizontalBodyScrollController,
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: constraints.maxWidth,
                        ),
                        child: Theme(
                          data: theme.copyWith(
                            dividerColor: theme.dividerColor.withOpacity(0.1),
                          ),
                          child: DataTable(
                            headingRowHeight: 0,
                            columnSpacing: 16,
                            horizontalMargin: 16,
                            dataRowColor: MaterialStateProperty.resolveWith((
                              states,
                            ) {
                              if (states.contains(MaterialState.hovered)) {
                                return theme.colorScheme.primary.withOpacity(
                                  0.05,
                                );
                              }
                              return Colors.transparent;
                            }),
                            dividerThickness: 1,
                            columns: _buildColumns(),
                            rows: _filteredStockIn.map((stock) {
                              return _buildDataRow(stock, theme, accentColor);
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildStockOutTab(ThemeData theme, Color accentColor) {
    if (_isLoadingStockOuts) {
      return const Center(child: CircularProgressIndicator());
    }

    final deviceType = widget.settingsService.deviceType;

    final filteredStockOuts = _stockOuts.where((stockOut) {
      // 1. Search Query Filter
      bool matchesQuery = true;
      if (_stockOutSearchQuery.isNotEmpty) {
        final query = _stockOutSearchQuery.toLowerCase();
        final matchesPatient = stockOut.patientName.toLowerCase().contains(
          query,
        );
        final matchesProduct = stockOut.stockOutItems.any(
          (item) => item.productName.toLowerCase().contains(query),
        );
        matchesQuery = matchesPatient || matchesProduct;
      }

      // 2. Date Range Filter
      bool matchesDate = true;
      if (_stockOutFilterStartDate != null && _stockOutFilterEndDate != null) {
        // Create end of day for end date to be inclusive
        final endDate = DateTime(
          _stockOutFilterEndDate!.year,
          _stockOutFilterEndDate!.month,
          _stockOutFilterEndDate!.day,
          23,
          59,
          59,
        );
        matchesDate =
            stockOut.createdAt.isAfter(
              _stockOutFilterStartDate!.subtract(const Duration(seconds: 1)),
            ) &&
            stockOut.createdAt.isBefore(endDate);
      }

      // 3. Insurance Filter (only for pharmacy modes)
      bool matchesInsurance = true;
      if (deviceType != DeviceType.CLINIC_INVENTORY &&
          _stockOutFilterInsuranceId != null) {
        matchesInsurance = stockOut.stockOutItems.any(
          (i) => i.insuranceId == _stockOutFilterInsuranceId,
        );
      }

      return matchesQuery && matchesDate && matchesInsurance;
    }).toList();

    return Column(
      children: [
        // Inline Filters Header
        Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // View Toggle Button (Icon Only)
                IconButton(
                  icon: Icon(
                    _showStockOutNamesView ? Icons.list : Icons.table_chart,
                    size: 20,
                  ),
                  tooltip: _showStockOutNamesView
                      ? 'Summary View'
                      : 'Items View',
                  onPressed: () => setState(
                    () => _showStockOutNamesView = !_showStockOutNamesView,
                  ),
                ),
                const SizedBox(width: 8),
                // Search Field
                Container(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: TextField(
                    controller: _stockOutSearchController,
                    onChanged: (value) =>
                        setState(() => _stockOutSearchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Search sales...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _stockOutSearchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _stockOutSearchController.clear();
                                setState(() => _stockOutSearchQuery = '');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: theme.brightness == Brightness.light
                          ? Colors.black.withOpacity(0.04)
                          : Colors.white.withOpacity(0.04),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Date Filter
                InkWell(
                  onTap: () async {
                    final picked = await showDialog<DateTimeRange>(
                      context: context,
                      builder: (context) => CompactDateRangePicker(
                        initialStartDate: _stockOutFilterStartDate,
                        initialEndDate: _stockOutFilterEndDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      ),
                    );

                    if (picked != null) {
                      setState(() {
                        _stockOutFilterStartDate = picked.start;
                        _stockOutFilterEndDate = picked.end;
                      });
                    }
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.light
                          ? theme.scaffoldBackgroundColor
                          : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: (_stockOutFilterStartDate != null)
                            ? accentColor
                            : theme.dividerColor.withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: (_stockOutFilterStartDate != null)
                              ? accentColor
                              : theme.iconTheme.color,
                        ),
                        if (_stockOutFilterStartDate != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            _stockOutFilterStartDate!.year ==
                                        _stockOutFilterEndDate!.year &&
                                    _stockOutFilterStartDate!.month ==
                                        _stockOutFilterEndDate!.month &&
                                    _stockOutFilterStartDate!.day ==
                                        _stockOutFilterEndDate!.day
                                ? DateFormat(
                                    'MMM dd',
                                  ).format(_stockOutFilterStartDate!)
                                : '${DateFormat('MMM dd').format(_stockOutFilterStartDate!)} - ${DateFormat('MMM dd').format(_stockOutFilterEndDate!)}',
                            style: TextStyle(
                              fontSize: 13,
                              color: accentColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (_stockOutFilterStartDate != null) ...[
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () => setState(() {
                      _stockOutFilterStartDate = null;
                      _stockOutFilterEndDate = null;
                    }),
                  ),
                ],
                if (deviceType != DeviceType.CLINIC_INVENTORY) ...[
                  const SizedBox(width: 16),
                  // Insurance Filter (only for pharmacy modes)
                  FutureBuilder<List<Insurance>>(
                    future: widget.database.getAllInsurances(),
                    builder: (context, snapshot) {
                      final insurances = snapshot.data ?? [];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: theme.brightness == Brightness.light
                              ? theme.scaffoldBackgroundColor
                              : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: (_stockOutFilterInsuranceId != null)
                                ? accentColor
                                : theme.dividerColor.withOpacity(0.1),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String?>(
                            value: _stockOutFilterInsuranceId,
                            hint: const Text(
                              'Insurance',
                              style: TextStyle(fontSize: 13),
                            ),
                            icon: Icon(
                              Icons.shield_outlined,
                              size: 16,
                              color: (_stockOutFilterInsuranceId != null)
                                  ? accentColor
                                  : null,
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('All'),
                              ),
                              ...insurances.map(
                                (i) => DropdownMenuItem(
                                  value: i.id,
                                  child: Text(i.acronym),
                                ),
                              ),
                            ],
                            onChanged: (value) => setState(
                              () => _stockOutFilterInsuranceId = value,
                            ),
                            style: TextStyle(
                              fontSize: 13,
                              color: (_stockOutFilterInsuranceId != null)
                                  ? accentColor
                                  : theme.textTheme.bodyMedium?.color,
                              fontWeight: (_stockOutFilterInsuranceId != null)
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),

        Expanded(
          child: filteredStockOuts.isEmpty
              ? _buildEmptyStockOutState(theme)
              : _showStockOutNamesView
              ? _buildStockOutNamesView(
                  theme,
                  accentColor,
                  filteredStockOuts,
                  context,
                )
              : _buildStockOutTable(
                  theme,
                  accentColor,
                  filteredStockOuts,
                  context,
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyStockOutState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: theme.dividerColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            _stockOutSearchQuery.isEmpty &&
                    _stockOutFilterStartDate == null &&
                    _stockOutFilterInsuranceId == null
                ? 'No stock outs recorded yet.'
                : 'No matches found',
            style: TextStyle(color: theme.dividerColor),
          ),
        ],
      ),
    );
  }

  Widget _buildStockOutTable(
    ThemeData theme,
    Color accentColor,
    List<StockOutDTO> filteredStockOuts,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 80), // Space for dock
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Fixed Header
              SingleChildScrollView(
                controller: _stockOutHorizontalHeaderScrollController,
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: Theme(
                    data: theme.copyWith(dividerColor: Colors.transparent),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: theme.dividerColor.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                      ),
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(
                          theme.brightness == Brightness.light
                              ? Colors.grey.shade100
                              : Colors.grey.shade800,
                        ),
                        columnSpacing: 16,
                        horizontalMargin: 16,
                        dataRowColor: MaterialStateProperty.all(
                          Colors.transparent,
                        ),
                        columns: _buildStockOutColumns(),
                        rows: const [],
                      ),
                    ),
                  ),
                ),
              ),
              // Scrollable Body
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    controller: _stockOutHorizontalBodyScrollController,
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth,
                      ),
                      child: Theme(
                        data: theme.copyWith(
                          dividerColor: theme.dividerColor.withOpacity(0.1),
                        ),
                        child: DataTable(
                          headingRowHeight: 0,
                          columnSpacing: 16,
                          horizontalMargin: 16,
                          dataRowColor: MaterialStateProperty.resolveWith((
                            states,
                          ) {
                            if (states.contains(MaterialState.hovered)) {
                              return theme.colorScheme.primary.withOpacity(
                                0.05,
                              );
                            }
                            return Colors.transparent;
                          }),
                          dividerThickness: 1,
                          columns: _buildStockOutColumns(),
                          rows: filteredStockOuts.map((stockOut) {
                            return _buildStockOutDataRow(
                              stockOut,
                              theme,
                              accentColor,
                              context,
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<DataColumn> _buildStockOutColumns() {
    final deviceType = widget.settingsService.deviceType;
    final isClinic = deviceType == DeviceType.CLINIC_INVENTORY;
    final isWholesale = deviceType == DeviceType.PHARMACY_WHOLESALE;

    return [
      const DataColumn(label: _HeaderCell('Date')),
      DataColumn(
        label: _HeaderCell(
          isClinic
              ? 'Receiving Service'
              : isWholesale
              ? 'Destination'
              : 'Patient',
        ),
      ),
      const DataColumn(label: _HeaderCell('Items')),
      if (!isClinic)
        const DataColumn(label: _HeaderCell('Total Price'), numeric: true),
      DataColumn(
        label: _HeaderCell(
          isClinic || isWholesale ? 'Dispatched By' : 'Sold By',
        ),
      ),
      if (!isClinic) const DataColumn(label: _HeaderCell('Invoice')),
    ];
  }

  DataRow _buildStockOutDataRow(
    StockOutDTO stockOut,
    ThemeData theme,
    Color accentColor,
    BuildContext context,
  ) {
    final deviceType = widget.settingsService.deviceType;
    final isClinic = deviceType == DeviceType.CLINIC_INVENTORY;
    final dateStr = _formatContextualDate(stockOut.createdAt);
    final timeStr = _formatContextualTime(stockOut.createdAt);

    // Calculate split totals
    double patientTotal = 0.0;
    double insuranceTotal = 0.0;
    String? insuranceName;

    for (var item in stockOut.stockOutItems) {
      if (item.insuranceId != null) {
        insuranceName = item.insuranceName;
      }
      patientTotal += item.patientPays;
      insuranceTotal += item.insurancePays;
    }

    // Hover for Items
    final itemsListString = stockOut.stockOutItems
        .map((i) {
          final names = i.productName
              .split(' || ')
              .map((e) => e.trim())
              .toList();
          final displayName = names.join(' / ');
          return '$displayName (${i.quantitySold}) - ${NumberFormat.currency(symbol: 'RF ', decimalDigits: 0).format(i.itemTotal)}';
        })
        .join('\n');

    // Hover for Patient
    String patientTooltip = stockOut.patientName;
    if (stockOut.insuranceCardNumber != null) {
      patientTooltip += '\nInsurance Card: ${stockOut.insuranceCardNumber}';
      patientTooltip += '\n${stockOut.issuingCompany ?? ""}';
      if (stockOut.prescriberName != null) {
        patientTooltip += '\nPrescriber: ${stockOut.prescriberName}';
      }
    } else if (insuranceName != null) {
      patientTooltip += '\nInsurance: $insuranceName';
    }

    return DataRow(
      cells: [
        // Date column
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                dateStr,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                timeStr,
                style: TextStyle(
                  fontSize: 10,
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
        // Patient/Receiving Service/Destination column
        DataCell(
          Tooltip(
            message: patientTooltip,
            child: Text(
              isClinic && stockOut.destinationClinicService != null
                  ? _formatClinicServiceFromString(
                      stockOut.destinationClinicService!,
                    )
                  : stockOut.patientName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        // Items column
        DataCell(
          InkWell(
            onTap: () {
              final displayName =
                  isClinic && stockOut.destinationClinicService != null
                  ? _formatClinicServiceFromString(
                      stockOut.destinationClinicService!,
                    )
                  : stockOut.patientName;
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Items for $displayName'),
                  content: SingleChildScrollView(child: Text(itemsListString)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
            child: Tooltip(
              message: itemsListString,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${stockOut.stockOutItems.length} items'),
                  const SizedBox(width: 4),
                  const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
        // Total Price column (only for non-clinic modes)
        if (!isClinic)
          DataCell(
            insuranceTotal > 0
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Patient: ${NumberFormat.currency(symbol: 'RF ', decimalDigits: 0).format(patientTotal)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        '${insuranceName ?? 'Insurance'}: ${NumberFormat.currency(symbol: 'RF ', decimalDigits: 0).format(insuranceTotal)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  )
                : Text(
                    NumberFormat.currency(
                      symbol: 'RF ',
                      decimalDigits: 0,
                    ).format(stockOut.totalPrice),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
          ),
        // Dispatched By/Sold By column
        DataCell(
          Text(
            stockOut.userId == widget.authService.currentUser?.id
                ? 'You'
                : (stockOut.userName ?? 'Unknown'),
            style: TextStyle(
              fontWeight: stockOut.userId == widget.authService.currentUser?.id
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: stockOut.userId == widget.authService.currentUser?.id
                  ? accentColor
                  : theme.textTheme.bodyMedium?.color,
            ),
          ),
        ),
        // Invoice column (only for non-clinic modes)
        if (!isClinic)
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.description_outlined),
                  tooltip: 'View Invoice',
                  onPressed: () async {
                    if (mounted) {
                      final size = MediaQuery.sizeOf(context);
                      showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                            insetPadding: const EdgeInsets.all(20),
                            child: SizedBox(
                              width: size.width * 0.9,
                              height: size.height * 0.85,
                              child: FutureBuilder<Uint8List>(
                                future: _buildInvoicePdf(stockOut),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  if (snapshot.hasError) {
                                    return Center(
                                      child: Text('Error generating PDF: ${snapshot.error}'),
                                    );
                                  }
                                  if (!snapshot.hasData) {
                                    return const Center(child: Text('No PDF data'));
                                  }
                                  return PdfPreview(
                                    build: (format) async => snapshot.data!,
                                    canChangePageFormat: false,
                                    canChangeOrientation: false,
                                    canDebug: false,
                                    actions: const [],
                                    pdfFileName: 'invoice.pdf',
                                    maxPageWidth: 700,
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.print_outlined),
                  tooltip: 'Print Invoice',
                  onPressed: () async {
                    final pdfBytes = await _buildInvoicePdf(stockOut);
                    await Printing.layoutPdf(
                      onLayout: (format) async => pdfBytes,
                    );
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStockOutNamesView(
    ThemeData theme,
    Color accentColor,
    List<StockOutDTO> filteredStockOuts,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Fixed Header
              SingleChildScrollView(
                controller: _stockOutHorizontalHeaderScrollController,
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: Theme(
                    data: theme.copyWith(dividerColor: Colors.transparent),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: theme.dividerColor.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                      ),
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(
                          theme.brightness == Brightness.light
                              ? Colors.grey.shade100
                              : Colors.grey.shade800,
                        ),
                        columnSpacing: 32,
                        horizontalMargin: 16,
                        dataRowColor: MaterialStateProperty.all(
                          Colors.transparent,
                        ),
                        columns: _buildItemsViewColumns(),
                        rows: const [],
                      ),
                    ),
                  ),
                ),
              ),
              // Scrollable Body
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    controller: _stockOutHorizontalBodyScrollController,
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth,
                      ),
                      child: Theme(
                        data: theme.copyWith(
                          dividerColor: theme.dividerColor.withOpacity(0.1),
                        ),
                        child: DataTable(
                          headingRowHeight: 0,
                          columnSpacing: 32,
                          horizontalMargin: 16,
                          dataRowColor: MaterialStateProperty.resolveWith((
                            states,
                          ) {
                            if (states.contains(MaterialState.hovered)) {
                              return theme.colorScheme.primary.withOpacity(
                                0.05,
                              );
                            }
                            return Colors.transparent;
                          }),
                          dividerThickness: 1,
                          columns: _buildItemsViewColumns(),
                          rows: _buildItemsViewRows(
                            filteredStockOuts,
                            theme,
                            accentColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<DataColumn> _buildItemsViewColumns() {
    final deviceType = widget.settingsService.deviceType;
    final isClinic = deviceType == DeviceType.CLINIC_INVENTORY;
    final isWholesale = deviceType == DeviceType.PHARMACY_WHOLESALE;

    return [
      const DataColumn(label: Text('Date')),
      DataColumn(
        label: Text(
          isClinic
              ? 'Service'
              : isWholesale
              ? 'Destination'
              : 'Patient',
        ),
      ),
      const DataColumn(label: Text('Product Name')),
      const DataColumn(label: Text('Qty')),
      if (!isClinic) const DataColumn(label: Text('Unit Price')),
      if (!isClinic) const DataColumn(label: Text('Total')),
      DataColumn(
        label: Text(isClinic || isWholesale ? 'Dispatched By' : 'Sold By'),
      ),
    ];
  }

  List<DataRow> _buildItemsViewRows(
    List<StockOutDTO> filteredStockOuts,
    ThemeData theme,
    Color accentColor,
  ) {
    final deviceType = widget.settingsService.deviceType;
    final isClinic = deviceType == DeviceType.CLINIC_INVENTORY;

    final rows = <DataRow>[];

    for (final stockOut in filteredStockOuts) {
      final dateStr = _formatContextualDate(stockOut.createdAt);
      final serviceOrRecipient =
          isClinic && stockOut.destinationClinicService != null
          ? _formatClinicServiceFromString(stockOut.destinationClinicService!)
          : stockOut.patientName;
      final userName = stockOut.userId == widget.authService.currentUser?.id
          ? 'You'
          : (stockOut.userName ?? 'Unknown');

      // Group items by product name to consolidate quantities
      final groupedItems = <String, Map<String, dynamic>>{};
      for (final item in stockOut.stockOutItems) {
        if (groupedItems.containsKey(item.productName)) {
          groupedItems[item.productName]!['quantity'] += item.quantitySold;
          groupedItems[item.productName]!['total'] += item.itemTotal;
          groupedItems[item.productName]!['items'].add(item);
        } else {
          groupedItems[item.productName] = {
            'quantity': item.quantitySold,
            'price': item.pricePerUnit,
            'total': item.itemTotal,
            'items': [item],
          };
        }
      }

      // Create rows from grouped items
      for (final entry in groupedItems.entries) {
        final productName = entry.key;
        final itemData = entry.value;
        final items = itemData['items'] as List<StockOutItemDTO>;

        // Build batch details for tooltip
        final batchDetails = items
            .map((item) {
              return 'Batch: ${item.batchNumber ?? 'N/A'} | Qty: ${item.quantitySold} | Location: ${item.location ?? 'N/A'}';
            })
            .join('\\n');

        final names = productName.split(' || ').map((e) => e.trim()).toList();
        final primaryName = names[0];
        final otherNames = names.length > 1
            ? names.sublist(1).join(', ')
            : null;

        rows.add(
          DataRow(
            cells: [
              DataCell(Text(dateStr)),
              DataCell(
                Text(
                  serviceOrRecipient,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              DataCell(
                Tooltip(
                  message: batchDetails,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        primaryName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (otherNames != null)
                        Text(
                          otherNames,
                          style: TextStyle(
                            fontSize: 10,
                            color: theme.textTheme.bodySmall?.color
                                ?.withOpacity(0.5),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              DataCell(Text('${itemData['quantity']}')),
              if (!isClinic)
                DataCell(
                  Text(
                    NumberFormat.currency(
                      symbol: 'RF ',
                      decimalDigits: 0,
                    ).format(itemData['price']),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              if (!isClinic)
                DataCell(
                  Text(
                    NumberFormat.currency(
                      symbol: 'RF ',
                      decimalDigits: 0,
                    ).format(itemData['total']),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ),
              DataCell(
                Text(
                  userName,
                  style: TextStyle(
                    fontWeight: userName == 'You'
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: userName == 'You' ? accentColor : null,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }

    return rows;
  }

  /// Format clinic service string from database to display name
  String _formatClinicServiceFromString(String serviceStr) {
    switch (serviceStr) {
      case 'DENTAL':
        return 'Dental';
      case 'INTERNAL_MEDICINE':
        return 'Internal Medicine';
      case 'LABORATORY':
        return 'Laboratory';
      case 'SURGERY':
        return 'Surgery';
      case 'PEDIATRICS':
        return 'Pediatrics';
      case 'CARDIOLOGY':
        return 'Cardiology';
      case 'ORTHOPEDICS':
        return 'Orthopedics';
      default:
        return serviceStr;
    }
  }

  Widget _buildMacDock(ThemeData theme, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.light
            ? Colors.white.withOpacity(0.3)
            : Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Stack(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDockButton(
                    icon: Icons.add_shopping_cart,
                    label: 'Add Sale',
                    color: Colors.green,
                    onPressed: _showProcessSaleFlow,
                    theme: theme,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 1,
                    height: 30,
                    color: theme.dividerColor.withOpacity(0.2),
                  ),
                  const SizedBox(width: 8),
                  _buildDockButton(
                    icon: Icons.add_business,
                    label: 'Add Stock',
                    color: accentColor,
                    onPressed: _showAddStockFlow,
                    theme: theme,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 1,
                    height: 30,
                    color: theme.dividerColor.withOpacity(0.2),
                  ),
                  const SizedBox(width: 8),
                  _buildUserAvatar(theme, accentColor),
                ],
              ),
              // Grainy mesh overlay
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.1),
                          Colors.transparent,
                          Colors.white.withOpacity(0.05),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
              // Additional noise-like layer
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.0,
                        colors: [
                          Colors.white.withOpacity(0.03),
                          Colors.transparent,
                          Colors.black.withOpacity(0.02),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserAvatar(ThemeData theme, Color accentColor) {
    final user = widget.authService.currentUser;
    final initials = user?.names.isNotEmpty == true
        ? user!.names.split(' ').take(2).map((e) => e[0].toUpperCase()).join()
        : '?';

    return Material(
      color: Colors.transparent,
      child: FutureBuilder<bool>(
        future: _checkMultiUserSupport(),
        builder: (context, supportSnapshot) {
          final supportsMultiUser = supportSnapshot.data ?? false;
          return PopupMenuButton<String>(
            offset: const Offset(0, -200),
            tooltip: 'User Menu',
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'catalog',
                child: Row(
                  children: [
                    Icon(Icons.menu_book, color: accentColor, size: 20),
                    const SizedBox(width: 12),
                    const Text('Product Catalog'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'stock_requests',
                child: Row(
                  children: [
                    Icon(Icons.inventory, color: accentColor, size: 20),
                    const SizedBox(width: 12),
                    const Text('Stock Requests'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, color: accentColor, size: 20),
                    const SizedBox(width: 12),
                    const Text('Settings'),
                  ],
                ),
              ),
              if (supportsMultiUser && user?.role == UserRole.Manager)
                PopupMenuItem<String>(
                  value: 'user_management',
                  child: Row(
                    children: [
                      Icon(Icons.people_outline, color: accentColor, size: 20),
                      const SizedBox(width: 12),
                      const Text('User Management'),
                    ],
                  ),
                ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, color: accentColor, size: 20),
                    const SizedBox(width: 12),
                    const Text('Profile'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red, size: 20),
                    const SizedBox(width: 12),
                    const Text('Logout', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (String value) async {
              switch (value) {
                case 'catalog':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CatalogScreen(
                        database: widget.database,
                        authService: widget.authService,
                      ),
                    ),
                  );
                  break;
                case 'stock_requests':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StockRequestScreen(
                        database: widget.database,
                        authService: widget.authService,
                      ),
                    ),
                  );
                  break;
                case 'settings':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingsScreen(
                        settingsService: widget.settingsService,
                        syncService: widget.syncService,
                        activationService: widget.activationService,
                        authService: widget.authService,
                      ),
                    ),
                  );
                  break;
                case 'user_management':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserManagementScreen(
                        authService: widget.authService,
                        database: widget.database,
                      ),
                    ),
                  );
                  break;
                case 'profile':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProfileScreen(authService: widget.authService),
                    ),
                  );
                  break;
                case 'logout':
                  await widget.authService.logout();
                  break;
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: accentColor,
                    foregroundColor: theme.colorScheme.onPrimary,
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDockButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    required ThemeData theme,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStockInCombinedView(
    ThemeData theme,
    Color accentColor,
    BoxConstraints constraints,
  ) {
    // Group stocks by productId
    final groupedStocks = <String, List<StockInDTO>>{};
    for (final stock in _filteredStockIn) {
      if (!groupedStocks.containsKey(stock.productId)) {
        groupedStocks[stock.productId] = [];
      }
      groupedStocks[stock.productId]!.add(stock);
    }

    // Create combined DTOs
    final combinedStocks = groupedStocks.entries.map((entry) {
      final stocks = entry.value;

      // Find closest to expire stock
      StockInDTO? closestToExpire;
      for (final stock in stocks) {
        if (stock.expiryDate != null) {
          if (closestToExpire == null ||
              stock.expiryDate!.isBefore(closestToExpire.expiryDate!)) {
            closestToExpire = stock;
          }
        }
      }

      // If no stock has expiry, use first stock
      final referenceStock = closestToExpire ?? stocks.first;

      // Calculate total quantity
      final totalQuantity = stocks.fold<int>(0, (sum, s) => sum + s.quantity);

      return {
        'reference': referenceStock,
        'stocks': stocks,
        'totalQuantity': totalQuantity,
      };
    }).toList();

    // Apply sorting to combined view
    if (_stockInSortColumn == 'stock') {
      combinedStocks.sort((a, b) {
        final aQty = a['totalQuantity'] as int;
        final bQty = b['totalQuantity'] as int;
        final compare = aQty.compareTo(bQty);
        return _stockInSortAscending ? compare : -compare;
      });
    } else if (_stockInSortColumn == 'expiry') {
      combinedStocks.sort((a, b) {
        final aRef = a['reference'] as StockInDTO;
        final bRef = b['reference'] as StockInDTO;
        if (aRef.expiryDate == null && bRef.expiryDate == null) return 0;
        if (aRef.expiryDate == null) return _stockInSortAscending ? 1 : -1;
        if (bRef.expiryDate == null) return _stockInSortAscending ? -1 : 1;
        final compare = aRef.expiryDate!.compareTo(bRef.expiryDate!);
        return _stockInSortAscending ? compare : -compare;
      });
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Column(
          children: [
            // Fixed Header
            SingleChildScrollView(
              controller: _horizontalHeaderScrollController,
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: Theme(
                  data: theme.copyWith(dividerColor: Colors.transparent),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: theme.dividerColor.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                    ),
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(
                        theme.brightness == Brightness.light
                            ? Colors.grey.shade100
                            : Colors.grey.shade800,
                      ),
                      columnSpacing: 16,
                      horizontalMargin: 16,
                      dataRowColor: MaterialStateProperty.all(
                        Colors.transparent,
                      ),
                      columns: _buildCombinedViewColumns(),
                      rows: const [],
                    ),
                  ),
                ),
              ),
            ),
            // Scrollable Body
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  controller: _horizontalBodyScrollController,
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: Theme(
                      data: theme.copyWith(
                        dividerColor: theme.dividerColor.withOpacity(0.1),
                      ),
                      child: DataTable(
                        headingRowHeight: 0,
                        columnSpacing: 16,
                        horizontalMargin: 16,
                        dataRowColor: MaterialStateProperty.resolveWith((
                          states,
                        ) {
                          if (states.contains(MaterialState.hovered)) {
                            return theme.colorScheme.primary.withOpacity(0.05);
                          }
                          return Colors.transparent;
                        }),
                        dividerThickness: 1,
                        columns: _buildCombinedViewColumns(),
                        rows: combinedStocks.map((item) {
                          return _buildCombinedViewDataRow(
                            item['reference'] as StockInDTO,
                            item['stocks'] as List<StockInDTO>,
                            item['totalQuantity'] as int,
                            theme,
                            accentColor,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DataColumn> _buildCombinedViewColumns() {
    final isClinicMode =
        widget.settingsService.deviceType == DeviceType.CLINIC_INVENTORY;

    return [
      const DataColumn(label: _HeaderCell('Product Name')),
      DataColumn(
        label: _SortableHeaderCell(
          label: 'Total Units',
          sortBy: 'stock',
          currentSort: _stockInSortColumn,
          isAscending: _stockInSortAscending,
          onSort: (column) {
            setState(() {
              if (_stockInSortColumn == column) {
                _stockInSortAscending = !_stockInSortAscending;
              } else {
                _stockInSortColumn = column;
                _stockInSortAscending = true;
              }
            });
          },
        ),
        numeric: true,
      ),
      if (!isClinicMode)
        const DataColumn(label: _HeaderCell('Price/Unit'), numeric: true),
      DataColumn(
        label: _SortableHeaderCell(
          label: 'Expiration Date',
          sortBy: 'expiry',
          currentSort: _stockInSortColumn,
          isAscending: _stockInSortAscending,
          onSort: (column) {
            setState(() {
              if (_stockInSortColumn == column) {
                _stockInSortAscending = !_stockInSortAscending;
              } else {
                _stockInSortColumn = column;
                _stockInSortAscending = true;
              }
            });
          },
        ),
      ),
      const DataColumn(label: _HeaderCell('Batches')),
    ];
  }

  DataRow _buildCombinedViewDataRow(
    StockInDTO referenceStock,
    List<StockInDTO> allStocks,
    int totalQuantity,
    ThemeData theme,
    Color accentColor,
  ) {
    final isClinicMode =
        widget.settingsService.deviceType == DeviceType.CLINIC_INVENTORY;
    final names = referenceStock.productName
        .split(' || ')
        .map((e) => e.trim())
        .toList();
    final primaryName = names[0];
    final otherNames = names.length > 1 ? names.sublist(1).join(', ') : null;

    // Build hover overlay showing all batches
    final batchDetails = allStocks
        .map((stock) {
          return 'Batch: ${stock.batchNumber ?? 'N/A'} | Units: ${stock.quantity} | Price: RF ${stock.pricePerUnit.toStringAsFixed(0)} | Expiry: ${stock.expiryDate != null ? DateFormat('MMM dd, yyyy').format(stock.expiryDate!) : 'N/A'} | Location: ${stock.location ?? 'N/A'}';
        })
        .join('\n\n');

    final isExpired =
        referenceStock.expiryDate != null &&
        referenceStock.expiryDate!.isBefore(DateTime.now());
    final isExpiringSoon =
        referenceStock.expiryDate != null &&
        referenceStock.expiryDate!.isBefore(
          DateTime.now().add(const Duration(days: 90)),
        ) &&
        !isExpired;

    // Check if any batch is low stock
    final hasLowStock = allStocks.any(
      (s) => s.reorderLevel != null && s.quantity <= s.reorderLevel!,
    );

    return DataRow(
      cells: [
        // Product Name - Flexible width
        DataCell(
          SizedBox(
            width: productNameMinWidth,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Tooltip(
                message: batchDetails,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      primaryName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    if (otherNames != null)
                      Text(
                        otherNames,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9,
                          color: theme.textTheme.bodySmall?.color?.withOpacity(
                            0.6,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Stock - Fixed width, center aligned
        DataCell(
          SizedBox(
            width: stockWidth,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: hasLowStock
                    ? Colors.orange.withOpacity(0.1)
                    : Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$totalQuantity',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: hasLowStock ? Colors.orange : Colors.green,
                ),
              ),
            ),
          ),
        ),
        // Price - Fixed width, right aligned (if not clinic mode)
        if (!isClinicMode)
          DataCell(
            SizedBox(
              width: priceWidth,
              child: Text(
                NumberFormat.currency(
                  symbol: 'RF ',
                  decimalDigits: 0,
                ).format(referenceStock.pricePerUnit),
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        // Expiry - Fixed width
        DataCell(
          SizedBox(
            width: expiryWidth,
            child: Tooltip(
              message: _getRelativeExpiry(referenceStock.expiryDate),
              child: Row(
                children: [
                  if (referenceStock.expiryDate != null)
                    Icon(
                      isExpired
                          ? Icons.error_outline
                          : (isExpiringSoon
                                ? Icons.warning_amber_outlined
                                : Icons.check_circle_outline),
                      size: 14,
                      color: isExpired
                          ? Colors.red
                          : (isExpiringSoon ? Colors.orange : Colors.green),
                    ),
                  if (referenceStock.expiryDate != null)
                    const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      referenceStock.expiryDate != null
                          ? DateFormat(
                              'MMM yyyy',
                            ).format(referenceStock.expiryDate!)
                          : 'N/A',
                      style: TextStyle(
                        color: isExpired
                            ? Colors.red
                            : (isExpiringSoon ? Colors.orange : null),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Batch Count - Fixed width
        DataCell(
          SizedBox(
            width: batchWidth,
            child: Text(
              '${allStocks.length} batch${allStocks.length == 1 ? '' : 'es'}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
            ),
          ),
        ),
      ],
    );
  }

  void _showProcessSaleFlow() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return _StockOutFlow(
          database: widget.database,
          stockOutService: widget.stockOutService,
          authService: widget.authService,
          settingsService: widget.settingsService,
          onSuccess: () {
            _loadStockIn();
            _loadStockOuts();
          },
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 5 * anim1.value,
            sigmaY: 5 * anim1.value,
          ),
          child: FadeTransition(
            opacity: anim1,
            child: ScaleTransition(
              scale: anim1.drive(CurveTween(curve: Curves.easeOutBack)),
              child: child,
            ),
          ),
        );
      },
    );
  }

  DataRow _buildDataRow(StockInDTO stock, ThemeData theme, Color accentColor) {
    final isClinicMode =
        widget.settingsService.deviceType == DeviceType.CLINIC_INVENTORY;
    final names = stock.productName.split(' || ').map((e) => e.trim()).toList();
    final primaryName = names[0];
    final otherNames = names.length > 1 ? names.sublist(1).join(', ') : null;

    // Build hover overlay showing batch details
    final stockDetails =
        'Batch: ${stock.batchNumber ?? 'N/A'}\n'
        'Units: ${stock.quantity}\n'
        'Price/Unit: RF ${stock.pricePerUnit.toStringAsFixed(0)}\n'
        'Expiry: ${stock.expiryDate != null ? DateFormat('MMM dd, yyyy').format(stock.expiryDate!) : 'N/A'}\n'
        'Location: ${stock.location ?? 'N/A'}\n'
        'Added: ${DateFormat('MMM dd, yyyy HH:mm').format(stock.createdAt)}';

    final isExpired =
        stock.expiryDate != null && stock.expiryDate!.isBefore(DateTime.now());
    final isExpiringSoon =
        stock.expiryDate != null &&
        stock.expiryDate!.isBefore(
          DateTime.now().add(const Duration(days: 90)),
        ) &&
        !isExpired;
    final isLowStock =
        stock.reorderLevel != null && stock.quantity <= stock.reorderLevel!;

    return DataRow(
      cells: [
        // Product Name - Flexible width
        DataCell(
          SizedBox(
            width: productNameMinWidth,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Tooltip(
                message: stockDetails,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      primaryName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    if (otherNames != null)
                      Text(
                        otherNames,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9,
                          color: theme.textTheme.bodySmall?.color?.withOpacity(
                            0.6,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Stock - Fixed width, center aligned
        DataCell(
          SizedBox(
            width: stockWidth,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isLowStock
                    ? Colors.orange.withOpacity(0.1)
                    : Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${stock.quantity}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isLowStock ? Colors.orange : Colors.green,
                ),
              ),
            ),
          ),
        ),
        // Price - Fixed width, right aligned (if not clinic mode)
        if (!isClinicMode)
          DataCell(
            SizedBox(
              width: priceWidth,
              child: Text(
                NumberFormat.currency(
                  symbol: 'RF ',
                  decimalDigits: 0,
                ).format(stock.pricePerUnit),
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        // Expiry - Fixed width
        DataCell(
          SizedBox(
            width: expiryWidth,
            child: Tooltip(
              message: _getRelativeExpiry(stock.expiryDate),
              child: Row(
                children: [
                  if (stock.expiryDate != null)
                    Icon(
                      isExpired
                          ? Icons.error_outline
                          : (isExpiringSoon
                                ? Icons.warning_amber_outlined
                                : Icons.check_circle_outline),
                      size: 14,
                      color: isExpired
                          ? Colors.red
                          : (isExpiringSoon ? Colors.orange : Colors.green),
                    ),
                  if (stock.expiryDate != null) const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      stock.expiryDate != null
                          ? DateFormat('MMM yyyy').format(stock.expiryDate!)
                          : 'N/A',
                      style: TextStyle(
                        color: isExpired
                            ? Colors.red
                            : (isExpiringSoon ? Colors.orange : null),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Batch - Fixed width
        DataCell(
          SizedBox(
            width: batchWidth,
            child: Text(
              stock.batchNumber ?? 'N/A',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ),
        // Location - Fixed width
        DataCell(
          SizedBox(
            width: locationWidth,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.dividerColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                stock.location ?? 'N/A',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        ),
        // Actions - Fixed width
        DataCell(
          SizedBox(
            width: actionsWidth,
            child: Builder(
              builder: (context) {
                final canEdit =
                    (stock.userId == widget.authService.currentUser?.id) &&
                    DateTime.now().difference(stock.createdAt).inHours < 8;

                return IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  color: canEdit ? accentColor : Colors.grey.withOpacity(0.3),
                  tooltip: canEdit
                      ? 'Edit Stock'
                      : 'Edit restricted (Owner & Time limit)',
                  onPressed: canEdit
                      ? () {
                          _showAddStockFlow(stockToEdit: stock);
                        }
                      : null,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _showAddStockFlow({StockInDTO? stockToEdit}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return _AddStockFlow(
          database: widget.database,
          stockService: widget.stockInService,
          authService: widget.authService,
          deviceType: widget.settingsService.deviceType,
          stockToEdit: stockToEdit,
          onSuccess: () {
            _loadStockIn();
          },
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 5 * anim1.value,
            sigmaY: 5 * anim1.value,
          ),
          child: FadeTransition(
            opacity: anim1,
            child: ScaleTransition(
              scale: anim1.drive(CurveTween(curve: Curves.easeOutBack)),
              child: child,
            ),
          ),
        );
      },
    );
  }

  List<DataColumn> _buildColumns() {
    final isClinicMode =
        widget.settingsService.deviceType == DeviceType.CLINIC_INVENTORY;

    return [
      const DataColumn(label: _HeaderCell('Product Name')),
      DataColumn(
        label: _SortableHeaderCell(
          label: 'Stock',
          sortBy: 'stock',
          currentSort: _stockInSortColumn,
          isAscending: _stockInSortAscending,
          onSort: (column) {
            setState(() {
              if (_stockInSortColumn == column) {
                _stockInSortAscending = !_stockInSortAscending;
              } else {
                _stockInSortColumn = column;
                _stockInSortAscending = true;
              }
            });
          },
        ),
        numeric: true,
      ),
      if (!isClinicMode)
        const DataColumn(label: _HeaderCell('Price/Unit'), numeric: true),
      DataColumn(
        label: _SortableHeaderCell(
          label: 'Expiry',
          sortBy: 'expiry',
          currentSort: _stockInSortColumn,
          isAscending: _stockInSortAscending,
          onSort: (column) {
            setState(() {
              if (_stockInSortColumn == column) {
                _stockInSortAscending = !_stockInSortAscending;
              } else {
                _stockInSortColumn = column;
                _stockInSortAscending = true;
              }
            });
          },
        ),
      ),
      const DataColumn(label: _HeaderCell('Batch')),
      const DataColumn(label: _HeaderCell('Location')),
      const DataColumn(label: _HeaderCell('Actions')),
    ];
  }

  // Column width configuration
  final double productNameMinWidth = 220;
  final double stockWidth = 100;
  final double priceWidth = 120;
  final double expiryWidth = 140;
  final double batchWidth = 120;
  final double locationWidth = 120;
  final double actionsWidth = 80;

  @override
  void dispose() {
    // Clean up listeners to prevent memory leaks
    widget.deviceStateManager.removeListener(_onDeviceStateChanged);
    widget.authService.removeListener(_onAuthChanged);
    
    _horizontalHeaderScrollController.dispose();
    _horizontalBodyScrollController.dispose();
    _stockOutHorizontalHeaderScrollController.dispose();
    _stockOutHorizontalBodyScrollController.dispose();
    _stockInSearchController.dispose();
    _stockOutSearchController.dispose();
    super.dispose();
  }
}

/// Header cell widget for consistent table header styling
class _HeaderCell extends StatelessWidget {
  final String label;

  const _HeaderCell(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
    );
  }
}

/// Sortable header cell widget with click handler and sort indicator
class _SortableHeaderCell extends StatelessWidget {
  final String label;
  final String sortBy;
  final String currentSort;
  final bool isAscending;
  final Function(String) onSort;

  const _SortableHeaderCell({
    required this.label,
    required this.sortBy,
    required this.currentSort,
    required this.isAscending,
    required this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    final isSorted = currentSort == sortBy;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onSort(sortBy),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            if (isSorted)
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Icon(
                  isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 14,
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.only(left: 6),
                child: Icon(Icons.unfold_more, size: 14, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}

class _ArrowKeyTraversal extends StatelessWidget {
  final Widget child;

  const _ArrowKeyTraversal({required this.child});

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      policy: WidgetOrderTraversalPolicy(),
      child: Shortcuts(
        shortcuts: <LogicalKeySet, Intent>{
          LogicalKeySet(LogicalKeyboardKey.arrowDown): NextFocusIntent(),
          LogicalKeySet(LogicalKeyboardKey.arrowUp): PreviousFocusIntent(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            NextFocusIntent: CallbackAction<NextFocusIntent>(
              onInvoke: (intent) {
                FocusScope.of(context).nextFocus();
                return null;
              },
            ),
            PreviousFocusIntent: CallbackAction<PreviousFocusIntent>(
              onInvoke: (intent) {
                FocusScope.of(context).previousFocus();
                return null;
              },
            ),
          },
          child: child,
        ),
      ),
    );
  }
}

class _AddStockFlow extends StatefulWidget {
  final AppDatabase database;
  final StockInService stockService;
  final AuthService authService;
  final VoidCallback onSuccess;
  final StockInDTO? stockToEdit;
  final DeviceType deviceType;

  const _AddStockFlow({
    required this.database,
    required this.stockService,
    required this.authService,
    required this.onSuccess,
    required this.deviceType,
    this.stockToEdit,
  });

  @override
  State<_AddStockFlow> createState() => _AddStockFlowState();
}

class _AddStockFlowState extends State<_AddStockFlow> {
  int _step = 1;
  Product? _selectedProduct;

  // Step 1 State
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  ItemType? _selectedType;
  String? _selectedInsuranceId;

  // Step 2 State
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _batchController = TextEditingController();
  final _locationController = TextEditingController();
  final _reorderController = TextEditingController();
  DateTime? _expiryDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.stockToEdit != null) {
      _step = 2; // Jump to step 2 directly
      _initializeEditMode();
    }
  }

  Future<void> _initializeEditMode() async {
    final stock = widget.stockToEdit!;
    _quantityController.text = stock.quantity.toString();
    // Default price to 0 for clinic inventory mode
    if (widget.deviceType == DeviceType.CLINIC_INVENTORY) {
      _priceController.text = '0';
    } else {
      _priceController.text = stock.pricePerUnit.toString();
    }
    _batchController.text = stock.batchNumber ?? '';
    _locationController.text = stock.location ?? '';
    if (stock.reorderLevel != null) {
      _reorderController.text = stock.reorderLevel.toString();
    }
    _expiryDate = stock.expiryDate;

    // Fetch product details
    try {
      final product = await widget.database.getProductById(stock.productId);
      if (mounted) {
        setState(() {
          _selectedProduct = product;
        });
      }
    } catch (e) {
      debugPrint('Failed to load product for editing: $e');
    }
  }

  /// Formats units for display
  String _formatUnit(String? unit) {
    if (unit == null || unit.isEmpty) return 'pieces';
    final normalized = unit.toLowerCase().trim();
    if (normalized == 'pc_s' ||
        normalized == 'piece' ||
        normalized == 'pieces' ||
        normalized == 'pcs') {
      return 'pieces';
    }
    return unit;
  }

  /// Parses product name segments and prioritizes match with search query
  (String, List<String>) _getParsedNames(String fullName, String query) {
    final names = fullName.split(' || ').map((e) => e.trim()).toList();
    if (query.isEmpty) {
      return (names[0], names.length > 1 ? names.sublist(1) : []);
    }

    final lowerQuery = query.toLowerCase();
    final matchIndex = names.indexWhere(
      (n) => n.toLowerCase().contains(lowerQuery),
    );

    if (matchIndex != -1) {
      final match = names[matchIndex];
      final others = List<String>.from(names)..removeAt(matchIndex);
      return (match, others);
    }
    return (names[0], names.length > 1 ? names.sublist(1) : []);
  }

  void _selectProduct(Product product) {
    setState(() {
      _selectedProduct = product;
      _step = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _ArrowKeyTraversal(
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 600,
            constraints: const BoxConstraints(maxHeight: 700),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: animation.drive(
                      Tween(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).chain(CurveTween(curve: Curves.easeOutQuad)),
                    ),
                    child: child,
                  ),
                );
              },
              child: _step == 1 ? _buildStep1() : _buildStep2(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Spotlight Search Bar
        Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.search, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        style: const TextStyle(fontSize: 20),
                        decoration: const InputDecoration(
                          hintText: 'Search product to add stock...',
                          border: InputBorder.none,
                        ),
                        onChanged: (value) =>
                            setState(() => _searchQuery = value),
                      ),
                    ),
                    _buildStep1Filters(),
                  ],
                ),
              ),
              if (_searchQuery.length >= 2) const Divider(height: 1),
              if (_searchQuery.length >= 2)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 400),
                  child: FutureBuilder<List<Product>>(
                    future: widget.database.getFilteredProducts(
                      searchQuery: _searchQuery,
                      type: _selectedType,
                      insuranceId: _selectedInsuranceId,
                    ),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox(
                          height: 100,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final products = snapshot.data!;
                      if (products.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'No products found matching your search.',
                          ),
                        );
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: products.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, indent: 60),
                        itemBuilder: (context, index) {
                          final p = products[index];
                          final (mainName, others) = _getParsedNames(
                            p.name,
                            _searchQuery,
                          );

                          return ListTile(
                            leading: Icon(
                              p.type == ItemType.DRUG
                                  ? Icons.medication
                                  : Icons.medical_services,
                              color: theme.colorScheme.primary,
                            ),
                            title: Text(
                              mainName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (others.isNotEmpty)
                                  Text(
                                    others.join(', '),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.textTheme.bodySmall?.color,
                                    ),
                                  ),
                                Text(
                                  _formatUnit(p.sellingUnit),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _ProductPeekIcon(
                                  product: p,
                                  database: widget.database,
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.chevron_right),
                              ],
                            ),
                            onTap: () => _selectProduct(p),
                          );
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep1Filters() {
    final theme = Theme.of(context);
    final isClinicMode = widget.deviceType == DeviceType.CLINIC_INVENTORY;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Type Filter
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.light
                ? theme.scaffoldBackgroundColor
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<ItemType?>(
              value: _selectedType,
              hint: const Text('Type', style: TextStyle(fontSize: 13)),
              icon: const Icon(Icons.category_outlined, size: 16),
              items: [
                const DropdownMenuItem(value: null, child: Text('All Types')),
                const DropdownMenuItem(
                  value: ItemType.DRUG,
                  child: Text('Drugs'),
                ),
                const DropdownMenuItem(
                  value: ItemType.CONSUMABLE_DEVICE,
                  child: Text('Consumables'),
                ),
              ],
              onChanged: (value) => setState(() => _selectedType = value),
            ),
          ),
        ),
        if (!isClinicMode) ...[
          const SizedBox(width: 8),
          // Insurance Filter (only for pharmacy modes)
          FutureBuilder<List<Insurance>>(
            future: widget.database.getAllInsurances(),
            builder: (context, snapshot) {
              final insurances = snapshot.data ?? [];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.light
                      ? theme.scaffoldBackgroundColor
                      : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: _selectedInsuranceId,
                    hint: const Text(
                      'Insurance',
                      style: TextStyle(fontSize: 13),
                    ),
                    icon: const Icon(Icons.shield_outlined, size: 16),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All')),
                      ...insurances.map(
                        (i) => DropdownMenuItem(
                          value: i.id,
                          child: Text(i.acronym),
                        ),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _selectedInsuranceId = value),
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildStep2() {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Header
              Container(
                color: theme.colorScheme.primary.withOpacity(0.05),
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => setState(() => _step = 1),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.stockToEdit != null
                                ? 'Edit Stock for'
                                : 'Configure Stock for',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Builder(
                            builder: (context) {
                              final (mainName, others) = _getParsedNames(
                                _selectedProduct?.name ?? '',
                                '',
                              );
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    mainName,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (others.isNotEmpty)
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        others.join(' • '),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _quantityController,
                              autofocus: true,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Quantity',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              onFieldSubmitted: (_) =>
                                  FocusScope.of(context).nextFocus(),
                              validator: (v) =>
                                  (v == null || int.tryParse(v) == null)
                                  ? 'Invalid'
                                  : null,
                            ),
                          ),
                          // Only show price field for non-clinic inventory modes
                          if (widget.deviceType != DeviceType.CLINIC_INVENTORY)
                            const SizedBox(width: 16),
                          if (widget.deviceType != DeviceType.CLINIC_INVENTORY)
                            Expanded(
                              child: TextFormField(
                                controller: _priceController,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Price per Unit',
                                  prefixText: 'RF ',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                onFieldSubmitted: (_) =>
                                    FocusScope.of(context).nextFocus(),
                                validator: (v) =>
                                    (v == null || double.tryParse(v) == null)
                                    ? 'Invalid'
                                    : null,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _batchController,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Batch Number',
                                border: OutlineInputBorder(),
                              ),
                              onFieldSubmitted: (_) =>
                                  FocusScope.of(context).nextFocus(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Expiry Date Dropdowns
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Expiry Date',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              // Day Dropdown
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  value: _expiryDate?.day,
                                  decoration: const InputDecoration(
                                    labelText: 'Day',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: List.generate(31, (index) => index + 1)
                                      .map(
                                        (day) => DropdownMenuItem(
                                          value: day,
                                          child: Text(day.toString()),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        final now = DateTime.now();
                                        _expiryDate = DateTime(
                                          _expiryDate?.year ?? now.year + 1,
                                          _expiryDate?.month ?? now.month,
                                          value,
                                        );
                                      });
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Month Dropdown
                              Expanded(
                                flex: 2,
                                child: DropdownButtonFormField<int>(
                                  value: _expiryDate?.month,
                                  decoration: const InputDecoration(
                                    labelText: 'Month',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: [
                                    const DropdownMenuItem(
                                      value: 1,
                                      child: Text('January'),
                                    ),
                                    const DropdownMenuItem(
                                      value: 2,
                                      child: Text('February'),
                                    ),
                                    const DropdownMenuItem(
                                      value: 3,
                                      child: Text('March'),
                                    ),
                                    const DropdownMenuItem(
                                      value: 4,
                                      child: Text('April'),
                                    ),
                                    const DropdownMenuItem(
                                      value: 5,
                                      child: Text('May'),
                                    ),
                                    const DropdownMenuItem(
                                      value: 6,
                                      child: Text('June'),
                                    ),
                                    const DropdownMenuItem(
                                      value: 7,
                                      child: Text('July'),
                                    ),
                                    const DropdownMenuItem(
                                      value: 8,
                                      child: Text('August'),
                                    ),
                                    const DropdownMenuItem(
                                      value: 9,
                                      child: Text('September'),
                                    ),
                                    const DropdownMenuItem(
                                      value: 10,
                                      child: Text('October'),
                                    ),
                                    const DropdownMenuItem(
                                      value: 11,
                                      child: Text('November'),
                                    ),
                                    const DropdownMenuItem(
                                      value: 12,
                                      child: Text('December'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        final now = DateTime.now();
                                        _expiryDate = DateTime(
                                          _expiryDate?.year ?? now.year + 1,
                                          value,
                                          _expiryDate?.day ?? 1,
                                        );
                                      });
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Year Dropdown
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  value: _expiryDate?.year,
                                  decoration: const InputDecoration(
                                    labelText: 'Year',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: List.generate(10, (index) {
                                    final year = DateTime.now().year + index;
                                    return DropdownMenuItem(
                                      value: year,
                                      child: Text(year.toString()),
                                    );
                                  }),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        final now = DateTime.now();
                                        _expiryDate = DateTime(
                                          value,
                                          _expiryDate?.month ?? now.month,
                                          _expiryDate?.day ?? 1,
                                        );
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _locationController,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Location',
                                border: OutlineInputBorder(),
                              ),
                              onFieldSubmitted: (_) =>
                                  FocusScope.of(context).nextFocus(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _reorderController,
                              textInputAction: TextInputAction.done,
                              decoration: const InputDecoration(
                                labelText: 'Reorder Level',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              onFieldSubmitted: (_) {
                                if (!_isSaving) {
                                  _saveStock();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveStock,
                          child: _isSaving
                              ? const CircularProgressIndicator()
                              : Text(
                                  widget.stockToEdit != null
                                      ? 'Update Stock Entry'
                                      : 'Complete Stock Entry',
                                  style: const TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveStock() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      // For clinic inventory mode, price should be 0
      final price = widget.deviceType == DeviceType.CLINIC_INVENTORY
          ? 0.0
          : double.parse(_priceController.text);

      final createDTO = StockInCreateDTO(
        productId: _selectedProduct!.id,
        quantity: int.parse(_quantityController.text),
        pricePerUnit: price,
        batchNumber: _batchController.text.isEmpty
            ? null
            : _batchController.text,
        location: _locationController.text.isEmpty
            ? null
            : _locationController.text,
        expiryDate: _expiryDate,
        reorderLevel: int.tryParse(_reorderController.text),
        deviceType: widget.deviceType,
      );

      if (widget.stockToEdit != null) {
        await widget.stockService.updateStockIn(
          widget.stockToEdit!.id,
          createDTO,
        );
      } else {
        await widget.stockService.createStockIn(
          createDTO,
          userId: widget.authService.currentUser?.id,
        );
      }
      widget.onSuccess();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

class _ProductPeekIcon extends StatelessWidget {
  final Product product;
  final AppDatabase database;

  const _ProductPeekIcon({required this.product, required this.database});

  String _formatUnit(String? unit) {
    if (unit == null || unit.isEmpty) return 'unit';
    final normalized = unit.toLowerCase().trim();
    if (normalized == 'pc_s' ||
        normalized == 'piece' ||
        normalized == 'pieces' ||
        normalized == 'pcs') {
      return 'pieces';
    }
    return unit;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.primary;

    return Tooltip(
      richMessage: WidgetSpan(
        child: FutureBuilder<List<dynamic>>(
          future: Future.wait([
            database.getInsurancesForProduct(product.id),
            database.getAllInsurances(),
          ]),
          builder: (context, snapshot) {
            final loading = !snapshot.hasData && !snapshot.hasError;
            final coverages =
                (snapshot.data?[0] as List<ProductInsurance>?)
                    ?.where((pi) => pi.cost > 0)
                    .toList() ??
                [];
            final allInsurances = snapshot.data?[1] as List<Insurance>? ?? [];

            return Container(
              width: 240,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Insurance Coverage',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (loading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  else if (coverages.isEmpty)
                    Text(
                      'No coverage found.',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    )
                  else
                    ...coverages.map((pi) {
                      final insurance = allInsurances.firstWhere(
                        (i) => i.id == pi.insuranceId,
                        orElse: () => Insurance(
                          id: '',
                          name: 'Unknown',
                          acronym: 'UNK',
                          clientPercentage: 0,
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                          version: 1,
                        ),
                      );

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              '${insurance.acronym}: ',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                            Text(
                              '${pi.cost.toStringAsFixed(0)} RWF',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: accentColor,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'per ${_formatUnit(pi.unit.name)}',
                              style: TextStyle(
                                fontSize: 10,
                                color: theme.textTheme.bodySmall?.color,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                ],
              ),
            );
          },
        ),
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          Icons.visibility_outlined,
          size: 18,
          color: theme.colorScheme.primary.withOpacity(0.5),
        ),
      ),
    );
  }
}

/// Represents a stock allocation for a cart item
class _StockAllocation {
  StockIn stock;
  int quantityAllocated;

  _StockAllocation({required this.stock, required this.quantityAllocated});
}

class _StockOutItemForm {
  final Product product;
  final StockIn initialStock;
  List<_StockAllocation> allocations; // Selected stock allocations
  Set<String> selectedStockIds; // Track which stocks are selected
  int quantity;
  double price;
  String? insuranceId;
  Insurance? insurance;
  double itemTotal = 0;
  double patientPays = 0;
  double insurancePays = 0;
  late final TextEditingController priceController;

  _StockOutItemForm({
    required this.product,
    required this.initialStock,
    required this.quantity,
    required this.price,
  }) : allocations = [
         _StockAllocation(stock: initialStock, quantityAllocated: quantity),
       ],
       selectedStockIds = {initialStock.id} {
    priceController = TextEditingController(text: price.toStringAsFixed(0));
  }

  /// Get the primary stock (first allocation)
  StockIn get stock =>
      allocations.isNotEmpty ? allocations[0].stock : initialStock;

  /// Total quantity across all allocations
  int get totalQuantityAllocated =>
      allocations.fold(0, (sum, alloc) => sum + alloc.quantityAllocated);

  void dispose() {
    priceController.dispose();
  }
}

class _StockOutFlow extends StatefulWidget {
  final AppDatabase database;
  final StockOutService stockOutService;
  final AuthService authService;
  final SettingsService settingsService;
  final VoidCallback onSuccess;

  const _StockOutFlow({
    required this.database,
    required this.stockOutService,
    required this.authService,
    required this.settingsService,
    required this.onSuccess,
  });

  @override
  State<_StockOutFlow> createState() => _StockOutFlowState();
}

class _StockOutFlowState extends State<_StockOutFlow> {
  int _step = 1;
  final _formKey = GlobalKey<FormState>();

  // Device Type and Mode-Specific Fields
  late DeviceType _deviceType;

  // Wholesale Fields
  final _destinationPharmacyNameController = TextEditingController();
  final _destinationPharmacyPhoneController = TextEditingController();
  final _tinNumberController = TextEditingController();
  bool _isRetailSale = false; // Toggle for wholesale to sell retail

  // Clinic Fields
  ClinicService? _selectedClinicService;

  // Patient Info (Retail Only)
  final _patientNameController = TextEditingController();
  final _cardController = TextEditingController();
  final _companyController = TextEditingController();
  final _prescriberNameController = TextEditingController();
  final _prescriberLicenseController = TextEditingController();
  final _organizationController = TextEditingController();
  String? _stockOutInsuranceId;
  Insurance? _selectedInsurance;

  // Cart
  final List<_StockOutItemForm> _cart = [];
  final _searchController = TextEditingController();
  String _searchQuery = '';
  ItemType? _selectedType;
  String? _searchInsuranceId;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Initialize device type from settings
    _deviceType = widget.settingsService.deviceType;
  }

  @override
  void dispose() {
    for (var item in _cart) {
      item.dispose();
    }
    _searchController.dispose();
    _patientNameController.dispose();
    _companyController.dispose();
    _cardController.dispose();
    _prescriberNameController.dispose();
    _prescriberLicenseController.dispose();
    _organizationController.dispose();
    _destinationPharmacyNameController.dispose();
    _destinationPharmacyPhoneController.dispose();
    _tinNumberController.dispose();
    super.dispose();
  }

  void _calculateTotalsForItem(_StockOutItemForm item) {
    item.itemTotal = item.price * item.quantity;

    // Apply insurance pricing for PHARMACY_RETAIL or wholesale retail sales
    final isRetailMode = _deviceType == DeviceType.PHARMACY_RETAIL ||
        (_deviceType == DeviceType.PHARMACY_WHOLESALE && _isRetailSale);
    
    if (isRetailMode &&
        item.insuranceId != null &&
        item.insurance != null) {
      final clientPercentage = item.insurance!.clientPercentage / 100.0;
      item.patientPays = item.itemTotal * clientPercentage;
      item.insurancePays = item.itemTotal - item.patientPays;
    } else {
      item.patientPays = item.itemTotal;
      item.insurancePays = 0;
    }
  }

  Future<void> _updateItemPriceAndCoverage(_StockOutItemForm item) async {
    // 1. Start with private price
    double price = item.stock.pricePerUnit ?? 0;
    Insurance? itemInsurance = _selectedInsurance;
    String? itemInsuranceId = _stockOutInsuranceId;

    // 2. For PHARMACY_RETAIL or wholesale retail sales: Check for insurance coverage if selected
    final isRetailMode = _deviceType == DeviceType.PHARMACY_RETAIL ||
        (_deviceType == DeviceType.PHARMACY_WHOLESALE && _isRetailSale);
    
    if (isRetailMode && itemInsurance != null) {
      final insurances = await widget.database.getInsurancesForProduct(
        item.product.id,
      );
      final coverage = insurances.cast<ProductInsurance?>().firstWhere(
        (c) => c?.insuranceId == itemInsurance!.id,
        orElse: () => null,
      );

      if (coverage != null && coverage.cost > 0) {
        price = coverage.cost;
      } else {
        // Not covered - revert to private sale for this specific item
        itemInsurance = null;
        itemInsuranceId = null;
      }
    } else if (_deviceType != DeviceType.PHARMACY_RETAIL) {
      // For non-retail: Clear insurance as it's not applicable
      itemInsurance = null;
      itemInsuranceId = null;
    }

    // 3. Update the item
    setState(() {
      item.price = price;
      item.insurance = itemInsurance;
      item.insuranceId = itemInsuranceId;
      // Sync controller if it's not currently focused or if price changed from outside
      final priceString = price.toStringAsFixed(0);
      if (item.priceController.text != priceString) {
        item.priceController.text = priceString;
      }
      _calculateTotalsForItem(item);
    });
  }

  Future<void> _refreshCartPrices() async {
    for (var item in _cart) {
      await _updateItemPriceAndCoverage(item);
    }
  }

  void _addItem(Product product) async {
    final stockItems = await widget.database.getStockInsByProduct(product.id);

    if (stockItems.isEmpty) {
      Toast.warning('No stock available for this product');
      return;
    }

    // Filter out stocks with 0 quantity and stocks already fully allocated in cart
    final availableStocks = stockItems
        .where((s) => s.quantity > 0) // Only stocks with available quantity
        .where(
          (s) => !_cart.any((item) => item.stock.id == s.id),
        ) // Not already in cart
        .toList();

    if (availableStocks.isEmpty) {
      Toast.warning(
        'All available stock batches for this product are either empty or already in the cart.',
      );
      return;
    }

    // Auto-select FEFO stock
    final selectedStock = _selectFefoStock(availableStocks);

    final newItem = _StockOutItemForm(
      product: product,
      initialStock: selectedStock,
      quantity: 1,
      price: selectedStock.pricePerUnit ?? 0,
    );

    await _updateItemPriceAndCoverage(newItem);

    setState(() {
      _cart.add(newItem);
      _searchController.clear();
      _searchQuery = '';
    });
  }

  void _advanceFromStep1() {
    if (_formKey.currentState!.validate()) {
      setState(() => _step = 2);
    }
  }

  /// Select the best stock entry based on FEFO (First Expired First Out)
  StockIn _selectFefoStock(List<StockIn> stocks) {
    if (stocks.isEmpty) throw Exception('No stocks available');

    final sorted = [...stocks];
    sorted.sort((a, b) {
      // Priority 1: Expired entries first
      final aExpired =
          a.expiryDate != null && a.expiryDate!.isBefore(DateTime.now());
      final bExpired =
          b.expiryDate != null && b.expiryDate!.isBefore(DateTime.now());
      if (aExpired && !bExpired) return -1;
      if (!aExpired && bExpired) return 1;

      // Priority 2: Expiring within 30 days
      final aExpiringSoon =
          a.expiryDate != null &&
          a.expiryDate!.isBefore(
            DateTime.now().add(const Duration(days: 30)),
          ) &&
          !aExpired;
      final bExpiringSoon =
          b.expiryDate != null &&
          b.expiryDate!.isBefore(
            DateTime.now().add(const Duration(days: 30)),
          ) &&
          !bExpired;
      if (aExpiringSoon && !bExpiringSoon) return -1;
      if (!aExpiringSoon && bExpiringSoon) return 1;

      // Priority 3: Earliest expiry date first
      if (a.expiryDate != null && b.expiryDate != null) {
        return a.expiryDate!.compareTo(b.expiryDate!);
      }

      // Priority 4: Oldest batch creation (FIFO fallback)
      return a.createdAt.compareTo(b.createdAt);
    });

    return sorted.first;
  }

  /// Show dropdown menu for stock selection on cart item
  Future<void> _submitStockOut() async {
    if (_cart.isEmpty) return;

    setState(() => _isSaving = true);
    try {
      // Validate device-type-specific fields
      if (_deviceType == DeviceType.PHARMACY_RETAIL) {
        if (_patientNameController.text.trim().isEmpty &&
            _stockOutInsuranceId != null) {
          throw 'Patient name is required for insurance transactions';
        }
      } else if (_deviceType == DeviceType.PHARMACY_WHOLESALE) {
        if (_destinationPharmacyNameController.text.trim().isEmpty) {
          throw 'Destination pharmacy name is required for wholesale';
        }
      } else if (_deviceType == DeviceType.CLINIC_INVENTORY) {
        if (_selectedClinicService == null) {
          throw 'Clinic service must be selected';
        }
      }

      final saleDTO = StockOutCreateDTO(
        deviceType: _deviceType,
        items: _cart
            .expand(
              (item) => item.allocations.map(
                (allocation) => StockOutItemCreateDTO(
                  stockInId: allocation.stock.id,
                  quantitySold: allocation.quantityAllocated,
                  // Only include price for pharmacy modes, not for clinic
                  pricePerUnit: _deviceType == DeviceType.CLINIC_INVENTORY
                      ? null
                      : item.price,
                  insuranceId: _deviceType == DeviceType.PHARMACY_RETAIL
                      ? item.insuranceId
                      : null,
                ),
              ),
            )
            .toList(),
        // Retail-specific fields
        patientName: _deviceType == DeviceType.PHARMACY_RETAIL
            ? (_patientNameController.text.trim().isEmpty
                  ? 'Walk-in Customer'
                  : _patientNameController.text.trim())
            : null,
        insuranceCardNumber:
            _deviceType == DeviceType.PHARMACY_RETAIL &&
                _cardController.text.isNotEmpty
            ? _cardController.text
            : null,
        issuingCompany:
            _deviceType == DeviceType.PHARMACY_RETAIL &&
                _companyController.text.isNotEmpty
            ? _companyController.text
            : null,
        prescriberName:
            _deviceType == DeviceType.PHARMACY_RETAIL &&
                _prescriberNameController.text.isNotEmpty
            ? _prescriberNameController.text
            : null,
        prescriberLicenseId:
            _deviceType == DeviceType.PHARMACY_RETAIL &&
                _prescriberLicenseController.text.isNotEmpty
            ? _prescriberLicenseController.text
            : null,
        prescribingOrganization:
            _deviceType == DeviceType.PHARMACY_RETAIL &&
                _organizationController.text.isNotEmpty
            ? _organizationController.text
            : null,
        // Wholesale-specific fields
        destinationPharmacyName: _deviceType == DeviceType.PHARMACY_WHOLESALE
            ? _destinationPharmacyNameController.text.trim()
            : null,
        destinationPharmacyPhone:
            _deviceType == DeviceType.PHARMACY_WHOLESALE &&
                _destinationPharmacyPhoneController.text.isNotEmpty
            ? _destinationPharmacyPhoneController.text
            : null,
        tinNumber:
            _deviceType == DeviceType.PHARMACY_WHOLESALE &&
                _tinNumberController.text.isNotEmpty
            ? _tinNumberController.text
            : null,
        // Clinic-specific fields
        destinationClinicService: _deviceType == DeviceType.CLINIC_INVENTORY
            ? _selectedClinicService
            : null,
      );

      await widget.stockOutService.createStockOut(
        saleDTO,
        userId: widget.authService.currentUser?.id,
      );
      widget.onSuccess();
      if (mounted) Navigator.pop(context);
    } catch (e, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: e,
          stack: stackTrace,
          library: 'stock_out_flow',
          context: ErrorDescription('while creating a stock out transaction'),
        ),
      );
      debugPrint('Stock out failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error creating sale: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ArrowKeyTraversal(
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 800,
            constraints: const BoxConstraints(maxHeight: 800),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                const Divider(height: 1),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: KeyedSubtree(
                        key: ValueKey(_step),
                        child: _buildCurrentStep(),
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    String title = 'Process New Transaction';
    IconData icon = Icons.add_shopping_cart;
    String modeLabel = _deviceType == DeviceType.PHARMACY_RETAIL
        ? 'Pharmacy Retail'
        : (_deviceType == DeviceType.PHARMACY_WHOLESALE
              ? 'Pharmacy Wholesale'
              : 'Clinic Inventory');

    if (_step == 1) {
      title = _deviceType == DeviceType.PHARMACY_RETAIL
          ? 'Patient Information'
          : (_deviceType == DeviceType.PHARMACY_WHOLESALE
                ? 'Destination Pharmacy'
                : 'Clinic Service');
    }
    if (_step == 2) {
      title = 'Select Products';
      icon = Icons.search;
    }
    if (_step == 3) {
      title = 'Review & Finalize';
      icon = Icons.fact_check;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 24, 24, 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Text(
                    'Step $_step of 3',
                    style: TextStyle(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      modeLabel,
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            style: IconButton.styleFrom(
              backgroundColor: theme.dividerColor.withOpacity(0.05),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Row(
        children: [
          if (_step > 1)
            OutlinedButton.icon(
              onPressed: () => setState(() => _step--),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Previous Step'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          const Spacer(),
          if (_step < 3)
            ElevatedButton.icon(
              onPressed: () {
                if (_step == 1) {
                  if (_formKey.currentState!.validate()) {
                    setState(() => _step++);
                  }
                } else {
                  if (_cart.isEmpty) {
                    Toast.warning('Please add at least one product');
                    return;
                  }
                  setState(() => _step++);
                }
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Next Step'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _submitStockOut,
              icon: const Icon(Icons.check_circle),
              label: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Confirm & Create Sale'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_step) {
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2();
      case 3:
        return _buildStep3();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_deviceType == DeviceType.PHARMACY_RETAIL)
            _buildStep1Retail()
          else if (_deviceType == DeviceType.PHARMACY_WHOLESALE)
            _buildStep1Wholesale()
          else if (_deviceType == DeviceType.CLINIC_INVENTORY)
            _buildStep1Clinic()
          else
            _buildStep1Retail(), // Default to retail
        ],
      ),
    );
  }

  Widget _buildStep1Retail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Patient Details'),
        const SizedBox(height: 20),
        TextFormField(
          controller: _patientNameController,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: 'Full name of the patient',
            labelText: _stockOutInsuranceId != null
                ? 'Patient Name *'
                : 'Patient Name (Optional)',
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
          validator: (v) =>
              (_stockOutInsuranceId != null && (v == null || v.trim().isEmpty))
              ? 'Required for Insurance'
              : null,
        ),
        const SizedBox(height: 32),
        _buildSectionTitle('Insurance Details'),
        const SizedBox(height: 12),
        Text(
          'Keep empty for private sales where the patient pays 100%.',
          style: TextStyle(
            color: Theme.of(
              context,
            ).textTheme.bodySmall?.color?.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 20),
        FutureBuilder<List<Insurance>>(
          future: widget.database.getAllInsurances(),
          builder: (context, snapshot) {
            final insurances = snapshot.data ?? [];
            return DropdownButtonFormField<String>(
              value: _stockOutInsuranceId,
              decoration: InputDecoration(
                labelText: 'Select Insurance Provider',
                prefixIcon: const Icon(Icons.shield_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('No Insurance (Private)'),
                ),
                ...insurances.map(
                  (i) => DropdownMenuItem(
                    value: i.id,
                    child: Text('${i.name} (${i.acronym})'),
                  ),
                ),
              ],
              onChanged: (value) async {
                setState(() {
                  _stockOutInsuranceId = value;
                  _selectedInsurance = value != null
                      ? insurances.firstWhere((i) => i.id == value)
                      : null;
                });
                await _refreshCartPrices();
              },
            );
          },
        ),
        if (_stockOutInsuranceId != null) ...[
          const SizedBox(height: 24),
          TextFormField(
            controller: _cardController,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Insurance Card Number *',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
            validator: (v) =>
                (_stockOutInsuranceId != null && (v == null || v.isEmpty))
                ? 'Required'
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _companyController,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Issuing Company *',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
            validator: (v) =>
                (_stockOutInsuranceId != null && (v == null || v.isEmpty))
                ? 'Required'
                : null,
          ),
        ],
        const SizedBox(height: 24),
        _buildSectionTitle(
          _stockOutInsuranceId != null
              ? 'Prescriber Details (Required)'
              : 'Prescriber Details (Optional)',
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _prescriberNameController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: _stockOutInsuranceId != null
                      ? 'Prescriber Name *'
                      : 'Prescriber Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                validator: (v) =>
                    (_stockOutInsuranceId != null && (v == null || v.isEmpty))
                    ? 'Required'
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _prescriberLicenseController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: _stockOutInsuranceId != null
                      ? 'License ID *'
                      : 'License ID',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                validator: (v) =>
                    (_stockOutInsuranceId != null && (v == null || v.isEmpty))
                    ? 'Required'
                    : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _organizationController,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: _stockOutInsuranceId != null
                ? 'Prescribing Organization *'
                : 'Prescribing Organization',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onFieldSubmitted: (_) => _advanceFromStep1(),
          validator: (v) =>
              (_stockOutInsuranceId != null && (v == null || v.isEmpty))
              ? 'Required'
              : null,
        ),
      ],
    );
  }

  Widget _buildStep1Wholesale() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Retail Sale Toggle
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isRetailSale
                  ? theme.colorScheme.primary.withOpacity(0.5)
                  : theme.dividerColor.withOpacity(0.2),
              width: _isRetailSale ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Checkbox(
                value: _isRetailSale,
                onChanged: (value) {
                  setState(() {
                    _isRetailSale = value ?? false;
                    // Clear wholesale fields when switching to retail
                    if (_isRetailSale) {
                      _destinationPharmacyNameController.clear();
                      _destinationPharmacyPhoneController.clear();
                      _tinNumberController.clear();
                    } else {
                      // Clear retail fields when switching to wholesale
                      _patientNameController.clear();
                      _cardController.clear();
                      _companyController.clear();
                      _prescriberNameController.clear();
                      _prescriberLicenseController.clear();
                      _organizationController.clear();
                      _stockOutInsuranceId = null;
                      _selectedInsurance = null;
                    }
                  });
                },
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Retail Sale',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: _isRetailSale
                            ? theme.colorScheme.primary
                            : theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Enable to sell to individual customers with insurance support',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Show retail fields or wholesale fields based on toggle
        if (_isRetailSale)
          _buildStep1Retail()
        else ...[
          _buildSectionTitle('Destination Pharmacy Details'),
          const SizedBox(height: 20),
          TextFormField(
            controller: _destinationPharmacyNameController,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Pharmacy Name *',
              hintText: 'Name of the destination pharmacy',
              prefixIcon: const Icon(Icons.business),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Pharmacy name is required'
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _destinationPharmacyPhoneController,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              hintText: '+250 XXX XXX XXX',
              prefixIcon: const Icon(Icons.phone),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _tinNumberController,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'TIN Number',
              hintText: 'Tax Identification Number',
              prefixIcon: const Icon(Icons.numbers),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onFieldSubmitted: (_) => _advanceFromStep1(),
          ),
        ],
      ],
    );
  }

  Widget _buildStep1Clinic() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Clinic Service'),
        const SizedBox(height: 20),
        Text(
          'Select the clinic service that will receive this inventory:',
          style: TextStyle(
            color: theme.textTheme.bodyMedium?.color,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<ClinicService>(
          value: _selectedClinicService,
          decoration: InputDecoration(
            labelText: 'Clinic Service *',
            prefixIcon: const Icon(Icons.local_hospital),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: ClinicService.values.map((service) {
            return DropdownMenuItem(
              value: service,
              child: Text(_formatClinicServiceName(service)),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedClinicService = value),
          validator: (v) => (v == null) ? 'Clinic service is required' : null,
        ),
      ],
    );
  }

  String _formatClinicServiceName(ClinicService service) {
    switch (service) {
      case ClinicService.DENTAL:
        return 'Dental';
      case ClinicService.INTERNAL_MEDICINE:
        return 'Internal Medicine';
      case ClinicService.LABORATORY:
        return 'Laboratory';
      case ClinicService.SURGERY:
        return 'Surgery';
      case ClinicService.PEDIATRICS:
        return 'Pediatrics';
      case ClinicService.CARDIOLOGY:
        return 'Cardiology';
      case ClinicService.ORTHOPEDICS:
        return 'Orthopedics';
    }
  }

  Widget _buildStep2Summary(ThemeData theme) {
    if (_deviceType == DeviceType.PHARMACY_RETAIL) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                _patientNameController.text.trim().isEmpty
                    ? 'Walk-in Customer'
                    : _patientNameController.text.trim(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          if (_selectedInsurance != null) ...[
            Row(
              children: [
                Icon(Icons.shield, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_selectedInsurance!.name} (${_selectedInsurance!.acronym})',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 28),
              child: Row(
                children: [
                  _buildBadge(
                    'Patient: ${_selectedInsurance!.clientPercentage.toStringAsFixed(0)}%',
                    Colors.orange.shade100,
                    Colors.orange.shade900,
                  ),
                  const SizedBox(width: 8),
                  _buildBadge(
                    'Insurer: ${(100 - _selectedInsurance!.clientPercentage).toStringAsFixed(0)}%',
                    Colors.green.shade100,
                    Colors.green.shade900,
                  ),
                ],
              ),
            ),
          ] else
            Row(
              children: [
                const Icon(Icons.money_off, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                const Text(
                  'Private Sale (Patient pays 100%)',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
        ],
      );
    } else if (_deviceType == DeviceType.PHARMACY_WHOLESALE) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.business, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _destinationPharmacyNameController.text.isEmpty
                      ? 'No pharmacy selected'
                      : _destinationPharmacyNameController.text,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          if (_destinationPharmacyPhoneController.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  _destinationPharmacyPhoneController.text,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
          if (_tinNumberController.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.numbers, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'TIN: ${_tinNumberController.text}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ],
      );
    } else if (_deviceType == DeviceType.CLINIC_INVENTORY) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_hospital,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                _selectedClinicService != null
                    ? _formatClinicServiceName(_selectedClinicService!)
                    : 'No service selected',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.info_outline, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              const Text(
                'Units only (no pricing)',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildStep2() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Transaction Summary'),
        Container(
          margin: const EdgeInsets.only(top: 12, bottom: 24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.2),
            ),
          ),
          child: _buildStep2Summary(theme),
        ),
        _buildSectionTitle('Product Search'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: theme.dividerColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: const TextStyle(fontSize: 18),
                  decoration: const InputDecoration(
                    hintText: 'Type product name to add...',
                    border: InputBorder.none,
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
              if (_searchQuery.isNotEmpty)
                IconButton(
                  onPressed: () => setState(() {
                    _searchController.clear();
                    _searchQuery = '';
                  }),
                  icon: const Icon(Icons.clear),
                ),
              _buildStep1Filters(), // Reusing filters
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (_searchQuery.length >= 2)
          Container(
            constraints: const BoxConstraints(maxHeight: 300),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
              ],
            ),
            child: FutureBuilder<List<Product>>(
              future: widget.database.getFilteredProducts(
                searchQuery: _searchQuery,
                type: _selectedType,
                insuranceId: _searchInsuranceId,
                onlyAvailable: true,
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const LinearProgressIndicator();
                final products = snapshot.data!;
                if (products.isEmpty)
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('No matching products found.'),
                  );
                return ListView.separated(
                  shrinkWrap: true,
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final p = products[index];
                    return ListTile(
                      leading: Icon(
                        p.type == ItemType.DRUG
                            ? Icons.medication
                            : Icons.inventory_2,
                      ),
                      title: Text(
                        p.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(p.description ?? p.type.name),
                      trailing: IconButton(
                        icon: const Icon(Icons.add_circle),
                        onPressed: () => _addItem(p),
                        color: theme.colorScheme.primary,
                      ),
                      onTap: () => _addItem(p),
                    );
                  },
                );
              },
            ),
          ),
        const SizedBox(height: 48),
        _buildSectionTitle('Shopping Cart'),
        const SizedBox(height: 16),
        if (_cart.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(48.0),
              child: Column(
                children: [
                  Icon(
                    Icons.shopping_basket_outlined,
                    size: 48,
                    color: theme.dividerColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(color: theme.dividerColor),
                  ),
                ],
              ),
            ),
          )
        else ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Product',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                const SizedBox(
                  width: 100,
                  child: Center(
                    child: Text(
                      'Qty',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                if (_deviceType != DeviceType.CLINIC_INVENTORY) ...[
                  const SizedBox(width: 24),
                  const SizedBox(
                    width: 100,
                    child: Text(
                      'Unit Price',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 24),
                  const SizedBox(
                    width: 100,
                    child: Text(
                      'Total',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
                const SizedBox(width: 64),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _cart.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildCartItemRow(theme, index);
            },
          ),
          const SizedBox(height: 24),
          if (_deviceType != DeviceType.CLINIC_INVENTORY)
            _buildCartTotalsBox(theme)
          else
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Items:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                      Text(
                        '${_cart.fold<int>(0, (sum, item) => sum + item.quantity)} units',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No pricing information tracked for clinic inventory',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildCartTotalsBox(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Running Total',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                NumberFormat.currency(
                  symbol: 'RF ',
                  decimalDigits: 0,
                ).format(_cart.fold(0.0, (sum, item) => sum + item.itemTotal)),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          if (_selectedInsurance != null) ...[
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Insurance Pays (${100 - _selectedInsurance!.clientPercentage}%)',
                  style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                ),
                Text(
                  NumberFormat.currency(symbol: 'RF ', decimalDigits: 0).format(
                    _cart.fold(0.0, (sum, item) => sum + item.insurancePays),
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Patient Pays (${_selectedInsurance!.clientPercentage}%)',
                  style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                ),
                Text(
                  NumberFormat.currency(symbol: 'RF ', decimalDigits: 0).format(
                    _cart.fold(0.0, (sum, item) => sum + item.patientPays),
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCartItemRow(ThemeData theme, int index) {
    final item = _cart[index];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.product.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    PopupMenuButton<void>(
                      icon: Icon(Icons.inventory_2_outlined, size: 18),
                      tooltip: 'Select stock entries',
                      onSelected: (_) {},
                      itemBuilder: (BuildContext context) {
                        return [
                          PopupMenuItem<void>(
                            enabled: false,
                            child: _buildHybridStockSelectionView(
                              item,
                              context,
                            ),
                          ),
                        ];
                      },
                    ),
                  ],
                ),
                if (_deviceType == DeviceType.PHARMACY_RETAIL)
                  Text(
                    item.insuranceId != null
                        ? 'Covered by Insurance'
                        : 'Private Sale',
                    style: TextStyle(
                      fontSize: 12,
                      color: item.insuranceId != null ? Colors.blue : null,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _buildCartQtyControl(item),
          if (_deviceType != DeviceType.CLINIC_INVENTORY) ...[
            const SizedBox(width: 24),
            SizedBox(
              width: 100,
              child: TextFormField(
                controller: item.priceController,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (v) {
                  final newPrice = double.tryParse(v);
                  if (newPrice != null) {
                    setState(() {
                      item.price = newPrice;
                      _calculateTotalsForItem(item);
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 24),
            SizedBox(
              width: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    NumberFormat.currency(
                      symbol: 'RF ',
                      decimalDigits: 0,
                    ).format(item.itemTotal),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (item.insuranceId != null)
                    Text(
                      'Patient: ${NumberFormat.currency(symbol: 'RF ', decimalDigits: 0).format(item.patientPays)}',
                      style: const TextStyle(fontSize: 11, color: Colors.green),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(width: 16),
          IconButton(
            onPressed: () => setState(() {
              final removed = _cart.removeAt(index);
              removed.dispose();
            }),
            icon: const Icon(Icons.delete_outline, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildCartQtyControl(_StockOutItemForm item) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {
              if (item.quantity > 1) {
                setState(() {
                  item.quantity--;
                  _updateCartItemQuantity(item);
                });
              }
            },
            icon: const Icon(Icons.remove, size: 16),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          GestureDetector(
            onTap: () => _showQuantityEditDialog(item),
            child: Container(
              width: 32,
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${item.quantity}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                item.quantity++;
                _updateCartItemQuantity(item);
              });
            },
            icon: const Icon(Icons.add, size: 16),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  /// Show dialog to edit quantity directly
  Future<void> _showQuantityEditDialog(_StockOutItemForm item) async {
    final controller = TextEditingController(text: '${item.quantity}');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Quantity'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Quantity',
            hintText: 'Enter quantity',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newQty = int.tryParse(controller.text);
              if (newQty != null && newQty > 0) {
                Navigator.pop(context);
                setState(() {
                  item.quantity = newQty;
                  _updateCartItemQuantity(item);
                });
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  /// Redistribute quantity across selected stocks using FEFO
  /// Auto-selects additional stocks if needed
  Future<void> _updateCartItemQuantity(_StockOutItemForm item) async {
    final allStocks = await widget.database.getStockInsByProduct(
      item.product.id,
    );

    // Get all available stocks sorted by FEFO
    final availableStocks = allStocks.where((s) => s.quantity > 0).toList();

    if (availableStocks.isEmpty) return;

    availableStocks.sort((a, b) => _sortByFEFO(a, b));

    // Calculate total in currently selected stocks
    var selectedTotal = 0;
    for (final stock in availableStocks) {
      if (item.selectedStockIds.contains(stock.id)) {
        selectedTotal += stock.quantity;
      }
    }

    // Auto-select additional stocks if needed (silently)
    if (selectedTotal < item.quantity) {
      for (final stock in availableStocks) {
        if (selectedTotal >= item.quantity) break;

        if (!item.selectedStockIds.contains(stock.id)) {
          // Check if stock is used by another cart item
          final isUsedElsewhere = _cart.any(
            (cartItem) =>
                cartItem != item &&
                cartItem.selectedStockIds.contains(stock.id),
          );

          if (!isUsedElsewhere) {
            item.selectedStockIds.add(stock.id);
            selectedTotal += stock.quantity;
          }
        }
      }
    }

    // Get selected stocks and distribute quantity
    final selectedStocks = availableStocks
        .where((s) => item.selectedStockIds.contains(s.id))
        .toList();

    final allocations = <_StockAllocation>[];
    var remainingQty = item.quantity;

    for (final stock in selectedStocks) {
      if (remainingQty <= 0) break;

      final allocateQty = remainingQty > stock.quantity
          ? stock.quantity
          : remainingQty;
      allocations.add(
        _StockAllocation(stock: stock, quantityAllocated: allocateQty),
      );
      remainingQty -= allocateQty;
    }

    if (remainingQty > 0) {
      // Truly insufficient stock across all available entries
      item.quantity -= remainingQty; // Adjust to maximum available
    }

    item.allocations = allocations;
    _calculateTotalsForItem(item);
  }

  /// FEFO sort comparator
  int _sortByFEFO(StockIn a, StockIn b) {
    final aExpired =
        a.expiryDate != null && a.expiryDate!.isBefore(DateTime.now());
    final bExpired =
        b.expiryDate != null && b.expiryDate!.isBefore(DateTime.now());
    if (aExpired && !bExpired) return -1;
    if (!aExpired && bExpired) return 1;

    final aExpiringSoon =
        a.expiryDate != null &&
        a.expiryDate!.isBefore(DateTime.now().add(const Duration(days: 30))) &&
        !aExpired;
    final bExpiringSoon =
        b.expiryDate != null &&
        b.expiryDate!.isBefore(DateTime.now().add(const Duration(days: 30))) &&
        !bExpired;
    if (aExpiringSoon && !bExpiringSoon) return -1;
    if (!aExpiringSoon && bExpiringSoon) return 1;

    if (a.expiryDate != null && b.expiryDate != null) {
      return a.expiryDate!.compareTo(b.expiryDate!);
    }
    return a.createdAt.compareTo(b.createdAt);
  }

  /// Build unified hybrid stock selection view
  /// Shows all available stocks, allows click to select/deselect
  Widget _buildHybridStockSelectionView(
    _StockOutItemForm item,
    BuildContext context,
  ) {
    return FutureBuilder<List<StockIn>>(
      future: widget.database.getStockInsByProduct(item.product.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            width: 280,
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final allStocks = snapshot.data!;
        final availableStocks = allStocks.where((s) => s.quantity > 0).toList();

        if (availableStocks.isEmpty) {
          return const SizedBox(
            width: 280,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No stocks available'),
            ),
          );
        }

        // Sort by FEFO
        availableStocks.sort((a, b) => _sortByFEFO(a, b));

        // Calculate totals
        final selectedTotal = availableStocks
            .where((s) => item.selectedStockIds.contains(s.id))
            .fold<int>(0, (sum, s) => sum + s.quantity);

        return SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.inventory_2,
                          size: 16,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Select Stock Entries',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Need: ${item.quantity} units • Selected: $selectedTotal units',
                      style: TextStyle(
                        fontSize: 11,
                        color: selectedTotal >= item.quantity
                            ? Colors.green
                            : Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                constraints: const BoxConstraints(maxHeight: 300),
                child: SingleChildScrollView(
                  child: Column(
                    children: availableStocks.map((stock) {
                      final isSelected = item.selectedStockIds.contains(
                        stock.id,
                      );
                      final isExpired =
                          stock.expiryDate != null &&
                          stock.expiryDate!.isBefore(DateTime.now());
                      final daysUntilExpiry = stock.expiryDate != null
                          ? stock.expiryDate!.difference(DateTime.now()).inDays
                          : null;

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            if (isSelected) {
                              // Check if we can deselect this stock
                              final remainingTotal = availableStocks
                                  .where(
                                    (s) =>
                                        item.selectedStockIds.contains(s.id) &&
                                        s.id != stock.id,
                                  )
                                  .fold<int>(0, (sum, s) => sum + s.quantity);

                              if (remainingTotal < item.quantity) {
                                // Cannot deselect - would leave insufficient stock
                                Toast.warning(
                                  'Cannot deselect: Would leave insufficient stock ($remainingTotal < ${item.quantity}). '
                                  'Either select another stock first or reduce quantity.',
                                  duration: const Duration(seconds: 3),
                                );
                                return;
                              }

                              setState(() {
                                item.selectedStockIds.remove(stock.id);
                              });
                            } else {
                              // Select
                              setState(() {
                                item.selectedStockIds.add(stock.id);
                              });
                            }

                            // Recalculate allocations
                            await _updateCartItemQuantity(item);
                            // Force rebuild of popup
                            //                             Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey.withOpacity(0.2),
                                ),
                                left: BorderSide(
                                  color: isSelected
                                      ? Colors.blue
                                      : Colors.transparent,
                                  width: 4,
                                ),
                              ),
                              color: isSelected
                                  ? Colors.blue.withOpacity(0.08)
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: isSelected,
                                  onChanged:
                                      null, // Visual only, tap handled by InkWell
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Batch: ${stock.batchNumber ?? 'N/A'}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                                color: isSelected
                                                    ? Colors.blue
                                                    : null,
                                              ),
                                            ),
                                          ),
                                          if (isExpired)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius:
                                                    BorderRadius.circular(3),
                                              ),
                                              child: const Text(
                                                'EXPIRED',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            )
                                          else if (daysUntilExpiry != null &&
                                              daysUntilExpiry <= 30)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.orange,
                                                borderRadius:
                                                    BorderRadius.circular(3),
                                              ),
                                              child: Text(
                                                'Exp $daysUntilExpiry d',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${stock.quantity} units available',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          if (stock.location != null)
                                            Text(
                                              stock.location ?? '',
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.05),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(8),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tap stocks to select/deselect. Allocation follows FEFO order.',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    if (selectedTotal < item.quantity)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '⚠️ Insufficient coverage - additional stocks will auto-select when quantity increases',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.orange[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build read-only view of auto-allocated stocks
  // ignore: unused_element
  Widget _buildAutoAllocatedStocksView(_StockOutItemForm item) {
    return SizedBox(
      width: 280,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, size: 14, color: Colors.orange),
                const SizedBox(width: 6),
                const Text(
                  'Auto-Allocated Stocks:',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ],
            ),
          ),
          ...item.allocations.map((alloc) {
            final stock = alloc.stock;
            final isExpired =
                stock.expiryDate != null &&
                stock.expiryDate!.isBefore(DateTime.now());
            final daysUntilExpiry = stock.expiryDate != null
                ? stock.expiryDate!.difference(DateTime.now()).inDays
                : null;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.orange.withOpacity(0.05),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Batch: ${stock.batchNumber ?? 'N/A'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        if (isExpired)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: const Text(
                              'EXPIRED',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        else if (daysUntilExpiry != null &&
                            daysUntilExpiry <= 30)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              'Exp $daysUntilExpiry d',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Allocating: ${alloc.quantityAllocated} units',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (stock.location != null)
                          Text(
                            stock.location ?? '',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  /// Build manual stock selection view (can only be used when not in auto mode)
  // ignore: unused_element
  Widget _buildManualStockSelectionView(
    _StockOutItemForm item,
    BuildContext context,
  ) {
    return FutureBuilder<List<StockIn>>(
      future: widget.database.getStockInsByProduct(item.product.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(width: 200, child: CircularProgressIndicator());
        }

        final allStocks = snapshot.data!;
        final availableStocks = allStocks
            .where((s) => s.quantity > 0)
            .where(
              (s) =>
                  s.id == item.allocations[0].stock.id ||
                  !_cart.any(
                    (cartItem) => cartItem.allocations.any(
                      (alloc) => alloc.stock.id == s.id,
                    ),
                  ),
            )
            .toList();

        if (availableStocks.isEmpty) {
          return const SizedBox(
            width: 200,
            child: Text('No other stocks available'),
          );
        }

        // Sort by FEFO
        availableStocks.sort((a, b) {
          final aExpired =
              a.expiryDate != null && a.expiryDate!.isBefore(DateTime.now());
          final bExpired =
              b.expiryDate != null && b.expiryDate!.isBefore(DateTime.now());
          if (aExpired && !bExpired) return -1;
          if (!aExpired && bExpired) return 1;

          final aExpiringSoon =
              a.expiryDate != null &&
              a.expiryDate!.isBefore(
                DateTime.now().add(const Duration(days: 30)),
              ) &&
              !aExpired;
          final bExpiringSoon =
              b.expiryDate != null &&
              b.expiryDate!.isBefore(
                DateTime.now().add(const Duration(days: 30)),
              ) &&
              !bExpired;
          if (aExpiringSoon && !bExpiringSoon) return -1;
          if (!aExpiringSoon && bExpiringSoon) return 1;

          if (a.expiryDate != null && b.expiryDate != null) {
            return a.expiryDate!.compareTo(b.expiryDate!);
          }
          return a.createdAt.compareTo(b.createdAt);
        });

        return SizedBox(
          width: 280,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text(
                  'Select Stock Entry:',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              ...availableStocks.map((stock) {
                final isCurrentlySelected =
                    stock.id == item.allocations[0].stock.id;
                final isExpired =
                    stock.expiryDate != null &&
                    stock.expiryDate!.isBefore(DateTime.now());
                final daysUntilExpiry = stock.expiryDate != null
                    ? stock.expiryDate!.difference(DateTime.now()).inDays
                    : null;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        item.allocations = [
                          _StockAllocation(
                            stock: stock,
                            quantityAllocated: item.quantity,
                          ),
                        ];
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isCurrentlySelected
                              ? Colors.blue
                              : Colors.grey.withOpacity(0.3),
                          width: isCurrentlySelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(6),
                        color: isCurrentlySelected
                            ? Colors.blue.withOpacity(0.1)
                            : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Batch: ${stock.batchNumber ?? 'N/A'}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              if (isExpired)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: const Text(
                                    'EXPIRED',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              else if (daysUntilExpiry != null &&
                                  daysUntilExpiry <= 30)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Text(
                                    'Exp $daysUntilExpiry d',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${stock.quantity} units',
                                style: const TextStyle(fontSize: 11),
                              ),
                              if (stock.location != null)
                                Text(
                                  stock.location ?? '',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                          if (isCurrentlySelected)
                            const Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Text(
                                '✓ Currently Selected',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStep3() {
    final theme = Theme.of(context);
    final total = _cart.fold<double>(0, (sum, i) => sum + i.itemTotal);
    final patientTotal = _cart.fold<double>(0, (sum, i) => sum + i.patientPays);
    final insuranceTotal = _cart.fold<double>(
      0,
      (sum, i) => sum + i.insurancePays,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Review Summary'),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              if (_deviceType == DeviceType.PHARMACY_RETAIL) ...[
                _buildReviewRow(
                  'Patient',
                  _patientNameController.text.trim().isEmpty
                      ? 'Walk-in Customer'
                      : _patientNameController.text,
                ),
                if (_selectedInsurance != null)
                  _buildReviewRow(
                    'Insurance',
                    '${_selectedInsurance!.name} (${_selectedInsurance!.acronym})',
                  ),
              ] else if (_deviceType == DeviceType.PHARMACY_WHOLESALE) ...[
                _buildReviewRow(
                  'Destination Pharmacy',
                  _destinationPharmacyNameController.text,
                ),
                if (_destinationPharmacyPhoneController.text.isNotEmpty)
                  _buildReviewRow(
                    'Phone',
                    _destinationPharmacyPhoneController.text,
                  ),
                if (_tinNumberController.text.isNotEmpty)
                  _buildReviewRow('TIN', _tinNumberController.text),
              ] else if (_deviceType == DeviceType.CLINIC_INVENTORY) ...[
                _buildReviewRow(
                  'Clinic Service',
                  _selectedClinicService != null
                      ? _formatClinicServiceName(_selectedClinicService!)
                      : 'N/A',
                ),
              ],
              const Divider(height: 32),
              ..._cart.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${item.quantity} x ${item.product.name}'),
                      if (_deviceType != DeviceType.CLINIC_INVENTORY)
                        Text(
                          NumberFormat.currency(
                            symbol: 'RF ',
                            decimalDigits: 0,
                          ).format(item.itemTotal),
                        )
                      else
                        Text('${item.quantity} units'),
                    ],
                  ),
                ),
              ),
              const Divider(height: 32),
              if (_deviceType != DeviceType.CLINIC_INVENTORY) ...[
                _buildReviewRow(
                  'Grand Total',
                  NumberFormat.currency(
                    symbol: 'RF ',
                    decimalDigits: 0,
                  ).format(total),
                  isBold: true,
                ),
                if (insuranceTotal > 0) ...[
                  const SizedBox(height: 8),
                  _buildReviewRow(
                    'Insurance Portion',
                    NumberFormat.currency(
                      symbol: 'RF ',
                      decimalDigits: 0,
                    ).format(insuranceTotal),
                    color: Colors.blue,
                  ),
                  _buildReviewRow(
                    'Patient Portion',
                    NumberFormat.currency(
                      symbol: 'RF ',
                      decimalDigits: 0,
                    ).format(patientTotal),
                    color: Colors.green,
                    isBold: true,
                  ),
                ],
              ] else ...[
                _buildReviewRow(
                  'Total Units',
                  '${_cart.fold<int>(0, (sum, item) => sum + item.quantity)} units',
                  isBold: true,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildReviewRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : null,
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : null,
            fontSize: 16,
            color: color,
          ),
        ),
      ],
    );
  }

  // Helper from step 1
  Widget _buildStep1Filters() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButtonHideUnderline(
          child: DropdownButton<ItemType?>(
            value: _selectedType,
            hint: const Text('Type', style: TextStyle(fontSize: 13)),
            icon: const Icon(Icons.keyboard_arrow_down, size: 16),
            items: [
              const DropdownMenuItem(value: null, child: Text('All')),
              const DropdownMenuItem(
                value: ItemType.DRUG,
                child: Text('Drugs'),
              ),
              const DropdownMenuItem(
                value: ItemType.CONSUMABLE_DEVICE,
                child: Text('Consumables'),
              ),
            ],
            onChanged: (value) => setState(() => _selectedType = value),
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
