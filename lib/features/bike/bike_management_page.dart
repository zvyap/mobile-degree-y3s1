import 'package:bike_renting_app/l10n/l10n.dart';
import 'package:bike_renting_app/shared/ui_components.dart';
import 'package:flutter/material.dart';

class BikeManagementPage extends StatelessWidget {
  const BikeManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FeaturePlaceholderPage(
      key: const ValueKey<String>('bike-management-page'),
      title: context.l10n.bikeManagement,
      subtitle: context.l10n.fleetDescription,
      accent: const Color(0xFF0E9F6E),
    );
  }
}
