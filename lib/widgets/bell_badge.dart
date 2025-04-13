import 'package:flutter/material.dart';
import 'package:timetable_manager/utils/colors.dart';

class BellBadge extends StatelessWidget {
  final String bellType;
  
  const BellBadge({super.key, required this.bellType});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _formatBellType(bellType),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
  
  String _formatBellType(String type) {
    return type.substring(0, 1).toUpperCase() + type.substring(1);
  }
}