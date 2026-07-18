import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:remixicon/remixicon.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/repositories/cloud_backup_repository.dart';

typedef _C = AppColors;

/// Lets the user pick which cloud backup to restore, instead of silently
/// restoring "latest" - with multiple devices uploading to the same
/// account, "latest" isn't necessarily the one the user wants, and
/// restoring the wrong one overwrites local data with no way back.
Future<CloudBackupSummary?> showCloudBackupPicker(
  BuildContext context,
  List<CloudBackupSummary> backups,
) {
  return showModalBottomSheet<CloudBackupSummary>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _CloudBackupPickerSheet(backups: backups),
  );
}

class _CloudBackupPickerSheet extends StatelessWidget {
  final List<CloudBackupSummary> backups;
  const _CloudBackupPickerSheet({required this.backups});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: BoxDecoration(
          color: _C.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Pilih Cadangan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _C.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(RemixIcons.close_line),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            if (backups.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Belum ada cadangan cloud tersimpan.',
                  style: TextStyle(color: _C.textSecondary),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                  itemCount: backups.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) {
                    final b = backups[i];
                    return _BackupTile(
                      backup: b,
                      onTap: () => Navigator.pop(context, b),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BackupTile extends StatelessWidget {
  final CloudBackupSummary backup;
  final VoidCallback onTap;
  const _BackupTile({required this.backup, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final formatted = DateFormat(
      'dd MMM yyyy HH:mm',
    ).format(backup.createdAt.toLocal());
    final deviceLabel = _deviceLabel(backup.deviceId);
    return Material(
      color: _C.background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDFA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  RemixIcons.archive_line,
                  color: Color(0xFF0D9488),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatted,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _C.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$deviceLabel · ${_formatSize(backup.sizeBytes)}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: _C.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                RemixIcons.arrow_right_s_line,
                size: 18,
                color: _C.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _deviceLabel(String? deviceId) {
  if (deviceId == null || deviceId.isEmpty) return 'Perangkat tidak dikenal';
  final short = deviceId.length <= 8 ? deviceId : deviceId.substring(0, 8);
  return 'Perangkat $short';
}

String _formatSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
