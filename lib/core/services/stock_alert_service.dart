import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../database/app_database.dart';
import '../../features/product/domain/entities/product_entity.dart';

class StockAlertService {
  final AppDatabase _db;
  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  StockAlertService(this._db) : _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    if (_initialized) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
    );
    _initialized = true;
  }

  Future<List<ProductEntity>> getLowStockProducts() async {
    final rows = await _db.select(_db.products).get();
    return rows
        .where((p) => p.trackStock && p.stock <= (p.minStock ?? 5))
        .map(
          (p) => ProductEntity(
            id: p.id,
            barcode: p.barcode,
            name: p.name,
            categoryId: p.categoryId,
            purchasePrice: p.purchasePrice,
            sellingPrice: p.sellingPrice,
            stock: p.stock,
            unit: p.unit,
            imagePath: p.imagePath,
            isActive: p.isActive,
            trackStock: p.trackStock,
            minStock: p.minStock,
          ),
        )
        .toList();
  }

  Future<void> checkAndNotify() async {
    final lowStock = await getLowStockProducts();
    if (lowStock.isEmpty) return;

    await init();

    if (lowStock.length == 1) {
      final p = lowStock.first;
      await _plugin.show(
        id: 0,
        title: 'Stok Menipis',
        body: '${p.name} — Sisa ${p.stock} ${p.unit} (min. ${p.minStock ?? 5})',
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'stock_alert',
            'Peringatan Stok',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    } else {
      await _plugin.show(
        id: 0,
        title: 'Stok Menipis',
        body: '${lowStock.length} produk hampir habis',
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'stock_alert',
            'Peringatan Stok',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    }
  }
}
