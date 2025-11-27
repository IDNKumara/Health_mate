import 'package:flutter/material.dart';
import 'package:health_mate/features/health_records/models/health_record.dart';
import 'package:health_mate/features/health_records/models/providers/health_record_provider.dart';
import 'package:health_mate/features/health_records/models/providers/screens/widgets/record_card.dart';
import 'package:provider/provider.dart';
import 'add_record_screen.dart';

class RecordsListScreen extends StatefulWidget {
  const RecordsListScreen({super.key});

  @override
  State<RecordsListScreen> createState() => _RecordsListScreenState();
}

class _RecordsListScreenState extends State<RecordsListScreen> {
  String? _selectedDate;

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        context.read<HealthRecordProvider>().loadRecords());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Health Records',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Consumer<HealthRecordProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage!,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (provider.records.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_rounded,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _selectedDate != null
                        ? 'No records found for this date'
                        : 'No health records yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add your first record',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              if (_selectedDate != null) _buildFilterChip(provider),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await provider.loadRecords();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.records.length,
                    itemBuilder: (context, index) {
                      final record = provider.records[index];
                      return RecordCard(
                        record: record,
                        onEdit: () => _editRecord(record),
                        onDelete: () => _deleteRecord(record),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(HealthRecordProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Chip(
        avatar: const Icon(Icons.filter_alt_rounded, size: 18),
        label: Text('Filtered: $_selectedDate'),
        deleteIcon: const Icon(Icons.close, size: 18),
        onDeleted: () {
          setState(() {
            _selectedDate = null;
          });
          provider.clearFilter();
        },
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
    );
  }

  void _showFilterDialog() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    ).then((selectedDate) {
      if (selectedDate != null) {
        final dateStr = selectedDate.toIso8601String().split('T')[0];
        setState(() {
          _selectedDate = dateStr;
        });
        context.read<HealthRecordProvider>().filterByDate(dateStr);
      }
    });
  }

  void _editRecord(HealthRecord record) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddRecordScreen(record: record),
      ),
    );
  }

  void _deleteRecord(HealthRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Delete Record'),
        content: const Text(
          'Are you sure you want to delete this health record?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context
                  .read<HealthRecordProvider>()
                  .deleteRecord(record.id!);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Record deleted successfully'
                          : 'Failed to delete record',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}