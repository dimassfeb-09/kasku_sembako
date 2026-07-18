import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:remixicon/remixicon.dart';
import '../../../../di/injection.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_json_codec.dart';
import '../../../../core/services/activity_log_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../subscription/presentation/cubit/subscription_cubit.dart';
import '../../../subscription/presentation/cubit/subscription_state.dart';
import '../../../transaction/presentation/bloc/pos_bloc.dart';
import '../../../transaction/presentation/bloc/pos_event_state.dart';
import '../bloc/backup_bloc.dart';
import '../bloc/backup_event.dart';
import '../bloc/backup_state.dart';
import '../widgets/backup_schedule_sheet.dart';
import '../widgets/cloud_backup_picker_sheet.dart';

typedef _C = AppColors;

class BackupPage extends StatelessWidget {
  const BackupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BackupBloc>(
      create: (_) => sl<BackupBloc>(),
      child: const _BackupPageBody(),
    );
  }
}

class _BackupPageBody extends StatefulWidget {
  const _BackupPageBody();

  @override
  State<_BackupPageBody> createState() => _BackupPageBodyState();
}

class _BackupPageBodyState extends State<_BackupPageBody> {
  bool _isLoading = false;

  Future<void> _backupDatabase() async {
    setState(() => _isLoading = true);
    try {
      final json = await exportDbToJson(sl<AppDatabase>());
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final backupFileName = 'kasirku_backup_$timestamp.json';
      final backupFile = await _writeJsonFile(
        p.join(tempDir.path, backupFileName),
        json,
      );
      await Share.shareXFiles([
        XFile(backupFile.path),
      ], text: 'Backup Database Kasirku Sembako $timestamp');
      await sl<ActivityLogService>().log(
        action: 'BACKUP',
        description: 'Berhasil membuat cadangan database: $backupFileName.',
      );
    } catch (e) {
      if (!mounted) return;
      _showError('Gagal membuat backup: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<File> _writeJsonFile(String path, Map<String, dynamic> json) async {
    final file = File(path);
    return file.writeAsString(jsonEncode(json));
  }

  Future<void> _restoreDatabase() async {
    setState(() => _isLoading = true);
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.any);
      if (result == null || result.files.single.path == null) return;
      final pickedPath = result.files.single.path!;

      if (!pickedPath.endsWith('.json')) {
        if (!mounted) return;
        _showError('Format berkas tidak didukung. Harus .json');
        return;
      }

      Map<String, dynamic> decoded;
      try {
        final raw = await File(pickedPath).readAsString();
        final parsed = jsonDecode(raw);
        if (parsed is! Map<String, dynamic>) {
          throw const FormatException('root is not an object');
        }
        decoded = parsed;
      } catch (_) {
        if (!mounted) return;
        _showError('Berkas cadangan tidak valid');
        return;
      }

      await _applyRestoreJson(
        decoded,
        sourceDescription: p.basename(pickedPath),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadCloudBackup(BuildContext blocContext) async {
    final json = await exportDbToJson(sl<AppDatabase>());
    if (!blocContext.mounted) return;
    blocContext.read<BackupBloc>().add(UploadCloudBackupRequested(json));
  }

  Future<void> _browseCloudBackups(BuildContext blocContext) async {
    blocContext.read<BackupBloc>().add(ListCloudBackupsRequested());
  }

  /// True if local data looks newer than the backup being restored, so the
  /// confirm dialog can warn before it gets silently overwritten - e.g. a
  /// backup from another device being restored onto a device with newer
  /// local transactions.
  Future<bool> _localDataLooksNewerThan(Map<String, dynamic> json) async {
    final exportedAtRaw = json['exportedAt'];
    final exportedAt = exportedAtRaw is String
        ? DateTime.tryParse(exportedAtRaw)
        : null;
    if (exportedAt == null) return false;

    final db = sl<AppDatabase>();
    final latestLog =
        await (db.select(db.activityLogs)
              ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
              ..limit(1))
            .getSingleOrNull();
    if (latestLog == null) return false;

    return latestLog.createdAt.isAfter(exportedAt);
  }

  Future<void> _applyRestoreJson(
    Map<String, dynamic> json, {
    required String sourceDescription,
  }) async {
    if (!mounted) return;
    final localIsNewer = await _localDataLooksNewerThan(json);
    if (!mounted) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Restore'),
        content: Text(
          localIsNewer
              ? 'Data di perangkat ini tampak lebih baru dari cadangan yang dipilih. '
                    'Seluruh data transaksi dan stok saat ini akan terhapus dan digantikan '
                    'oleh data dari cadangan ini. Tetap lanjutkan?'
              : 'Seluruh data transaksi dan stok saat ini akan terhapus dan digantikan oleh data dari berkas backup.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: _C.error),
            child: const Text('Pulihkan Data'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await sl<ActivityLogService>().log(
        action: 'RESTORE',
        description:
            'Memulai pemulihan database dari berkas: $sourceDescription.',
      );
      await importDbFromJson(sl<AppDatabase>(), json);
      if (!mounted) return;
      context.read<PosBloc>().add(ClearCartEvent());
      context.go('/home');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Data telah dipulihkan.')));
    } on InvalidBackupFormatException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    } catch (e) {
      if (!mounted) return;
      _showError('Gagal memulihkan data: $e');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: _C.error));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.background,
      appBar: AppBar(
        title: const Text('Cadangan & Pemulihan Data'),
        backgroundColor: _C.white,
        surfaceTintColor: _C.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
      ),
      body: BlocListener<BackupBloc, BackupState>(
        listener: (context, state) async {
          if (state is BackupError) {
            _showError(state.message);
          } else if (state is CloudBackupUploadSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cadangan berhasil diunggah ke cloud.'),
                backgroundColor: _C.success,
              ),
            );
          } else if (state is CloudBackupUploadSkipped) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Tidak ada perubahan sejak cadangan terakhir — tidak perlu diunggah ulang.',
                ),
              ),
            );
          } else if (state is BackupsListLoaded) {
            final blocContext = context;
            final selected = await showCloudBackupPicker(
              context,
              state.backups,
            );
            if (selected == null || !blocContext.mounted) return;
            blocContext.read<BackupBloc>().add(
              DownloadCloudBackupByIdRequested(selected.id),
            );
          } else if (state is CloudBackupDownloadSuccess) {
            await _applyRestoreJson(
              state.payload,
              sourceDescription: 'cadangan cloud',
            );
          }
        },
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HeroSection(),
                  const SizedBox(height: 24),
                  _SectionLabel(
                    icon: RemixIcons.hard_drive_2_line,
                    label: 'Lokal',
                  ),
                  const SizedBox(height: 12),
                  _ActionCard(
                    icon: RemixIcons.upload_cloud_2_line,
                    iconBg: const Color(0xFFE0F2FE),
                    iconColor: const Color(0xFF2563EB),
                    title: 'Buat Cadangan',
                    subtitle: 'Ekspor data toko sebagai berkas .json',
                    onTap: _backupDatabase,
                  ),
                  const SizedBox(height: 12),
                  _ActionCard(
                    icon: RemixIcons.download_cloud_2_line,
                    iconBg: const Color(0xFFFEF3C7),
                    iconColor: const Color(0xFFD97706),
                    title: 'Pulihkan Data',
                    subtitle: 'Impor dari berkas backup .json',
                    onTap: _restoreDatabase,
                  ),
                  const SizedBox(height: 32),
                  BlocBuilder<SubscriptionCubit, SubscriptionState>(
                    builder: (context, subState) {
                      final status = subState is SubscriptionStatusLoaded
                          ? subState.status
                          : null;
                      final isPro = status?.isEntitled ?? false;
                      return BlocBuilder<BackupBloc, BackupState>(
                        builder: (context, backupState) {
                          final isUploading =
                              backupState is CloudBackupUploading;
                          final isBrowsing = backupState is BackupsListLoading;
                          final isDownloading =
                              backupState is CloudBackupDownloading ||
                              isBrowsing;
                          final isBusy = isUploading || isDownloading;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _SectionLabel(
                                icon: RemixIcons.cloud_line,
                                label: 'Cloud',
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFF59E0B),
                                        Color(0xFFD97706),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'PRO',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              _ActionCard(
                                icon: RemixIcons.upload_cloud_2_line,
                                iconBg: const Color(0xFFF0FDFA),
                                iconColor: const Color(0xFF0D9488),
                                title: 'Backup ke Cloud',
                                subtitle: isPro
                                    ? 'Unggah data terbaru'
                                    : 'Upgrade ke Pro untuk mengaktifkan',
                                enabled: isPro,
                                isLoading: isUploading,
                                onTap: () => _uploadCloudBackup(context),
                              ),
                              const SizedBox(height: 12),
                              _ActionCard(
                                icon: RemixIcons.download_cloud_2_line,
                                iconBg: const Color(0xFFF0FDFA),
                                iconColor: const Color(0xFF0D9488),
                                title: 'Pulihkan dari Cloud',
                                subtitle: isPro
                                    ? 'Pilih & pulihkan cadangan'
                                    : 'Upgrade ke Pro untuk mengaktifkan',
                                enabled: isPro,
                                isLoading: isDownloading,
                                onTap: () => _browseCloudBackups(context),
                              ),
                              if (isPro) ...[
                                const SizedBox(height: 24),
                                const BackupScheduleSheet(),
                              ],
                              if (!isPro && !isBusy) ...[
                                const SizedBox(height: 16),
                                AppButton(
                                  text: 'Upgrade ke Pro',
                                  onPressed: () =>
                                      context.push('/subscription/upgrade'),
                                ),
                              ],
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            if (_isLoading)
              Container(
                color: _C.white.withValues(alpha: 0.7),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              RemixIcons.shield_check_line,
              color: Color(0xFF16A34A),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Data tetap aman',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _C.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Cadangkan secara berkala agar aman dari kehilangan data.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: _C.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  const _SectionLabel({required this.icon, required this.label, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: _C.textMuted),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _C.textMuted,
            letterSpacing: 0.5,
          ),
        ),
        if (trailing != null) ...[const Spacer(), trailing!],
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool enabled;
  final bool isLoading;

  const _ActionCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.enabled = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveEnabled = enabled && !isLoading;
    return Container(
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.borderLight),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: effectiveEnabled ? onTap : null,
          child: Opacity(
            opacity: effectiveEnabled ? 1 : 0.45,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: effectiveEnabled
                          ? iconBg
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: isLoading
                        ? const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            ),
                          )
                        : Icon(
                            icon,
                            size: 22,
                            color: effectiveEnabled ? iconColor : _C.textMuted,
                          ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: effectiveEnabled
                                ? _C.textPrimary
                                : _C.textMuted,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: _C.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (effectiveEnabled)
                    const Icon(
                      RemixIcons.arrow_right_s_line,
                      size: 20,
                      color: _C.textMuted,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
