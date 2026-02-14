import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:nexxpharma/data/database.dart';
import 'package:nexxpharma/data/tables.dart';

class CatalogScreen extends StatefulWidget {
  final AppDatabase database;

  const CatalogScreen({super.key, required this.database});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  String _searchQuery = '';
  ItemType? _selectedType;
  String? _selectedInsuranceId;
  bool _isDocked = false;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Formats units for display, specifically mapping 'Pc_s' to 'pieces'
  String _formatUnit(String? unit) {
    if (unit == null) return 'Unit';
    if (unit == 'Pc_s') return 'pieces';
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

  void _showInsuranceDetails(Product product) async {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.primary;
    final (mainName, others) = _getParsedNames(product.name, _searchQuery);

    final productInsurances = await widget.database.getInsurancesForProduct(
      product.id,
    );
    final insurances = await widget.database.getAllInsurances();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mainName,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: accentColor,
                              ),
                            ),
                            if (others.isNotEmpty)
                              Text(
                                'Other Name: ${others.join(", ")}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  color: theme.textTheme.bodyMedium?.color
                                      ?.withOpacity(0.6),
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.light
                          ? Colors.grey[100]
                          : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildInfoBadge(
                              theme,
                              product.type == ItemType.DRUG
                                  ? 'Drug'
                                  : 'Consumable',
                              product.type == ItemType.DRUG
                                  ? Colors.blue
                                  : Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            _buildInfoBadge(
                              theme,
                              _formatUnit(product.sellingUnit),
                              Colors.grey,
                            ),
                          ],
                        ),
                        if (product.description != null &&
                            product.description!.isNotEmpty &&
                            product.description!.toLowerCase() !=
                                'no comment') ...[
                          const SizedBox(height: 12),
                          Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.description!,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Insurance Coverage',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(
                        0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (productInsurances.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: Text(
                          'No insurance coverage found for this product.',
                        ),
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: productInsurances.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final pi = productInsurances[index];
                          final insurance = insurances.firstWhere(
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
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  insurance.acronym,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${pi.cost.toStringAsFixed(2)} RWF',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: accentColor,
                                      ),
                                    ),
                                    Text(
                                      'Per ${_formatUnit(pi.unit.name)}',
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoBadge(ThemeData theme, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildProductItem(
    Product product,
    ThemeData theme,
    Color accentColor, {
    bool isGrid = false,
  }) {
    final (mainName, others) = _getParsedNames(product.name, _searchQuery);

    return Card(
      elevation: 0,
      margin: isGrid ? EdgeInsets.zero : const EdgeInsets.only(bottom: 12),
      color: theme.brightness == Brightness.light
          ? Colors.white
          : Colors.white.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: InkWell(
        onTap: () => _showInsuranceDetails(product),
        borderRadius: BorderRadius.circular(16),
        child: isGrid
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: accentColor.withOpacity(0.1),
                      child: Icon(
                        product.type == ItemType.DRUG
                            ? Icons.medication
                            : Icons.inventory_2,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      mainName,
                      textAlign: TextAlign.center,
                      maxLines: others.isNotEmpty ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (others.isNotEmpty)
                      Text(
                        others.join(", "),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          color: theme.textTheme.bodySmall?.color?.withOpacity(
                            0.6,
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatUnit(product.sellingUnit)} • ${product.type == ItemType.DRUG ? 'Drug' : 'Consumable'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              )
            : ListTile(
                leading: CircleAvatar(
                  backgroundColor: accentColor.withOpacity(0.1),
                  child: Icon(
                    product.type == ItemType.DRUG
                        ? Icons.medication
                        : Icons.inventory_2,
                    color: accentColor,
                  ),
                ),
                title: Text(
                  mainName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (others.isNotEmpty)
                      Text(
                        'Other Name: ${others.join(", ")}',
                        style: TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: theme.textTheme.bodySmall?.color?.withOpacity(
                            0.6,
                          ),
                        ),
                      ),
                    Text(
                      '${product.type == ItemType.DRUG ? 'Drug' : 'Consumable'} • ${_formatUnit(product.sellingUnit)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void _onScroll() {
    // Auto-collapse if scrolling (even if filters are active)
    if (_isExpanded) {
      setState(() {
        _isExpanded = false;
      });
    }

    final docked = _scrollController.offset > 60;
    if (docked != _isDocked) {
      setState(() {
        _isDocked = docked;
      });
    }
  }

  bool get _hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _selectedType != null ||
      _selectedInsuranceId != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.primary;
    final showFullBar = _isExpanded || _hasActiveFilters;

    return Scaffold(
      appBar: AppBar(title: const Text('Product Catalog'), elevation: 0),
      extendBodyBehindAppBar: false,
      body: Stack(
        children: [
          // Background content layer
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                if (_isExpanded) {
                  setState(() {
                    _isExpanded = false;
                  });
                }
                // Unfocus search if open
                FocusScope.of(context).unfocus();
              },
              behavior: HitTestBehavior.translucent,
              child: FutureBuilder<List<Product>>(
                future: widget.database.getFilteredProducts(
                  searchQuery: _searchQuery,
                  type: _selectedType,
                  insuranceId: _selectedInsuranceId,
                ),
                builder: (context, snapshot) {
                  final products = snapshot.data ?? [];

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final isDesktop = constraints.maxWidth > 700;

                      return CustomScrollView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          const SliverToBoxAdapter(
                            child: SizedBox(height: 100),
                          ),
                          if (snapshot.connectionState ==
                              ConnectionState.waiting)
                            const SliverFillRemaining(
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (products.isEmpty)
                            const SliverFillRemaining(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.search_off,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 16),
                                    const Text('No matches found.'),
                                  ],
                                ),
                              ),
                            )
                          else if (isDesktop)
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 0,
                              ),
                              sliver: SliverGrid(
                                gridDelegate:
                                    const SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 250,
                                      mainAxisExtent: 210,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                    ),
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) => _buildProductItem(
                                    products[index],
                                    theme,
                                    accentColor,
                                    isGrid: true,
                                  ),
                                  childCount: products.length,
                                ),
                              ),
                            )
                          else
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) => _buildProductItem(
                                    products[index],
                                    theme,
                                    accentColor,
                                    isGrid: false,
                                  ),
                                  childCount: products.length,
                                ),
                              ),
                            ),
                          const SliverToBoxAdapter(child: SizedBox(height: 40)),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),

          // Collapsible Spotlight Floating Search Bar
          Positioned(
            top: _isDocked
                ? 20
                : (60 -
                          (_scrollController.hasClients
                              ? _scrollController.offset
                              : 0))
                      .clamp(20, 100)
                      .toDouble(),
            left: 16,
            right: 16,
            child: Align(
              alignment: Alignment.centerRight,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Spotlight Glass Container
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      width: showFullBar ? 800 : 56,
                      height: showFullBar ? 72 : 56,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          showFullBar ? 24 : 28,
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.brightness == Brightness.light
                                  ? Colors.white.withOpacity(0.8)
                                  : Colors.grey[900]?.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(
                                showFullBar ? 24 : 28,
                              ),
                              border: Border.all(
                                color: theme.dividerColor.withOpacity(0.1),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: showFullBar
                                ? SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    child: SizedBox(
                                      width:
                                          800 -
                                          24, // Matches maxWidth minus padding
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                controller: _searchController,
                                                autofocus: _isExpanded,
                                                decoration: InputDecoration(
                                                  hintText:
                                                      'Search inventory...',
                                                  prefixIcon: const Icon(
                                                    Icons.search,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          16,
                                                        ),
                                                    borderSide: BorderSide.none,
                                                  ),
                                                  filled: true,
                                                  fillColor:
                                                      theme.brightness ==
                                                          Brightness.light
                                                      ? theme
                                                            .scaffoldBackgroundColor
                                                      : Colors.white
                                                            .withOpacity(0.05),
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                      ),
                                                ),
                                                onChanged: (value) {
                                                  setState(() {
                                                    _searchQuery = value;
                                                  });
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            _buildInsuranceDropdown(theme),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                : InkWell(
                                    onTap: () =>
                                        setState(() => _isExpanded = true),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        const Icon(Icons.search, size: 24),
                                        if (_hasActiveFilters)
                                          Positioned(
                                            top: 14,
                                            right: 14,
                                            child: Container(
                                              width: 10,
                                              height: 10,
                                              decoration: BoxDecoration(
                                                color:
                                                    theme.colorScheme.primary,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 1.5,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    if (showFullBar) ...[
                      const SizedBox(height: 12),
                      // Floating Type Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _buildFloatingChip(
                              'All',
                              _selectedType == null,
                              () => setState(() => _selectedType = null),
                              theme,
                            ),
                            const SizedBox(width: 8),
                            _buildFloatingChip(
                              'Drugs',
                              _selectedType == ItemType.DRUG,
                              () =>
                                  setState(() => _selectedType = ItemType.DRUG),
                              theme,
                            ),
                            const SizedBox(width: 8),
                            _buildFloatingChip(
                              'Consumables',
                              _selectedType == ItemType.CONSUMABLE_DEVICE,
                              () => setState(
                                () =>
                                    _selectedType = ItemType.CONSUMABLE_DEVICE,
                              ),
                              theme,
                            ),
                            if (_hasActiveFilters) ...[
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _searchController.clear();
                                    _searchQuery = '';
                                    _selectedType = null;
                                    _selectedInsuranceId = null;
                                    _isExpanded = false; // Collapse on clear
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.error.withOpacity(
                                      0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: theme.colorScheme.error
                                          .withOpacity(0.2),
                                    ),
                                  ),
                                  child: Text(
                                    'Clear',
                                    style: TextStyle(
                                      color: theme.colorScheme.error,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
    ThemeData theme,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : (theme.brightness == Brightness.light
                        ? Colors.white
                        : Colors.grey[900])
                    ?.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.dividerColor.withOpacity(0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : theme.textTheme.bodyMedium?.color,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildInsuranceDropdown(ThemeData theme) {
    return StreamBuilder<List<Insurance>>(
      stream: widget.database.watchAllInsurances(),
      builder: (context, snapshot) {
        final insurances = snapshot.data ?? [];
        return Container(
          width: 150,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: theme.brightness == Brightness.light
                ? theme.scaffoldBackgroundColor
                : Colors.white.withOpacity(0.05),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedInsuranceId,
              isExpanded: true,
              hint: const Text('Insurance', style: TextStyle(fontSize: 13)),
              icon: const Icon(Icons.shield_outlined, size: 16),
              borderRadius: BorderRadius.circular(16),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('All', style: TextStyle(fontSize: 13)),
                ),
                ...insurances.map((ins) {
                  return DropdownMenuItem<String>(
                    value: ins.id,
                    child: Text(
                      ins.acronym,
                      style: const TextStyle(fontSize: 13),
                    ),
                  );
                }),
              ],
              onChanged: (val) {
                setState(() {
                  _selectedInsuranceId = val;
                });
              },
            ),
          ),
        );
      },
    );
  }
}
