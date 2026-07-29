import 'package:bike_renting_app/shared/ui_components.dart';
import 'package:flutter/material.dart';

class BikeManagementPage extends StatelessWidget {
  const BikeManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderPage(
      key: ValueKey<String>('bike-management-page'),
      title: 'Bike management',
      subtitle: 'Fleet health, battery status, and maintenance queue.',
      accent: Color(0xFF0E9F6E),
    );
  }
}
