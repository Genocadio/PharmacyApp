import 'package:flutter/material.dart';
import 'package:nexxpharma/data/database.dart';
import 'package:nexxpharma/data/tables.dart';
import 'package:nexxpharma/services/auth_service.dart';
import 'package:nexxpharma/services/stock_request_service.dart';
import 'package:nexxpharma/services/dto/stock_request_dto.dart';
import 'package:intl/intl.dart';
import 'package:nexxpharma/ui/modals/stock_request_edit_modal.dart';
import 'package:nexxpharma/services/stock_request_pdf_service.dart';
import 'package:printing/printing.dart';
import 'package:nexxpharma/ui/widgets/toast.dart';

class StockRequestScreen extends StatefulWidget {
  final AppDatabase database;
  final AuthService authService;

  const StockRequestScreen({
    super.key,
    required this.database,
    required this.authService,
  });

  @override
  State<StockRequestScreen> createState() => _StockRequestScreenState();
}

class _StockRequestScreenState extends State<StockRequestScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final StockRequestService _requestService;

  List<StockRequestDTO> _allRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _requestService = StockRequestService(widget.database);
    _loadRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    try {
      final requests = await _requestService.getAllRequests();
      setState(() {
        _allRequests = requests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading requests: $e')));
      }
    }
  }

  List<StockRequestDTO> _filterByStatus(StockRequestStatus? status) {
    if (status == null) return _allRequests;
    return _allRequests.where((r) => r.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Requests'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Drafts'),
            Tab(text: 'Submitted'),
            Tab(text: 'Received'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildRequestList(_filterByStatus(null)),
                _buildRequestList(_filterByStatus(StockRequestStatus.DRAFT)),
                _buildRequestList(
                  _filterByStatus(StockRequestStatus.SUBMITTED),
                ),
                _buildRequestList(_filterByStatus(StockRequestStatus.RECEIVED)),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createNewRequest(),
        icon: const Icon(Icons.add),
        label: const Text('New Request'),
      ),
    );
  }

  Widget _buildRequestList(List<StockRequestDTO> requests) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No requests found',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          return _buildRequestCard(request);
        },
      ),
    );
  }

  Widget _buildRequestCard(StockRequestDTO request) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _viewRequestDetails(request),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
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
                          request.requestNumber,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'By ${request.userName}',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(request.status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dateFormat.format(request.requestDate),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  if (request.neededByDate != null) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.event, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      'Need by: ${dateFormat.format(request.neededByDate!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.inventory_2,
                    size: 14,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${request.totalItems} items (${request.totalQuantity} qty)',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              if (request.status == StockRequestStatus.DRAFT) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _deleteRequest(request),
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text('Delete'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _editRequest(request),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(StockRequestStatus status) {
    Color color;
    IconData icon;

    switch (status) {
      case StockRequestStatus.DRAFT:
        color = Colors.grey;
        icon = Icons.edit;
        break;
      case StockRequestStatus.SUBMITTED:
        color = Colors.blue;
        icon = Icons.send;
        break;
      case StockRequestStatus.RECEIVED:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            status.name.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createNewRequest() async {
    final currentUser = widget.authService.currentUser;
    if (currentUser == null) {
      Toast.warning('Please log in to create a request');
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StockRequestEditModal(
        database: widget.database,
        requestService: _requestService,
        userId: currentUser.id,
        userName: currentUser.names,
      ),
    );

    if (result == true) {
      _loadRequests();
      Toast.success('Request created successfully');
    }
  }

  Future<void> _editRequest(StockRequestDTO request) async {
    final currentUser = widget.authService.currentUser;
    if (currentUser == null) return;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StockRequestEditModal(
        database: widget.database,
        requestService: _requestService,
        userId: currentUser.id,
        userName: currentUser.names,
        request: request,
      ),
    );

    if (result == true) {
      _loadRequests();
      Toast.success('Request updated successfully');
    }
  }

  void _viewRequestDetails(StockRequestDTO request) {
    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(
            title: Text('Request Details: ${request.requestNumber}'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (request.status != StockRequestStatus.RECEIVED)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton.icon(
                    onPressed: () => _markAsReceived(request),
                    icon: const Icon(Icons.download_done),
                    label: const Text('Mark Received'),
                  ),
                ),
            ],
          ),
          body: Row(
            children: [
              // Details Panel
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                        'Status',
                        _buildStatusBadge(request.status),
                      ),
                      const Divider(height: 32),
                      _buildDetailItem('Request Number', request.requestNumber),
                      _buildDetailItem('Requested By', request.userName),
                      _buildDetailItem(
                        'Request Date',
                        DateFormat(
                          'MMM dd, yyyy HH:mm',
                        ).format(request.requestDate),
                      ),
                      if (request.neededByDate != null)
                        _buildDetailItem(
                          'Needed By',
                          DateFormat(
                            'MMM dd, yyyy',
                          ).format(request.neededByDate!),
                        ),
                      if (request.notes?.isNotEmpty == true)
                        _buildDetailItem('Notes', request.notes!),
                      const SizedBox(height: 24),
                      Text(
                        'Items',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...request.items.map(
                        (item) => ListTile(
                          title: Text(item.productName),
                          subtitle: item.notes != null
                              ? Text(item.notes!)
                              : null,
                          trailing: Text(
                            'Qty: ${item.quantityRequested}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // PDF Preview Panel
              Expanded(
                flex: 3,
                child: Container(
                  color: Colors.grey.shade200,
                  child: PdfPreview(
                    build: (format) =>
                        StockRequestPDFService.generateRequestPDF(request),
                    allowPrinting: true,
                    allowSharing: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, Widget content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          content,
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Future<void> _markAsReceived(StockRequestDTO request) async {
    try {
      await _requestService.markAsReceived(request.id);
      if (mounted) {
        Navigator.pop(context); // Close details dialog
        _loadRequests();
        Toast.success('Request marked as received');
      }
    } catch (e) {
      Toast.error('Error updating status: $e');
    }
  }

  Future<void> _deleteRequest(StockRequestDTO request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Request'),
        content: Text(
          'Are you sure you want to delete ${request.requestNumber}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _requestService.deleteRequest(request.id);
        await _loadRequests();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Request deleted')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error deleting request: $e')));
        }
      }
    }
  }
}
