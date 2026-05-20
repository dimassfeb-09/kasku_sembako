import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/transaction_entity.dart';
import '../entities/cart_item_entity.dart';
import '../repositories/transaction_repository.dart';

class CheckoutUseCase {
  final TransactionRepository repository;

  CheckoutUseCase(this.repository);

  Future<Either<Failure, TransactionEntity>> call({
    required List<CartItemEntity> cartItems,
    required String paymentMethod,
    required double discount,
    required double tax,
    String? customerId,
    double cashReceived = 0.0,
  }) async {
    // Validasi HUTANG wajib customer
    if (paymentMethod == 'HUTANG' && customerId == null) {
      return const Left(ValidationFailure('Pilih pelanggan terlebih dahulu untuk transaksi hutang.'));
    }

    // Validasi CASH cukup
    if (paymentMethod == 'CASH') {
      final subtotal = cartItems.fold(0.0, (sum, item) => sum + item.subtotal);
      final total = subtotal - discount + tax;
      if (cashReceived < total) {
        return const Left(ValidationFailure('Jumlah uang diterima kurang dari total belanja.'));
      }
    }

    return await repository.checkout(cartItems, paymentMethod, discount, tax, customerId);
  }
}
