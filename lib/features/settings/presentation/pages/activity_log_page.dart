import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/database/app_database.dart';
import '../../../../di/injection.dart';
import '../../../../core/theme/app_colors.dart';

class ActivityLogPage extends StatefulWidget {
  const ActivityLogPage({super.key});

  @override
  State<ActivityLogPage> createState() => _ActivityLogPageState();
}

class _ActivityLogPageState extends State<ActivityLogPage> {
  final _db = sl<AppDatabase>();
  List<ActivityLog> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);
    try {
      final list = await _db.select(_db.activityLogs).get();
      setState(() {
        _logs = list..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat log aktivitas: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  IconData _getIconForAction(String action) {
    switch (action.toUpperCase()) {
      case 'VOID_TRANSACTION':
        return Icons.cancel_outlined;
      case 'LOGIN':
        return Icons.login_outlined;
      case 'LOGOUT':
        return Icons.logout_outlined;
      case 'BACKUP':
        return Icons.backup_outlined;
      case 'RESTORE':
        return Icons.settings_backup_restore_outlined;
      case 'ADJUST_STOCK':
        return Icons.warehouse_outlined;
      default:
        return Icons.info_outline;
    }
  }

  Color _getColorForAction(String action) {
    switch (action.toUpperCase()) {
      case 'VOID_TRANSACTION':
        return Colors.red;
      case 'LOGIN':
        return Colors.green;
      case 'LOGOUT':
        return Colors.orange;
      case 'BACKUP':
      case 'RESTORE':
        return Colors.blue;
      case 'ADJUST_STOCK':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Aktivitas Sistem'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadLogs),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
          ? const Center(child: Text('Belum ada log aktivitas yang tercatat.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _logs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final log = _logs[index];
                final color = _getColorForAction(log.action);
                final icon = _getIconForAction(log.action);

                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: color.withOpacity(0.1),
                      child: Icon(icon, color: color),
                    ),
                    title: Text(
                      log.description,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              size: 12,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'User ID: ${log.userId}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 12,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                DateFormat(
                                  'dd/MM/yyyy HH:mm:ss',
                                ).format(log.createdAt),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: color.withOpacity(0.3)),
                      ),
                      child: Text(
                        log.action,
                        style: TextStyle(
                          fontSize: 10,
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
