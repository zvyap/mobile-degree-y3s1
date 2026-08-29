import 'package:bike_renting_app/features/renting/renting_controller.dart';
import 'package:bike_renting_app/features/renting/renting_flow_page.dart';
import 'package:flutter/material.dart';

class QrScanPage extends StatelessWidget {
  const QrScanPage({
    super.key,
    required this.controller,
    this.onFlowLockChanged,
    this.onRequestExit,
  });

  final RentingController controller;
  final ValueChanged<bool>? onFlowLockChanged;
  final VoidCallback? onRequestExit;

  @override
  Widget build(BuildContext context) {
    return RentingFlowPage(
      controller: controller,
      onFlowLockChanged: onFlowLockChanged,
      onRequestExit: onRequestExit,
    );
  }
}
