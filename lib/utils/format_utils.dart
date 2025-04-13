class FormatUtils {
  static String formatTime(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length != 2) return timeString;
      
      final hour = int.parse(parts[0]);
      final minute = parts[1];
      
      final period = hour >= 12 ? 'PM' : 'AM';
      final formattedHour = hour % 12 == 0 ? 12 : hour % 12;
      
      return '$formattedHour:$minute $period';
    } catch (e) {
      return timeString;
    }
  }
  
  static String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}