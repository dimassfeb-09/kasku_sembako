import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../../../../di/injection.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_json_codec.dart';
import '../../../../core/services/activity_log_service.dart';
import '../../../subscription/presentation/cubit/subscription_cubit.dart';
import '../../../subscription/presentation/cubit/subscription_state.dart';
import '../../../transaction/presentation/bloc/pos_bloc.dart';
import '../../../transaction/presentation/bloc/pos_event_state.dart';
import '../bloc/backup_bloc.dart';
import '../bloc/backup_event.dart';
import '../bloc/backup_state.dart';

class BackupPage extends StatelessWidget {
  const BackupPage({super.key});

  @override
  Widget build(BuildContext context) {
    // SubscriptionCubit is provided app-wide (see app.dart); only BackupBloc is
    // page-scoped here.
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
      final json = await DatabaseJsonCodec.exportToJson(sl<AppDatabase>());

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal membuat backup: $e')));
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
      final result = await FilePicker.platform.pickFiles(
        type: FileType
            .any, // Beberapa OS membatasi extensi khusus, lebih aman pick any
      );

      if (result == null || result.files.single.path == null) {
        // User membatalkan picker
        return;
      }

      final pickedPath = result.files.single.path!;

      if (!pickedPath.endsWith('.json')) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Format berkas tidak didukung! Pastikan berkas berakhiran .json',
            ),
          ),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Berkas cadangan tidak valid (bukan JSON yang valid)',
            ),
            backgroundColor: Colors.red,
          ),
        );
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
    final json = await DatabaseJsonCodec.exportToJson(sl<AppDatabase>());
    if (!blocContext.mounted) return;
    blocContext.read<BackupBloc>().add(UploadCloudBackupRequested(json));
  }

  /// Shared by local (file_picker) and cloud (downloaded) restore: validates
  /// the JSON shape/schema version, applies it via [DatabaseJsonCodec], then
  /// resets navigation/cart state. Since the JSON path does DELETE+INSERT
  /// through the live Drift connection rather than swapping the underlying
  /// db file, the app no longer needs to fully close and restart afterward.
  Future<void> _applyRestoreJson(
    Map<String, dynamic> json, {
    required String sourceDescription,
  }) async {
    if (!mounted) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Restore'),
        content: const Text(
          'Apakah Anda yakin ingin memulihkan data dari berkas ini?\n\n'
          'Peringatan: Seluruh data transaksi dan stok saat ini akan terhapus dan digantikan oleh data dari berkas backup.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Pulihkan Data'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (!await _confirmAdminAccountChanges(json)) return;

    try {
      await sl<ActivityLogService>().log(
        action: 'RESTORE',
        description:
            'Memulai pemulihan database dari berkas: $sourceDescription.',
      );

      await DatabaseJsonCodec.importFromJson(sl<AppDatabase>(), json);

      if (!mounted) return;
      // Reset app-wide state instead of the old exit()-and-reopen flow:
      // .go('/home') disposes/rebuilds HomePage (re-fires its metrics load),
      // and every other list page already reloads its own data in
      // initState on next visit. PosBloc holds transient cart state with no
      // reload event, so it needs an explicit clear.
      context.read<PosBloc>().add(ClearCartEvent());
      context.go('/home');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Data telah dipulihkan.')));
    } on InvalidBackupFormatException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memulihkan data: $e')));
    }
  }

  /// Warns explicitly, by username, if restoring [json] would introduce an
  /// admin account this device doesn't currently recognize (a brand-new
  /// username, or an existing username being promoted to admin) — a backup
  /// file is otherwise trusted and applied silently, which is exactly what
  /// a hand-crafted malicious backup would rely on to plant a backdoor
  /// admin account. Returns true if it's safe to proceed (no such accounts,
  /// or the admin explicitly acknowledged them).
  Future<bool> _confirmAdminAccountChanges(Map<String, dynamic> json) async {
    final incomingAdmins = DatabaseJsonCodec.adminUsernamesIn(json);
    if (incomingAdmins.isEmpty) return true;

    final currentAdmins =
        (await (sl<AppDatabase>().select(
              sl<AppDatabase>().users,
            )..where((u) => u.role.equals('admin'))).get())
            .map((u) => u.username)
            .toSet();

    final newOrChangedAdmins = incomingAdmins.difference(currentAdmins);
    if (newOrChangedAdmins.isEmpty) return true;

    if (!mounted) return false;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Peringatan: Akun Admin Baru Terdeteksi'),
        content: Text(
          'Berkas ini akan menambahkan atau menaikkan akun berikut menjadi ADMIN, '
          'yang tidak dikenali sebagai admin pada data Anda saat ini:\n\n'
          '${newOrChangedAdmins.map((u) => '• $u').join('\n')}\n\n'
          'Hanya lanjutkan jika Anda mengenali dan mempercayai sumber berkas ini.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Saya Mengerti, Lanjutkan'),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadangan & Pemulihan Data')),
      body: BlocListener<BackupBloc, BackupState>(
        listener: (context, state) async {
          if (state is BackupError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is CloudBackupUploadSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cadangan berhasil diunggah ke cloud.'),
              ),
            );
          } else if (state is CloudBackupDownloadSuccess) {
            await _applyRestoreJson(
              state.payload,
              sourceDescription: 'cadangan cloud',
            );
          }
        },
        child: (_isLoading)
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.cloud_upload_outlined,
                      size: 80,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Cadangkan data transaksi Anda secara berkala agar aman dari kehilangan data akibat perangkat rusak.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 32),
                    Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          child: Icon(Icons.backup, color: Colors.white),
                        ),
                        title: const Text(
                          'Buat Cadangan Data (Backup)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text(
                          'Ekspor dan bagikan data Anda sebagai berkas JSON.',
                        ),
                        onTap: _backupDatabase,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.orangeAccent,
                          child: Icon(
                            Icons.settings_backup_restore,
                            color: Colors.white,
                          ),
                        ),
                        title: const Text(
                          'Pulihkan Data (Restore)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text(
                          'Impor data dari berkas backup berformat .json.',
                        ),
                        onTap: _restoreDatabase,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.workspace_premium,
                          size: 16,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Cadangan Cloud (Pro)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    BlocBuilder<SubscriptionCubit, SubscriptionState>(
                      builder: (context, subState) {
                        final status = subState is SubscriptionStatusLoaded
                            ? subState.status
                            : null;
                        final isPro = status?.isEntitled ?? false;

                        return BlocBuilder<BackupBloc, BackupState>(
                          builder: (context, backupState) {
                            final isBusy =
                                backupState is CloudBackupUploading ||
                                backupState is CloudBackupDownloading;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Card(
                                  child: ListTile(
                                    enabled: isPro && !isBusy,
                                    leading: CircleAvatar(
                                      backgroundColor: isPro
                                          ? Colors.teal
                                          : Colors.grey.shade300,
                                      child: backupState is CloudBackupUploading
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.cloud_upload,
                                              color: Colors.white,
                                            ),
                                    ),
                                    title: const Text(
                                      'Backup ke Cloud',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      isPro
                                          ? 'Unggah data saat ini ke server.'
                                          : 'Upgrade ke Pro untuk mengaktifkan.',
                                    ),
                                    onTap: isPro && !isBusy
                                        ? () => _uploadCloudBackup(context)
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Card(
                                  child: ListTile(
                                    enabled: isPro && !isBusy,
                                    leading: CircleAvatar(
                                      backgroundColor: isPro
                                          ? Colors.indigo
                                          : Colors.grey.shade300,
                                      child:
                                          backupState is CloudBackupDownloading
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.cloud_download,
                                              color: Colors.white,
                                            ),
                                    ),
                                    title: const Text(
                                      'Pulihkan dari Cloud',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      isPro
                                          ? 'Unduh cadangan terbaru dari server.'
                                          : 'Upgrade ke Pro untuk mengaktifkan.',
                                    ),
                                    onTap: isPro && !isBusy
                                        ? () => context.read<BackupBloc>().add(
                                            DownloadCloudBackupRequested(),
                                          )
                                        : null,
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
