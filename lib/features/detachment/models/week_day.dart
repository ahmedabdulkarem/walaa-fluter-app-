enum WeekDay {
  saturday,
  sunday,
  monday,
  tuesday,
  wednesday,
  thursday,
  friday;

  String get arabicLabel {
    switch (this) {
      case WeekDay.saturday:
        return 'السبت';
      case WeekDay.sunday:
        return 'الأحد';
      case WeekDay.monday:
        return 'الاثنين';
      case WeekDay.tuesday:
        return 'الثلاثاء';
      case WeekDay.wednesday:
        return 'الأربعاء';
      case WeekDay.thursday:
        return 'الخميس';
      case WeekDay.friday:
        return 'الجمعة';
    }
  }

  String get storageKey => name;

  static WeekDay fromStorageKey(String key) {
    return WeekDay.values.firstWhere(
      (d) => d.storageKey == key,
      orElse: () => WeekDay.saturday,
    );
  }
}
