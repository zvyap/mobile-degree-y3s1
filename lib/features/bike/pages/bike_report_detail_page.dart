import 'package:flutter/material.dart';

class BikeReportDetailPage extends StatelessWidget {
  const BikeReportDetailPage({
    super.key,
    required this.reportId,
  });

  final int reportId;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Report Detail: $reportId',
      ),
    );
  }
}