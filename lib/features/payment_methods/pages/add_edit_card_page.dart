import 'package:bike_renting_app/data/models/database_models.dart';
import 'package:bike_renting_app/features/payment_methods/controllers/payment_methods_controller.dart';
import 'package:bike_renting_app/features/payment_methods/models/card_brand.dart';
import 'package:bike_renting_app/features/payment_methods/validators/card_validator.dart';
import 'package:bike_renting_app/features/payment_methods/widgets/credit_card_preview.dart';
import 'package:bike_renting_app/l10n/l10n.dart';
import 'package:bike_renting_app/shared/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddEditCardPage extends StatefulWidget {
  const AddEditCardPage({
    super.key,
    required this.controller,
    this.editingCard,
  });

  final PaymentMethodsController controller;
  final PaymentMethodRecord? editingCard;

  bool get isEditing => editingCard != null;

  @override
  State<AddEditCardPage> createState() => _AddEditCardPageState();
}

class _AddEditCardPageState extends State<AddEditCardPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _cardNumberController;
  late final TextEditingController _nameController;
  late final TextEditingController _expiryController;
  late final TextEditingController _cvvController;

  late bool _isDefault;
  CardBrand _detectedBrand = CardBrand.unknown;

  @override
  void initState() {
    super.initState();
    final card = widget.editingCard;
    if (card != null) {
      _cardNumberController =
          TextEditingController(text: '•••• •••• •••• ${card.lastFour}');
      _nameController = TextEditingController(text: card.cardholderName ?? '');
      final exp = card.expiryMonth != null && card.expiryYear != null
          ? '${card.expiryMonth.toString().padLeft(2, '0')}/${(card.expiryYear! % 100).toString().padLeft(2, '0')}'
          : '';
      _expiryController = TextEditingController(text: exp);
      _cvvController = TextEditingController();
      _isDefault = card.isDefault;
      _detectedBrand = CardBrand.fromName(card.brand);
    } else {
      _cardNumberController = TextEditingController();
      _nameController = TextEditingController();
      _expiryController = TextEditingController();
      _cvvController = TextEditingController();
      _isDefault = false;
    }

    _cardNumberController.addListener(_handleCardNumberChanged);
    _nameController.addListener(_handleTextChanged);
    _expiryController.addListener(_handleTextChanged);
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _nameController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _handleCardNumberChanged() {
    final brand = CardBrand.detect(_cardNumberController.text);
    if (brand != _detectedBrand) {
      setState(() => _detectedBrand = brand);
    } else {
      setState(() {});
    }
  }

  void _handleTextChanged() {
    setState(() {});
  }

  String? _cardValidationMessage(
    BuildContext context,
    String? value,
    CardValidationError? error,
  ) {
    if (error == null) return null;
    return switch (error) {
      CardValidationError.cardNumberRequired => context.l10n.cvCardNumberRequired,
      CardValidationError.cardDigitsOnly => context.l10n.cvCardDigitsOnly,
      CardValidationError.cardBrandUnsupported => context.l10n.cvCardBrandUnsupported,
      CardValidationError.cardNumberLength => context.l10n.cvCardNumberLength(
        CardValidator.cleanDigits(value ?? '').length,
      ),
      CardValidationError.cardNumberTooLong => context.l10n.cvCardNumberTooLong,
      CardValidationError.cardChecksumFailed => context.l10n.cvCardChecksumFailed,
      CardValidationError.expiryRequired => context.l10n.cvExpiryRequired,
      CardValidationError.expiryFormat => context.l10n.cvExpiryFormat,
      CardValidationError.expiryInvalidMonth => context.l10n.cvExpiryInvalidMonth,
      CardValidationError.expiryInvalidYear => context.l10n.cvExpiryInvalidYear,
      CardValidationError.cardExpired => context.l10n.cvCardExpired,
      CardValidationError.expiryTooFar => context.l10n.cvExpiryTooFar,
      CardValidationError.cvvRequired => context.l10n.cvCvvRequired,
      CardValidationError.cvvLength => context.l10n.cvCvvLength,
      CardValidationError.nameRequired => context.l10n.cvNameRequired,
      CardValidationError.nameTooShort => context.l10n.cvNameTooShort,
      CardValidationError.nameTooLong => context.l10n.cvNameTooLong,
      CardValidationError.nameInvalidChars => context.l10n.cvNameInvalidChars,
      CardValidationError.nameNeedsTwoParts => context.l10n.cvNameNeedsTwoParts,
    };
  }

  String _paymentErrorText(
    BuildContext context,
    PaymentMethodsController controller,
  ) {
    return switch (controller.errorType) {
      PaymentMethodErrorType.sessionExpired => context.l10n.pmSessionExpired,
      PaymentMethodErrorType.cardInUse => context.l10n.pmCardInUse,
      PaymentMethodErrorType.duplicate => context.l10n.pmDuplicateCard,
      PaymentMethodErrorType.validation =>
        context.l10n.pmValidationError(controller.errorDetail ?? ''),
      PaymentMethodErrorType.unknown || null => context.l10n.pmUnknownError,
    };
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final card = widget.editingCard;
    if (card != null) {
      // Edit existing card
      final expiryText = _expiryController.text.trim();
      final parts = expiryText.split('/');
      final month = int.parse(parts[0]);
      final year = 2000 + int.parse(parts[1]);

      final success = await widget.controller.updateCard(
        id: card.id,
        cardholderName: _nameController.text.trim(),
        expiryMonth: month,
        expiryYear: year,
        isDefault: _isDefault,
      );

      if (!mounted) return;

      if (success) {
        AppToast.show(context, message: context.l10n.cardUpdatedSuccess);
        Navigator.of(context).pop();
      } else {
        final error = widget.controller.errorType == null
            ? context.l10n.failedToUpdateCard
            : _paymentErrorText(context, widget.controller);
        AppToast.show(context, message: error, variant: AppToastVariant.error);
      }
    } else {
      // Add new card
      final rawNumber = CardValidator.cleanDigits(_cardNumberController.text);
      final lastFour = rawNumber.substring(rawNumber.length - 4);
      final expiryText = _expiryController.text.trim();
      final parts = expiryText.split('/');
      final month = int.parse(parts[0]);
      final year = 2000 + int.parse(parts[1]);

      final success = await widget.controller.addCard(
        brand: _detectedBrand.displayName,
        lastFour: lastFour,
        expiryMonth: month,
        expiryYear: year,
        cardholderName: _nameController.text.trim(),
        isDefault: _isDefault,
      );

      if (!mounted) return;

      if (success) {
        AppToast.show(context, message: context.l10n.cardAddedSuccess);
        Navigator.of(context).pop();
      } else {
        final error = widget.controller.errorType == null
            ? context.l10n.failedToAddCard
            : _paymentErrorText(context, widget.controller);
        AppToast.show(context, message: error, variant: AppToastVariant.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isEditing = widget.isEditing;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? context.l10n.editCard : context.l10n.addCard),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.controller,
          builder: (context, _) {
            final isSaving = widget.controller.isSaving;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Live Card Preview
                    CreditCardPreview(
                      cardNumber: _cardNumberController.text,
                      cardholderName: _nameController.text,
                      expiryDate: _expiryController.text,
                      brand: _detectedBrand,
                    ),

                    const SizedBox(height: 24),

                    // Card Number field (Read-only on edit)
                    Text(
                      context.l10n.cardNumber,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      key: const ValueKey<String>('card-number-input'),
                      controller: _cardNumberController,
                      enabled: !isEditing && !isSaving,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        CardNumberInputFormatter(),
                      ],
                      decoration: InputDecoration(
                        hintText: context.l10n.cardNumberHint,
                        prefixIcon: Icon(_detectedBrand.icon),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        errorMaxLines: 2,
                      ),
                      validator: isEditing
                          ? null
                          : (v) => _cardValidationMessage(
                                context,
                                v,
                                CardValidator.validateCardNumber(v),
                              ),
                    ),

                    const SizedBox(height: 18),

                    // Cardholder Name field
                    Text(
                      context.l10n.cardholderName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      key: const ValueKey<String>('cardholder-name-input'),
                      controller: _nameController,
                      enabled: !isSaving,
                      textCapitalization: TextCapitalization.words,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        hintText: context.l10n.cardholderNameHint,
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        errorMaxLines: 2,
                      ),
                      validator: (v) => _cardValidationMessage(
                        context,
                        v,
                        CardValidator.validateCardholderName(v),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Expiry and CVV Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Expiry Date Field
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.l10n.expiryDate,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                key: const ValueKey<String>('card-expiry-input'),
                                controller: _expiryController,
                                enabled: !isSaving,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  CardExpiryInputFormatter(),
                                ],
                                decoration: InputDecoration(
                                  hintText: context.l10n.expiryDateHint,
                                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  errorMaxLines: 2,
                                ),
                                validator: (v) => _cardValidationMessage(
                                  context,
                                  v,
                                  CardValidator.validateExpiry(v),
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (!isEditing) ...[
                          const SizedBox(width: 14),

                          // CVV Field
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.l10n.cvvCvc,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  key: const ValueKey<String>('card-cvv-input'),
                                  controller: _cvvController,
                                  enabled: !isSaving,
                                  obscureText: true,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(3),
                                  ],
                                  decoration: InputDecoration(
                                    hintText: context.l10n.cvvHint,
                                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    errorMaxLines: 2,
                                  ),
                                  validator: (v) => _cardValidationMessage(
                                    context,
                                    v,
                                    CardValidator.validateCvv(v),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Default payment method switch
                    Material(
                      color: scheme.surfaceContainerLowest,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: scheme.outlineVariant),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: SwitchListTile(
                        key: const ValueKey<String>('card-default-switch'),
                        value: _isDefault,
                        onChanged: isSaving
                            ? null
                            : (val) => setState(() => _isDefault = val),
                        title: Text(
                          context.l10n.setAsDefaultPaymentMethod,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          context.l10n.automaticallyUseCard,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        key: const ValueKey<String>('card-save-button'),
                        onPressed: isSaving ? null : _submit,
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                isEditing ? context.l10n.updateCard : context.l10n.addCard,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
