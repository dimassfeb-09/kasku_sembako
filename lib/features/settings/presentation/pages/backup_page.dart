import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../../../../di/injection.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/services/activity_log_service.dart';

class BackupPage extends StatefulWidget {
  const BackupPage({super.key});

  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  bool _isLoading = false;

  Future<void> _backupDatabase() async {
    setState(() => _isLoading = true);
    try {
      final dbFolder = await getApplicationDocumentsDirectory();
      final sourceFile = File(p.join(dbFolder.path, 'kasirku_db.sqlite'));

      if (!await sourceFile.exists()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Database tidak ditemukan!')),
        );
        return;
      }

      // Salin ke berkas sementara dengan nama berstempel waktu
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final backupFileName = 'kasirku_backup_$timestamp.sqlite';
      final backupFile = await sourceFile.copy(
        p.join(tempDir.path, backupFileName),
      );

      // Bagikan berkas backup
      await Share.shareXFiles([
        XFile(backupFile.path),
      ], text: 'Backup Database Kasirku Sembako $timestamp');

      // Log aktivitas backup sukses
      await sl<ActivityLogService>().log(
        action: 'BACKUP',
        description: 'Berhasil membuat cadangan database: $backupFileName.',
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal membuat backup: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
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
      final pickedFile = File(pickedPath);

      // Validasi sederhana nama berkas atau ekstensi
      if (!pickedPath.endsWith('.sqlite')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Format berkas tidak didukung! Pastikan berkas berakhiran .sqlite',
            ),
          ),
        );
        return;
      }

      // Validasi header SQLite (Magic Bytes: SQLite format 3)
      try {
        final bytes = await pickedFile.openRead(0, 16).first;
        final header = String.fromCharCodes(bytes);
        if (!header.startsWith('SQLite format 3')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Berkas cadangan tidak valid (Bukan database SQLite)'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memverifikasi berkas cadangan: $e'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Konfirmasi Restore
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

      final dbFolder = await getApplicationDocumentsDirectory();
      final targetFile = File(p.join(dbFolder.path, 'kasirku_db.sqlite'));

      // Log aktivitas restore
      await sl<ActivityLogService>().log(
        action: 'RESTORE',
        description:
            'Memulai pemulihan database dari berkas: ${p.basename(pickedPath)}.',
      );

      // Tutup koneksi aktif database agar melepaskan kunci file
      await sl<AppDatabase>().close();

      // Copy file cadangan menimpa database utama
      await pickedFile.copy(targetFile.path);

      // Tampilkan dialog sukses dan saran restart
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Restore Sukses!'),
          content: const Text(
            'Pemulihan database berhasil diselesaikan.\n\n'
            'Silakan tutup aplikasi ini secara penuh dan buka kembali agar perubahan data termuat dengan benar.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                exit(0); // Tutup aplikasi secara penuh
              },
              child: const Text('Keluar Aplikasi'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Re-register AppDatabase agar koneksi bisa dibuka kembali jika terlanjur ditutup
      try {
        await sl.unregister<AppDatabase>();
        sl.registerLazySingleton<AppDatabase>(() => AppDatabase());
      } catch (_) {}
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memulihkan data: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadangan & Pemulihan Data')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
                        'Ekspor dan bagikan file database Anda.',
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
                        'Impor data dari file backup berformat .sqlite.',
                      ),
                      onTap: _restoreDatabase,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
