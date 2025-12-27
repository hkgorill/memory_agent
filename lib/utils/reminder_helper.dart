import '../models/memory.dart';

class ReminderHelper {
  // Check if razor needs reminder
  static bool shouldShowRazorReminder(RazorMemory? razorMemory) {
    if (razorMemory == null) return false;

    final now = DateTime.now();
    final lastChanged = razorMemory.lastChangedAt;
    final notifyDay = razorMemory.notifyDay;

    // Calculate this month's notify date
    final thisMonthNotifyDate = DateTime(now.year, now.month, notifyDay);

    // If today is on or after the notify day of this month
    // AND last changed was before this month's notify date
    if (now.isAfter(thisMonthNotifyDate.subtract(const Duration(days: 1))) &&
        lastChanged.isBefore(thisMonthNotifyDate)) {
      return true;
    }

    return false;
  }

  // Get days until next razor replacement
  static int? daysUntilRazorReplacement(RazorMemory? razorMemory) {
    if (razorMemory == null) return null;

    final now = DateTime.now();
    final lastChanged = razorMemory.lastChangedAt;
    final notifyDay = razorMemory.notifyDay;

    // Calculate next notification date
    DateTime nextNotifyDate;
    if (now.day < notifyDay) {
      nextNotifyDate = DateTime(now.year, now.month, notifyDay);
    } else {
      nextNotifyDate = DateTime(now.year, now.month + 1, notifyDay);
    }

    return nextNotifyDate.difference(now).inDays;
  }

  // Get days since car wash
  static int? daysSinceCarWash(CarWashMemory? carWashMemory) {
    if (carWashMemory == null) return null;
    return DateTime.now().difference(carWashMemory.createdAt).inDays;
  }
}

