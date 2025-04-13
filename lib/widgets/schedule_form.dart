import 'package:flutter/material.dart';
import 'package:timetable_manager/models/models.dart';
import 'package:timetable_manager/utils/colors.dart';
import 'package:timetable_manager/utils/time_utils.dart'; // for time formatting

class ScheduleForm extends StatefulWidget {
  final List<Timetable> timetables;
  final Function(Schedule) onSubmit;

  const ScheduleForm({
    super.key,
    required this.timetables,
    required this.onSubmit,
  });

  @override
  State<ScheduleForm> createState() => _ScheduleFormState();
}

class _ScheduleFormState extends State<ScheduleForm> {
  final _formKey = GlobalKey<FormState>();
  Timetable? _selectedTimetable;
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedBellType = 'Short';
  final Map<String, bool> _selectedDays = {
    'Monday': false,
    'Tuesday': false,
    'Wednesday': false,
    'Thursday': false,
    'Friday': false,
    'Saturday': false,
    'Sunday': false,
  };

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _selectedTimetable != null) {
      final selectedDays = _selectedDays.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();

      if (selectedDays.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please select at least one day'),
            backgroundColor: AppColors.dangerColor,
          ),
        );
        return;
      }

      final schedule = Schedule(
        timetableId: _selectedTimetable!.id,
        time: TimeUtils.formatTimeOfDay(_selectedTime),
        bellType: _selectedBellType,
        days: selectedDays,
      );

      widget.onSubmit(schedule);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Schedule',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primaryColor,
                  ),
            ),
            const SizedBox(height: 24),

            // Timetable Dropdown
            DropdownButtonFormField<Timetable>(
              decoration: const InputDecoration(
                labelText: 'Select Timetable',
              ),
              value: _selectedTimetable,
              items: widget.timetables.map((timetable) {
                return DropdownMenuItem<Timetable>(
                  value: timetable,
                  child: Text(timetable.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTimetable = value;
                });
              },
              validator: (value) =>
                  value == null ? 'Please select a timetable' : null,
            ),
            const SizedBox(height: 16),

            // Time Picker
            InkWell(
              onTap: _pickTime,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Select Time',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  TimeUtils.formatTimeOfDay(_selectedTime),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Bell Type Dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Bell Type',
              ),
              value: _selectedBellType,
              items: ['longbell', 'shortbell'].map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedBellType = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Days selection
            const Text(
              'Days:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            ..._selectedDays.entries.map(
              (entry) => CheckboxListTile(
                title: Text(entry.key),
                value: entry.value,
                activeColor: AppColors.primaryColor,
                onChanged: (value) {
                  setState(() {
                    _selectedDays[entry.key] = value ?? false;
                  });
                },
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Add Schedule',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
