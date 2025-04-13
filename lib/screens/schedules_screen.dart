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
  late Future<List<Timetable>> _timetablesFuture;
  late Future<List<Schedule>> _schedulesFuture;
  String? _selectedTimetableId;
  
  @override
  void initState() {
    super.initState();
    _refreshData();
  }
  
  void _refreshData() {
    setState(() {
      _timetablesFuture = _apiService.fetchTimetables();
      _schedulesFuture = _apiService.fetchSchedules(timetableId: _selectedTimetableId);
    });
  }
  
  Future<void> _deleteSchedule(Schedule schedule) async {
    if (!mounted) return;
    
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Schedule'),
        content: Text('Are you sure you want to delete this schedule?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.dangerColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ?? false;
    
    if (!mounted) return;
    
    if (confirm) {
      try {
        if (schedule.id != null) {
          await _apiService.deleteSchedule(schedule.id!);
          
          if (!mounted) return;
          
          _refreshData();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Schedule deleted successfully')),
          );
        }
      } catch (e) {
        if (!mounted) return;
        showErrorDialog(context, 'Failed to delete schedule', e.toString());
      }
    }
  }
  
  void _showAddScheduleDialog(List<Timetable> timetables) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        child: ScheduleForm(
          timetables: timetables,
          onSubmit: (Schedule schedule) async {
            try {
              await _apiService.addSchedule(schedule);
              
              // Use dialogContext to close the dialog
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
              
              // Use the widget's mounting state for the main screen
              if (!mounted) return;
              
              _refreshData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Schedule added successfully')),
              );
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
                Text(
                  'Schedules',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.secondaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                FutureBuilder<List<Timetable>>(
                  future: _timetablesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting ||
                        snapshot.hasError ||
                        !snapshot.hasData) {
                      return const SizedBox();
                    }
                    
                    final timetables = snapshot.data!;
                    
                    return Row(
                      children: [
                        DropdownButton<String>(
                          hint: const Text('All Timetables'),
                          value: _selectedTimetableId,
                          onChanged: (value) {
                            setState(() {
                              _selectedTimetableId = value;
                              _schedulesFuture = _apiService.fetchSchedules(
                                timetableId: _selectedTimetableId,
                              );
                            });
                          },
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('All Timetables'),
                            ),
                            ...timetables.map((timetable) => DropdownMenuItem<String>(
                              value: timetable.id,
                              child: Text(timetable.name),
                            )),
                          ],
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: timetables.isEmpty
                              ? null
                              : () => _showAddScheduleDialog(timetables),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Schedule'),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Schedule>>(
                future: _schedulesFuture,
                builder: (context, scheduleSnapshot) {
                  if (scheduleSnapshot.connectionState == ConnectionState.waiting) {
                    return const LoadingIndicator();
                  } else if (scheduleSnapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading schedules: ${scheduleSnapshot.error}',
                        style: TextStyle(color: AppColors.dangerColor),
                      ),
                    );
                  } else if (!scheduleSnapshot.hasData || scheduleSnapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('No schedules found'),
                    );
                  } else {
                    final schedules = scheduleSnapshot.data!;
                    
                    return FutureBuilder<List<Timetable>>(
                      future: _timetablesFuture,
                      builder: (context, timetableSnapshot) {
                        if (timetableSnapshot.connectionState == ConnectionState.waiting ||
                            timetableSnapshot.hasError ||
                            !timetableSnapshot.hasData) {
                          return const LoadingIndicator();
                        }
                        
                        final timetables = timetableSnapshot.data!;
                        final timetableMap = {for (var t in timetables) t.id: t};
                        
                        return ListView.builder(
                          itemCount: schedules.length,
                          itemBuilder: (context, index) {
                            final schedule = schedules[index];
                            final timetable = timetableMap[schedule.timetableId];
                            
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
                                        Text(
                                          FormatUtils.formatTime(schedule.time),
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        BellBadge(bellType: schedule.bellType),
                                      ],
                                    ),
                                    if (timetable != null) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        'Timetable: ${timetable.name}',
                                        style: TextStyle(
                                          color: AppColors.secondaryColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: schedule.days
                                          .map((day) => DayBadge(day: day))
                                          .toList(),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton.icon(
                                          onPressed: () => _deleteSchedule(schedule),
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
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}