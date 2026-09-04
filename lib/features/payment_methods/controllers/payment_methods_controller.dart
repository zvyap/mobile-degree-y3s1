import 'package:bike_renting_app/data/database/database_exception.dart';
import 'package:bike_renting_app/data/models/database_models.dart';
import 'package:bike_renting_app/data/repositories/payment_method_repository.dart';
import 'package:flutter/foundation.dart';

class PaymentMethodsController extends ChangeNotifier {
  PaymentMethodsController(this._repository);

  final PaymentMethodRepository _repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<PaymentMethodRecord> _cards = const [];
  List<PaymentMethodRecord> get cards => _cards;

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final list = await _repository.listOwn();
      // Filter card provider methods
      _cards = list.where((p) => p.provider == 'card').toList();
    } catch (e) {
      _errorMessage = _parseError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addCard({
    required String brand,
    required String lastFour,
    required int expiryMonth,
    required int expiryYear,
    String? cardholderName,
    bool isDefault = false,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.createCard(
        brand: brand,
        lastFour: lastFour,
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
        cardholderName: cardholderName,
        isDefault: isDefault,
      );
      await load();
      return true;
    } catch (e) {
      _errorMessage = _parseError(e);
      notifyListeners();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateCard({
    required int id,
    String? cardholderName,
    int? expiryMonth,
    int? expiryYear,
    bool? isDefault,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.updateCard(
        id: id,
        cardholderName: cardholderName,
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
        isDefault: isDefault,
      );
      await load();
      return true;
    } catch (e) {
      _errorMessage = _parseError(e);
      notifyListeners();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> setDefault(int id) async {
    _errorMessage = null;
    try {
      await _repository.setDefault(id);
      await load();
      return true;
    } catch (e) {
      _errorMessage = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCard(int id) async {
    _errorMessage = null;
    try {
      await _repository.deleteCard(id);
      await load();
      return true;
    } on DatabaseException catch (e) {
      if (e.code == DatabaseErrorCode.paymentMethodInUse) {
        _errorMessage =
            'Cannot delete card: it is currently attached to an active or pending rental.';
      } else {
        _errorMessage = _parseError(e);
      }
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  String _parseError(Object error) {
    if (error is DatabaseException) {
      return switch (error.code) {
        DatabaseErrorCode.notAuthenticated => 'User session expired. Please log in again.',
        DatabaseErrorCode.paymentMethodInUse =>
          'Cannot delete card: it is currently attached to an active rental.',
        DatabaseErrorCode.validation => 'Validation error: ${error.message}',
        DatabaseErrorCode.conflict => 'This card is already registered in your account.',
        _ => error.message.isNotEmpty ? error.message : 'An unexpected database error occurred.',
      };
    }
    return error.toString();
  }
}
