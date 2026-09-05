import 'package:bike_renting_app/data/database/database_exception.dart';
import 'package:bike_renting_app/data/models/database_models.dart';
import 'package:bike_renting_app/data/repositories/payment_method_repository.dart';
import 'package:flutter/foundation.dart';

/// Typed error categories surfaced by [PaymentMethodsController].
enum PaymentMethodErrorType { sessionExpired, cardInUse, duplicate, validation, unknown }

class PaymentMethodsController extends ChangeNotifier {
  PaymentMethodsController(this._repository);

  final PaymentMethodRepository _repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  PaymentMethodErrorType? _errorType;
  PaymentMethodErrorType? get errorType => _errorType;

  String? _errorDetail;
  String? get errorDetail => _errorDetail;

  List<PaymentMethodRecord> _cards = const [];
  List<PaymentMethodRecord> get cards => _cards;

  void clearError() {
    if (_errorType != null || _errorDetail != null) {
      _errorType = null;
      _errorDetail = null;
      notifyListeners();
    }
  }

  Future<void> load() async {
    _isLoading = true;
    _clearErrorFields();
    notifyListeners();

    try {
      final list = await _repository.listOwn();
      // Filter card provider methods
      _cards = list.where((p) => p.provider == 'card').toList();
    } catch (e) {
      _applyError(e);
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
    _clearErrorFields();
    notifyListeners();

    if (cardholderName != null && cardholderName.trim().isNotEmpty) {
      final name = cardholderName.trim().toLowerCase();
      if (_cards.any((c) => c.cardholderName?.trim().toLowerCase() == name)) {
        _errorType = PaymentMethodErrorType.duplicate;
        _errorDetail = 'Card name already in use';
        _isSaving = false;
        notifyListeners();
        return false;
      }
    }

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
      _applyError(e);
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
    _clearErrorFields();
    notifyListeners();

    if (cardholderName != null && cardholderName.trim().isNotEmpty) {
      final name = cardholderName.trim().toLowerCase();
      if (_cards.any((c) => c.id != id && c.cardholderName?.trim().toLowerCase() == name)) {
        _errorType = PaymentMethodErrorType.duplicate;
        _errorDetail = 'Card name already in use';
        _isSaving = false;
        notifyListeners();
        return false;
      }
    }

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
      _applyError(e);
      notifyListeners();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> setDefault(int id) async {
    _clearErrorFields();
    try {
      await _repository.setDefault(id);
      await load();
      return true;
    } catch (e) {
      _applyError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCard(int id) async {
    _clearErrorFields();
    try {
      await _repository.deleteCard(id);
      await load();
      return true;
    } catch (e) {
      _applyError(e);
      notifyListeners();
      return false;
    }
  }

  void _clearErrorFields() {
    _errorType = null;
    _errorDetail = null;
  }

  void _applyError(Object error) {
    if (error is DatabaseException) {
      switch (error.code) {
        case DatabaseErrorCode.notAuthenticated:
          _errorType = PaymentMethodErrorType.sessionExpired;
          break;
        case DatabaseErrorCode.paymentMethodInUse:
          _errorType = PaymentMethodErrorType.cardInUse;
          break;
        case DatabaseErrorCode.conflict:
          _errorType = PaymentMethodErrorType.duplicate;
          break;
        case DatabaseErrorCode.validation:
          _errorType = PaymentMethodErrorType.validation;
          _errorDetail = error.message;
          break;
        default:
          _errorType = PaymentMethodErrorType.unknown;
      }
    } else {
      _errorType = PaymentMethodErrorType.unknown;
    }
  }
}
