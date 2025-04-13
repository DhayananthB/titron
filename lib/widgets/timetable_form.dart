import 'package:flutter/material.dart';
import 'package:timetable_manager/models/models.dart';
import 'package:timetable_manager/utils/colors.dart';

class TimetableForm extends StatefulWidget {
  final Function(Timetable) onSubmit;
  final Timetable? timetable;

  const TimetableForm({
    super.key,
    required this.onSubmit,
    this.timetable,
  });

  @override
  State<TimetableForm> createState() => _TimetableFormState();
}

class _TimetableFormState extends State<TimetableForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final List<String> _daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  final Set<String> _selectedDays = {};

  @override
  void initState() {
    super.initState();
    if (widget.timetable != null) {
      _nameController.text = widget.timetable!.name;
      _selectedDays.addAll(widget.timetable!.days);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDays.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one day'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final timetable = Timetable(
        id: widget.timetable?.id ?? 'temp_id',
        name: _nameController.text.trim(),
        days: _selectedDays.toList(),
        isActive: widget.timetable?.isActive ?? false,
      );

      widget.onSubmit(timetable);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.timetable != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEdit ? 'Edit Timetable' : 'Add New Timetable',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Timetable Name',
                hintText: 'e.g., Semester 1 Schedule',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 24),
            const Text(
              'Select Days:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _daysOfWeek.map((day) {
                final isSelected = _selectedDays.contains(day);
                return FilterChip(
                  label: Text(day),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        _selectedDays.add(day);
                      } else {
                        _selectedDays.remove(day);
                      }
                    });
                  },
                  selectedColor: AppColors.primaryColor.withAlpha((0.2 * 255).toInt()),
                  checkmarkColor: AppColors.primaryColor,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primaryColor : Colors.black,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  isEdit ? 'Update Timetable' : 'Add Timetable',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
