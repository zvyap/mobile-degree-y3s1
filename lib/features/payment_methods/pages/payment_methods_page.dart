import 'package:bike_renting_app/data/models/database_models.dart';
import 'package:bike_renting_app/data/repositories/payment_method_repository.dart';
import 'package:bike_renting_app/features/payment_methods/controllers/payment_methods_controller.dart';
import 'package:bike_renting_app/features/payment_methods/pages/add_edit_card_page.dart';
import 'package:bike_renting_app/features/payment_methods/widgets/card_method_tile.dart';
import 'package:bike_renting_app/features/payment_methods/widgets/paypal_method_tile.dart';
import 'package:bike_renting_app/l10n/l10n.dart';
import 'package:bike_renting_app/shared/app_toast.dart';
import 'package:flutter/material.dart';

class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({
    super.key,
    required this.repository,
  });

  final PaymentMethodRepository repository;

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  late final PaymentMethodsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PaymentMethodsController(widget.repository);
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

  void _openAddCard() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => AddEditCardPage(controller: _controller),
      ),
    );
  }

  void _openEditCard(PaymentMethodRecord card) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => AddEditCardPage(
          controller: _controller,
          editingCard: card,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(PaymentMethodRecord card) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.removeCard),
        content: Text(
          context.l10n.removeCardConfirmation(card.brand, card.lastFour),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.remove),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await _controller.deleteCard(card.id);
      if (!mounted) return;
      if (success) {
        AppToast.show(context, message: context.l10n.cardRemovedSuccess);
      } else {
        AppToast.show(
          context,
          message: _paymentErrorText(context, _controller),
          variant: AppToastVariant.error,
        );
      }
    }
  }

  Future<void> _setDefault(PaymentMethodRecord card) async {
    final success = await _controller.setDefault(card.id);
    if (!mounted) return;
    if (success) {
      AppToast.show(context, message: context.l10n.cardSetAsDefault(card.brand));
    } else {
      AppToast.show(
        context,
        message: _paymentErrorText(context, _controller),
        variant: AppToastVariant.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            final isLoading = _controller.isLoading;
            final cards = _controller.cards;
            final errorType = _controller.errorType;

            return RefreshIndicator(
              onRefresh: _controller.load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
                children: [
                  Text(
                    context.l10n.paymentMethods,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.l10n.managePaymentMethodsSubtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.68),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (errorType != null) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: scheme.errorContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline_rounded,
                              color: scheme.onErrorContainer),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _paymentErrorText(context, _controller),
                              style: TextStyle(color: scheme.onErrorContainer),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            color: scheme.onErrorContainer,
                            onPressed: _controller.clearError,
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Online Payment Section (PayPal)
                  Text(
                    context.l10n.onlineCheckout,
                    style: theme.textTheme.labelSmall?.copyWith(
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const PayPalMethodTile(),

                  const SizedBox(height: 16),

                  // Credit/Debit Cards Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n.savedCards,
                        style: theme.textTheme.labelSmall?.copyWith(
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      if (cards.isNotEmpty)
                        Text(
                          context.l10n.savedCardsCount(cards.length),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (isLoading && cards.isEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ] else if (cards.isEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 36, horizontal: 20),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: scheme.outlineVariant),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.credit_card_outlined,
                            size: 48,
                            color: scheme.onSurface.withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            context.l10n.noCardsSaved,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            context.l10n.noCardsSavedDescription,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurface.withValues(alpha: 0.65),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    for (final card in cards)
                      CardMethodTile(
                        key: ValueKey<String>('card-tile-${card.id}'),
                        card: card,
                        onEdit: () => _openEditCard(card),
                        onDelete: () => _confirmDelete(card),
                        onSetDefault: () => _setDefault(card),
                      ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey<String>('add-card-fab'),
        onPressed: _openAddCard,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          context.l10n.addCard,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
