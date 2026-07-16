import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:remixicon/remixicon.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/backup_scheduler_service.dart';
import '../../../../di/injection.dart';
import '../../domain/entities/backup_schedule.dart';
import '../../data/datasources/backup_schedule_local_datasource.dart';
import '../../../subscription/presentation/utils/pro_gate.dart';

typedef _C = AppColors;

class BackupScheduleSheet extends StatefulWidget {
  const BackupScheduleSheet({super.key});

  @override
  State<BackupScheduleSheet> createState() => _BackupScheduleSheetState();
}

class _BackupScheduleSheetState extends State<BackupScheduleSheet> {
  bool _loading = true;
  BackupSchedule _schedule = const BackupSchedule();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ds = BackupScheduleLocalDataSource(sl());
    final schedule = await ds.load();
    if (!mounted) return;
    setState(() {
      _schedule = schedule;
      _loading = false;
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final ds = BackupScheduleLocalDataSource(sl());
      await ds.save(_schedule);
      await sl<BackupSchedulerService>().apply(_schedule);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jadwal auto backup disimpan')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPro = isProEntitled(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.borderLight),
      ),
      child: _loading
          ? const Center(child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(RemixIcons.clockwise_2_line, color: Color(0xFF16A34A), size: 18),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text('Auto Backup',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _C.textPrimary)),
                    ),
                    if (!isPro)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3D6),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFFFE5A3)),
                        ),
                        child: const Text('PRO', style: TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF995500))),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('Cadangan otomatis berkala ke cloud.',
                  style: TextStyle(fontSize: 12, color: _C.textSecondary)),
                const SizedBox(height: 20),
                _buildToggle(),
                if (_schedule.enabled) ...[
                  const SizedBox(height: 20),
                  _buildIntervalPicker(),
                  if (_schedule.interval.hasDayPicker) ...[
                    const SizedBox(height: 16),
                    _buildDayPicker(),
                  ],
                  if (_schedule.interval.hasTimePicker) ...[
                    const SizedBox(height: 16),
                    _buildTimePicker(),
                  ],
                ],
                if (_schedule.lastRun != null) ...[
                  const SizedBox(height: 16),
                  _buildLastRun(),
                ],
                if (_schedule.enabled) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _C.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _saving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Simpan Jadwal', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _buildToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _schedule.enabled ? const Color(0xFFF0FDF4) : _C.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _schedule.enabled ? const Color(0xFFA7F3D0) : _C.borderLight,
        ),
      ),
      child: Row(
        children: [
          Icon(_schedule.enabled ? RemixIcons.checkbox_circle_fill : RemixIcons.checkbox_blank_circle_line,
            size: 20, color: _schedule.enabled ? _C.success : _C.textMuted),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Aktifkan Auto Backup',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _C.textPrimary)),
          ),
          Switch(
            value: _schedule.enabled,
            activeColor: _C.primary,
            onChanged: (v) => setState(() => _schedule = _schedule.copyWith(enabled: v)),
          ),
        ],
      ),
    );
  }

  Widget _buildIntervalPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Interval',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _C.textSecondary)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: BackupInterval.values.map((interval) {
            final selected = _schedule.interval == interval;
            return GestureDetector(
              onTap: () => setState(() {
                _schedule = _schedule.copyWith(
                  interval: interval,
                  day: interval.hasDayPicker ? _schedule.day ?? 1 : null,
                  clearDay: !interval.hasDayPicker,
                );
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? _C.primaryLight : _C.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: selected ? _C.primary.withValues(alpha: 0.3) : _C.borderLight,
                  ),
                ),
                child: Text(interval.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected ? _C.primary : _C.textSecondary,
                  )),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDayPicker() {
    final isMonthly = _schedule.interval == BackupInterval.monthly;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(isMonthly ? 'Tanggal' : 'Hari',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _C.textSecondary)),
        const SizedBox(height: 8),
        isMonthly ? _buildMonthDays() : _buildWeekDays(),
      ],
    );
  }

  Widget _buildWeekDays() {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return Wrap(
      spacing: 6,
      children: List.generate(7, (i) {
        final dayNum = i + 1;
        final selected = _schedule.day == dayNum;
        return GestureDetector(
          onTap: () => setState(() => _schedule = _schedule.copyWith(day: dayNum)),
          child: Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: selected ? _C.primaryLight : _C.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected ? _C.primary.withValues(alpha: 0.3) : _C.borderLight,
              ),
            ),
            child: Center(
              child: Text(days[i],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? _C.primary : _C.textSecondary,
                )),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMonthDays() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: List.generate(31, (i) {
        final dayNum = i + 1;
        final selected = _schedule.day == dayNum;
        return GestureDetector(
          onTap: () => setState(() => _schedule = _schedule.copyWith(day: dayNum)),
          child: Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: selected ? _C.primaryLight : _C.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected ? _C.primary.withValues(alpha: 0.3) : _C.borderLight,
              ),
            ),
            child: Center(
              child: Text('$dayNum',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? _C.primary : _C.textSecondary,
                )),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Waktu',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _C.textSecondary)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _pickTime(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _C.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _C.borderLight),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(RemixIcons.alarm_line, size: 18, color: _C.textSecondary),
                const SizedBox(width: 8),
                Text(_schedule.time,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _C.textPrimary)),
                const SizedBox(width: 4),
                const Text('WIB',
                  style: TextStyle(fontSize: 11, color: _C.textMuted)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickTime(BuildContext context) async {
    final parts = _schedule.time.split(':');
    final initialHour = int.tryParse(parts[0]) ?? 2;
    final initialMinute = int.tryParse(parts[1]) ?? 0;

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
    );
    if (picked != null) {
      setState(() {
        final h = picked.hour.toString().padLeft(2, '0');
        final m = picked.minute.toString().padLeft(2, '0');
        _schedule = _schedule.copyWith(time: '$h:$m');
      });
    }
  }

  Widget _buildLastRun() {
    final formatted = DateFormat('dd MMM yyyy HH:mm').format(_schedule.lastRun!);
    return Row(
      children: [
        const Icon(RemixIcons.check_line, size: 14, color: _C.success),
        const SizedBox(width: 6),
        Text('Terakhir: $formatted',
          style: const TextStyle(fontSize: 11, color: _C.textSecondary)),
      ],
    );
  }
}
