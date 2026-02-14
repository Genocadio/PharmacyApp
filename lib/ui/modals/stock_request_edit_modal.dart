import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nexxpharma/data/database.dart';
import 'package:nexxpharma/services/stock_request_service.dart';
import 'package:nexxpharma/services/dto/stock_request_dto.dart';
import 'package:uuid/uuid.dart';
import 'package:nexxpharma/ui/widgets/toast.dart';

class StockRequestEditModal extends StatefulWidget {
  final AppDatabase database;
  final StockRequestService requestService;
  final String userId;
  final String userName;
  final StockRequestDTO? request; // If null, creating new

  const StockRequestEditModal({
    super.key,
    required this.database,
    required this.requestService,
    required this.userId,
    required this.userName,
    this.request,
  });

  @override
  State<StockRequestEditModal> createState() => _StockRequestEditModalState();
}

class _StockRequestEditModalState extends State<StockRequestEditModal> {
  final _uuid = const Uuid();
  late DateTime _requestDate;
  DateTime? _neededByDate;
  final _notesController = TextEditingController();
  final _searchController = TextEditingController();
  String _searchQuery = '';

  // Local state for items being edited
  List<StockRequestItemDTO> _items = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.request != null) {
      _requestDate = widget.request!.requestDate;
      _neededByDate = widget.request!.neededByDate;
      _notesController.text = widget.request!.notes ?? '';
      _items = List.from(widget.request!.items);
    } else {
      _requestDate = DateTime.now();
      _items = [];
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _addItem(Product product) {
    // Check if already exists
    final index = _items.indexWhere((item) => item.productId == product.id);
    if (index != -1) {
      setState(() {
        final existingItem = _items[index];
        _items[index] = StockRequestItemDTO(
          id: existingItem.id,
          requestId: existingItem.requestId,
          productId: existingItem.productId,
          productName: existingItem.productName,
          quantityRequested: existingItem.quantityRequested + 1,
          notes: existingItem.notes,
        );
      });
    } else {
      setState(() {
        _items.add(
          StockRequestItemDTO(
            id: _uuid.v4(),
            requestId:
                widget.request?.id ?? '', // Will be assigned on save if new
            productId: product.id,
            productName: product.name,
            quantityRequested: 1,
          ),
        );
      });
    }
    _searchController.clear();
    setState(() => _searchQuery = '');
  }

  void _removeItem(String itemId) {
    setState(() {
      _items.removeWhere((item) => item.id == itemId);
    });
  }

  void _updateQuantity(String itemId, int quantity) {
    if (quantity <= 0) return;
    setState(() {
      final index = _items.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        final item = _items[index];
        _items[index] = StockRequestItemDTO(
          id: item.id,
          requestId: item.requestId,
          productId: item.productId,
          productName: item.productName,
          quantityRequested: quantity,
          notes: item.notes,
        );
      }
    });
  }

  Future<void> _saveRequest({bool submit = false}) async {
    if (_items.isEmpty) {
      Toast.warning('Please add at least one item');
      return;
    }

    setState(() => _isSaving = true);

    try {
      String requestId;
      if (widget.request == null) {
        // Create new request with items atomically
        final newRequest = await widget.requestService.createRequestWithItems(
          userId: widget.userId,
          requestDate: _requestDate,
          items: _items
              .map(
                (item) => StockRequestItemCreateDTO(
                  productId: item.productId,
                  quantityRequested: item.quantityRequested,
                  notes: item.notes,
                ),
              )
              .toList(),
          neededByDate: _neededByDate,
          notes: _notesController.text,
          submit: submit,
        );
        requestId = newRequest.id;
      } else {
        // Update existing request
        requestId = widget.request!.id;
        await widget.requestService.updateRequest(
          requestId: requestId,
          requestDate: _requestDate,
          neededByDate: _neededByDate,
          notes: _notesController.text,
        );

        // Sync items (this is a bit inefficient without a bulk update, but works for now)
        // Get current items from DB to see what to delete
        final currentRequest = await widget.requestService.getRequestById(
          requestId,
        );
        for (final dbItem in currentRequest.items) {
          if (!_items.any((uiItem) => uiItem.productId == dbItem.productId)) {
            await widget.requestService.removeItemFromRequest(
              requestId: requestId,
              itemId: dbItem.id,
            );
          }
        }

        for (final uiItem in _items) {
          await widget.requestService.addItemToRequest(
            requestId: requestId,
            productId: uiItem.productId,
            quantityRequested: uiItem.quantityRequested,
            notes: uiItem.notes,
          );
        }

        if (submit) {
          await widget.requestService.submitRequest(requestId);
        }
      }

      // Sync items (this is a bit inefficient without a bulk update, but works for now)
      // Get current items from DB to see what to delete
      final currentRequest = await widget.requestService.getRequestById(
        requestId,
      );
      for (final dbItem in currentRequest.items) {
        if (!_items.any((uiItem) => uiItem.productId == dbItem.productId)) {
          await widget.requestService.removeItemFromRequest(
            requestId: requestId,
            itemId: dbItem.id,
          );
        }
      }

      for (final uiItem in _items) {
        await widget.requestService.addItemToRequest(
          requestId: requestId,
          productId: uiItem.productId,
          quantityRequested: uiItem.quantityRequested,
          notes: uiItem.notes,
        );
      }

      if (submit) {
        await widget.requestService.submitRequest(requestId);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving request: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.request == null ? 'New Stock Request' : 'Edit Request',
          ),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            if (!_isSaving) ...[
              TextButton(
                onPressed: _items.isEmpty
                    ? null
                    : () => _saveRequest(submit: false),
                child: const Text('Save Draft'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed: _items.isEmpty
                      ? null
                      : () => _saveRequest(submit: true),
                  child: const Text('Submit Request'),
                ),
              ),
            ] else
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
          ],
        ),
        body: Row(
          children: [
            // Left Column: Request Info & Product Search
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(right: BorderSide(color: theme.dividerColor)),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Request Details',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            'Request Date',
                            dateFormat.format(_requestDate),
                            Icons.calendar_today,
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _neededByDate ?? DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                              );
                              if (picked != null) {
                                setState(() => _neededByDate = picked);
                              }
                            },
                            child: _buildInfoItem(
                              'Needed By',
                              _neededByDate != null
                                  ? dateFormat.format(_neededByDate!)
                                  : 'Select Date',
                              Icons.event,
                              isEditable: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        hintText: 'Add any additional information here...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'Search Products',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search product name...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                    const SizedBox(height: 12),
                    Expanded(child: _buildProductSearchResults()),
                  ],
                ),
              ),
            ),
            // Right Column: Items List
            Expanded(
              flex: 3,
              child: Container(
                color: theme.colorScheme.surface.withOpacity(0.5),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Requested Items',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_items.length} Items',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: _items.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              itemCount: _items.length,
                              itemBuilder: (context, index) {
                                return _buildItemCard(_items[index]);
                              },
                            ),
                    ),
                    if (_items.isNotEmpty) ...[
                      const Divider(height: 48),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Total Quantity:',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _items
                                .fold<int>(
                                  0,
                                  (sum, item) => sum + item.quantityRequested,
                                )
                                .toString(),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    String label,
    String value,
    IconData icon, {
    bool isEditable = false,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(icon, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
              if (isEditable) ...[
                const SizedBox(width: 4),
                Icon(Icons.edit, size: 12, color: theme.colorScheme.primary),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductSearchResults() {
    if (_searchQuery.length < 2) {
      return Center(
        child: Text(
          'Type at least 2 characters to search',
          style: TextStyle(color: Colors.grey.shade500),
        ),
      );
    }

    return FutureBuilder<List<Product>>(
      future: widget.database.searchProductsByName(_searchQuery),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text('No products found matching "$_searchQuery"'),
          );
        }

        final products = snapshot.data!;
        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            final alreadyAdded = _items.any(
              (item) => item.productId == product.id,
            );

            return ListTile(
              title: Text(product.name),
              subtitle: Text(product.type.name),
              trailing: IconButton(
                icon: Icon(
                  alreadyAdded ? Icons.add_circle : Icons.add_circle_outline,
                  color: alreadyAdded ? Colors.green : null,
                ),
                onPressed: () => _addItem(product),
              ),
              onTap: () => _addItem(product),
            );
          },
        );
      },
    );
  }

  Widget _buildItemCard(StockRequestItemDTO item) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Note for specific item? Currently DTO has it but we need a way to edit it
                  InkWell(
                    onTap: () => _editItemNote(item),
                    child: Text(
                      item.notes?.isNotEmpty == true
                          ? item.notes!
                          : 'Add note...',
                      style: TextStyle(
                        fontSize: 12,
                        color: item.notes?.isNotEmpty == true
                            ? theme.textTheme.bodyMedium?.color
                            : theme.colorScheme.primary,
                        fontStyle: item.notes?.isNotEmpty == true
                            ? null
                            : FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 18),
                    onPressed: () =>
                        _updateQuantity(item.id, item.quantityRequested - 1),
                  ),
                  SizedBox(
                    width: 40,
                    child: Text(
                      item.quantityRequested.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 18),
                    onPressed: () =>
                        _updateQuantity(item.id, item.quantityRequested + 1),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _removeItem(item.id),
            ),
          ],
        ),
      ),
    );
  }

  void _editItemNote(StockRequestItemDTO item) {
    final controller = TextEditingController(text: item.notes);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Note for ${item.productName}'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter note...'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                final index = _items.indexWhere((i) => i.id == item.id);
                if (index != -1) {
                  final existing = _items[index];
                  _items[index] = StockRequestItemDTO(
                    id: existing.id,
                    requestId: existing.requestId,
                    productId: existing.productId,
                    productName: existing.productName,
                    quantityRequested: existing.quantityRequested,
                    notes: controller.text,
                  );
                }
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_shopping_cart, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Your request is empty',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Search products on the left to add them',
            style: TextStyle(color: Colors.grey.shade400),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 16,
                  color: Colors.orange.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  'Add products to enable saving',
                  style: TextStyle(color: Colors.orange.shade800, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
