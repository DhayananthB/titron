// Updated schedules_screen.dart without page reload on add/delete
import 'package:flutter/material.dart';
import 'package:timetable_manager/models/models.dart';
import 'package:timetable_manager/services/api_service.dart';
import 'package:timetable_manager/utils/colors.dart';
import 'package:timetable_manager/utils/format_utils.dart';
import 'package:timetable_manager/widgets/bell_badge.dart';
import 'package:timetable_manager/widgets/day_badge.dart';
import 'package:timetable_manager/widgets/error_dialog.dart';
import 'package:timetable_manager/widgets/loading_indicator.dart';
import 'package:timetable_manager/widgets/schedule_form.dart';

class SchedulesScreen extends StatefulWidget {
  const SchedulesScreen({super.key});

  @override
  State<SchedulesScreen> createState() => _SchedulesScreenState();
}

class _SchedulesScreenState extends State<SchedulesScreen> {
  final ApiService _apiService = ApiService();
  List<Timetable> _timetables = [];
  List<Schedule> _schedules = [];
  String? _selectedTimetableId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final timetables = await _apiService.fetchTimetables();
      final schedules = await _apiService.fetchSchedules(timetableId: _selectedTimetableId);
      if (!mounted) return;
      setState(() {
        _timetables = timetables;
        _schedules = schedules;
      });
    } catch (e) {
      if (!mounted) return;
      showErrorDialog(context, 'Failed to load data', e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteSchedule(Schedule schedule) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Schedule'),
        content: const Text('Are you sure you want to delete this schedule?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.dangerColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true || schedule.id == null) return;

    try {
      await _apiService.deleteSchedule(schedule.id!);
      if (!mounted) return;
      setState(() => _schedules.removeWhere((s) => s.id == schedule.id));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Schedule deleted')));
    } catch (e) {
      if (!mounted) return;
      showErrorDialog(context, 'Delete failed', e.toString());
    }
  }

  void _showAddScheduleDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        child: ScheduleForm(
          timetables: _timetables,
          onSubmit: (Schedule schedule) async {
            try {
              await _apiService.addSchedule(schedule);
              if (!mounted || !dialogContext.mounted) return;
              Navigator.pop(dialogContext);
              final updatedSchedules = await _apiService.fetchSchedules(timetableId: _selectedTimetableId);
              if (!mounted) return;
              setState(() => _schedules = updatedSchedules);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Schedule added')));
            } catch (e) {
              if (!mounted) return;
              showErrorDialog(context, 'Failed to add schedule', e.toString());
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Schedules', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.secondaryColor)),
                Row(
                  children: [
                    DropdownButton<String>(
                      hint: const Text('All Timetables'),
                      value: _selectedTimetableId,
                      onChanged: (value) async {
                        setState(() => _selectedTimetableId = value);
                        final schedules = await _apiService.fetchSchedules(timetableId: value);
                        if (mounted) setState(() => _schedules = schedules);
                      },
                      items: [
                        const DropdownMenuItem<String>(value: null, child: Text('All Timetables')),
                        ..._timetables.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))),
                      ],
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _timetables.isEmpty ? null : _showAddScheduleDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Schedule'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const LoadingIndicator()
                : _schedules.isEmpty
                    ? const Center(child: Text('No schedules found'))
                    : Expanded(
                        child: ListView.builder(
                          itemCount: _schedules.length,
                          itemBuilder: (context, index) {
                            final schedule = _schedules[index];
                            final timetable = _timetables.firstWhere(
                              (t) => t.id == schedule.timetableId,
                              orElse: () => Timetable(id: '', name: 'Unknown', days: []),
                            );
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(FormatUtils.formatTime(schedule.time), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                        BellBadge(bellType: schedule.bellType),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text('Timetable: ${timetable.name}', style: TextStyle(fontWeight: FontWeight.w500, color: AppColors.secondaryColor)),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: schedule.days.map((d) => DayBadge(day: d)).toList(),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton.icon(
                                          onPressed: () => _deleteSchedule(schedule),
                                          icon: const Icon(Icons.delete_outline),
                                          style: TextButton.styleFrom(foregroundColor: AppColors.dangerColor),
                                          label: const Text('Delete'),
                                        ),
                                      ],
                                    )
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
