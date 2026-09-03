import 'package:flutter/material.dart';

class ReportFormPage extends StatelessWidget {
  const ReportFormPage({
    super.key,
    required this.bikeId,
  });

  final String? bikeId;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Create report for $bikeId',
      ),
    );
  }
}