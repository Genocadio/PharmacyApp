import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CompactDateRangePicker extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const CompactDateRangePicker({
    Key? key,
    this.initialStartDate,
    this.initialEndDate,
    required this.firstDate,
    required this.lastDate,
  }) : super(key: key);

  @override
  State<CompactDateRangePicker> createState() => _CompactDateRangePickerState();
}

class _CompactDateRangePickerState extends State<CompactDateRangePicker> {
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate ?? DateTime.now();
    _endDate = widget.initialEndDate ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(
          maxWidth: 800,
        ), // Widened for side-by-side
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Select Date Range',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Side-by-side selectors
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildDateSelector('From', _startDate, (date) {
                    setState(() {
                      _startDate = date;
                      if (_startDate.isAfter(_endDate)) {
                        _endDate = _startDate;
                      }
                    });
                  }),
                ),
                const SizedBox(width: 24),
                // Divider line
                Container(
                  width: 1,
                  height: 60,
                  color: Theme.of(context).dividerColor,
                  margin: const EdgeInsets.only(top: 24),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildDateSelector('To', _endDate, (date) {
                    setState(() {
                      _endDate = date;
                      if (_endDate.isBefore(_startDate)) {
                        _startDate = _endDate;
                      }
                    });
                  }),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      DateTimeRange(start: _startDate, end: _endDate),
                    );
                  },
                  child: const Text('Apply'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector(
    String label,
    DateTime currentDate,
    Function(DateTime) onChanged,
  ) {
    // Generate lists
    final years = List.generate(
      widget.lastDate.year - widget.firstDate.year + 1,
      (index) => widget.firstDate.year + index,
    ).reversed.toList();

    final months = List.generate(12, (index) => index + 1);

    // Calculate days in current month
    final daysInMonth = DateTime(
      currentDate.year,
      currentDate.month + 1,
      0,
    ).day;
    final days = List.generate(daysInMonth, (index) => index + 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Day
            Expanded(
              flex: 2,
              child: _buildDropdown<int>(
                value: currentDate.day,
                items: days,
                labelBuilder: (day) => day.toString().padLeft(2, '0'),
                onChanged: (newDay) {
                  if (newDay != null) {
                    onChanged(
                      DateTime(currentDate.year, currentDate.month, newDay),
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            // Month
            Expanded(
              flex: 3,
              child: _buildDropdown<int>(
                value: currentDate.month,
                items: months,
                labelBuilder: (month) =>
                    DateFormat('MMM').format(DateTime(2024, month)),
                onChanged: (newMonth) {
                  if (newMonth != null) {
                    // Handle day overflow (e.g., Jan 31 -> Feb 28)
                    final newDaysInMonth = DateTime(
                      currentDate.year,
                      newMonth + 1,
                      0,
                    ).day;
                    final newDay = currentDate.day > newDaysInMonth
                        ? newDaysInMonth
                        : currentDate.day;
                    onChanged(DateTime(currentDate.year, newMonth, newDay));
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            // Year
            Expanded(
              flex: 3,
              child: _buildDropdown<int>(
                value: currentDate.year,
                items: years,
                labelBuilder: (year) => year.toString(),
                onChanged: (newYear) {
                  if (newYear != null) {
                    // Handle leap year (e.g., Feb 29 2024 -> Feb 28 2023)
                    final newDaysInMonth = DateTime(
                      newYear,
                      currentDate.month + 1,
                      0,
                    ).day;
                    final newDay = currentDate.day > newDaysInMonth
                        ? newDaysInMonth
                        : currentDate.day;
                    onChanged(DateTime(newYear, currentDate.month, newDay));
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required String Function(T) labelBuilder,
    required Function(T?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          menuMaxHeight: 300,
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    labelBuilder(item),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
