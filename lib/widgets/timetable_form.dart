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
  final Map<String, bool> _selectedDays = {
    'Monday': false,
    'Tuesday': false,
    'Wednesday': false,
    'Thursday': false,
    'Friday': false,
    'Saturday': false,
    'Sunday': false,
  };
  
  @override
  void initState() {
    super.initState();
    if (widget.timetable != null) {
      _nameController.text = widget.timetable!.name;
      for (final day in widget.timetable!.days) {
        if (_selectedDays.containsKey(day)) {
          _selectedDays[day] = true;
        }
      }
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
  
  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final days = _selectedDays.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();
      
      if (days.isEmpty) {
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
        days: days,
        isActive: widget.timetable?.isActive ?? false,
      );
      
      widget.onSubmit(timetable);
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
              widget.timetable == null ? 'Add New Timetable' : 'Edit Timetable',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Enter timetable name',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Days:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            ...
            _selectedDays.entries.map(
              (entry) => CheckboxListTile(
                title: Text(entry.key),
                value: entry.value,
                activeColor: AppColors.primaryColor,
                onChanged: (value) {
                  setState(() {
                    _selectedDays[entry.key] = value ?? false;
                  });
                },
                contentPadding: EdgeInsets.zero,
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleSubmit,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    widget.timetable == null ? 'Add Timetable' : 'Update Timetable',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}