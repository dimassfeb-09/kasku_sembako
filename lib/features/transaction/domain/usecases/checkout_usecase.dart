import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/transaction_entity.dart';
import '../entities/cart_item_entity.dart';
import '../repositories/transaction_repository.dart';

const _dailyFreeLimit = 30;

class CheckoutUseCase {
  final TransactionRepository repository;

  CheckoutUseCase(this.repository);

  Future<Either<Failure, TransactionEntity>> call({
    required List<CartItemEntity> cartItems,
    required String paymentMethod,
    required double discount,
    required double tax,
    required bool isPro,
    String? customerId,
    double cashReceived = 0.0,
  }) async {
    if (!isPro) {
      final countResult = await repository.countToday();
      final count = countResult.getOrElse(() => 0);
      if (count >= _dailyFreeLimit) {
        return const Left(
          ValidationFailure(
            'Batas transaksi gratis hari ini sudah tercapai ($_dailyFreeLimit transaksi). Buka Pro untuk transaksi tanpa batas.',
          ),
        );
      }
    }

    if (paymentMethod == 'HUTANG' && customerId == null) {
      return const Left(
        ValidationFailure(
          'Pilih pelanggan terlebih dahulu untuk transaksi hutang.',
        ),
      );
    }

    if (paymentMethod == 'CASH') {
      final subtotal = cartItems.fold(0.0, (sum, item) => sum + item.subtotal);
      final total = subtotal - discount + tax;
      if (cashReceived < total) {
        return const Left(
          ValidationFailure('Jumlah uang diterima kurang dari total belanja.'),
        );
      }
    }

    return await repository.checkout(
      cartItems,
      paymentMethod,
      discount,
      tax,
      customerId,
    );
  }
}
