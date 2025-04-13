import 'package:flutter/material.dart';
import 'package:timetable_manager/models/models.dart';
import 'package:timetable_manager/services/api_service.dart';
import 'package:timetable_manager/utils/colors.dart';
import 'package:timetable_manager/widgets/day_badge.dart';
import 'package:timetable_manager/widgets/error_dialog.dart';
import 'package:timetable_manager/widgets/loading_indicator.dart';
import 'package:timetable_manager/widgets/timetable_form.dart';

class TimetablesScreen extends StatefulWidget {
  const TimetablesScreen({super.key});

  @override
  State<TimetablesScreen> createState() => _TimetablesScreenState();
}

class _TimetablesScreenState extends State<TimetablesScreen> {
  final ApiService _apiService = ApiService();
  List<Timetable> _timetables = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTimetables();
  }

  void _loadTimetables() async {
    setState(() => _isLoading = true);
    try {
      final timetables = await _apiService.fetchTimetables();
      setState(() {
        _timetables = timetables;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        showErrorDialog(context, 'Error loading timetables', e.toString());
      }
    }
  }

  Future<void> _deleteTimetable(Timetable timetable) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Timetable'),
        content: Text(
          'Are you sure you want to delete "${timetable.name}"? All associated schedules will also be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.dangerColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _apiService.deleteTimetable(timetable.id);
        setState(() {
          _timetables.removeWhere((t) => t.id == timetable.id);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Timetable deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          showErrorDialog(context, 'Failed to delete timetable', e.toString());
        }
      }
    }
  }

  Future<void> _setActiveTimetable(Timetable timetable) async {
    try {
      await _apiService.setActiveTimetable(timetable.id);
      setState(() {
        for (var t in _timetables) {
          t.isActive = false;
        }
        timetable.isActive = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${timetable.name} set as active')),
        );
      }
    } catch (e) {
      if (mounted) {
        showErrorDialog(context, 'Failed to set active timetable', e.toString());
      }
    }
  }

  void _showAddTimetableDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        child: TimetableForm(
          onSubmit: (Timetable timetable) async {
            Navigator.of(dialogContext).pop();
            try {
              final newTimetable = Timetable(
                id: '', // Let the backend assign ID
                name: timetable.name,
                days: timetable.days,
                isActive: false,
              );
              final created = await _apiService.addTimetable(newTimetable);
              setState(() {
                _timetables.add(created);
              });
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Timetable added successfully')),
                );
              }
            } catch (e, stackTrace) {
              debugPrint('Error adding timetable: $e');
              debugPrint(stackTrace.toString());
              if (mounted) {
                showErrorDialog(context, 'Failed to add timetable', e.toString());
              }
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Timetables',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.secondaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                ElevatedButton.icon(
                  onPressed: _showAddTimetableDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Timetable'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Timetables list or loading/error
            Expanded(
              child: _isLoading
                  ? const LoadingIndicator()
                  : _timetables.isEmpty
                      ? const Center(child: Text('No timetables found'))
                      : ListView.builder(
                          itemCount: _timetables.length,
                          itemBuilder: (context, index) {
                            final timetable = _timetables[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Title & Active Badge
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          timetable.name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (timetable.isActive)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.accentColor,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Text(
                                              'Active',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: timetable.days
                                          .map((day) => DayBadge(day: day))
                                          .toList(),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        if (!timetable.isActive)
                                          TextButton.icon(
                                            onPressed: () => _setActiveTimetable(timetable),
                                            icon: const Icon(Icons.check_circle_outline),
                                            label: const Text('Set Active'),
                                          ),
                                        const SizedBox(width: 8),
                                        TextButton.icon(
                                          onPressed: () => _deleteTimetable(timetable),
                                          icon: const Icon(Icons.delete_outline),
                                          style: TextButton.styleFrom(
                                            foregroundColor: AppColors.dangerColor,
                                          ),
                                          label: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
