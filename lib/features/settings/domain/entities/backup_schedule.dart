enum BackupInterval {
  hourly,
  daily,
  weekly,
  biweekly,
  monthly;

  String get label {
    switch (this) {
      case BackupInterval.hourly:
        return 'Setiap Jam';
      case BackupInterval.daily:
        return 'Setiap Hari';
      case BackupInterval.weekly:
        return 'Setiap Minggu';
      case BackupInterval.biweekly:
        return '2 Minggu';
      case BackupInterval.monthly:
        return 'Setiap Bulan';
    }
  }

  bool get hasDayPicker =>
      this == BackupInterval.weekly ||
      this == BackupInterval.biweekly ||
      this == BackupInterval.monthly;

  bool get hasTimePicker => this != BackupInterval.hourly;
}

class BackupSchedule {
  final bool enabled;
  final BackupInterval interval;
  final int? day;
  final String time;
  final DateTime? lastRun;

  const BackupSchedule({
    this.enabled = false,
    this.interval = BackupInterval.daily,
    this.day,
    this.time = '02:00',
    this.lastRun,
  });

  BackupSchedule copyWith({
    bool? enabled,
    BackupInterval? interval,
    int? day,
    String? time,
    DateTime? lastRun,
    bool clearDay = false,
    bool clearLastRun = false,
  }) {
    return BackupSchedule(
      enabled: enabled ?? this.enabled,
      interval: interval ?? this.interval,
      day: clearDay ? null : day ?? this.day,
      time: time ?? this.time,
      lastRun: clearLastRun ? null : lastRun ?? this.lastRun,
    );
  }
}
