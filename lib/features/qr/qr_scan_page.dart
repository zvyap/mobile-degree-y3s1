import 'dart:async';

import 'package:bike_renting_app/data/models/database_models.dart';
import 'package:bike_renting_app/features/renting/renting_controller.dart';
import 'package:bike_renting_app/features/renting/renting_flow_page.dart';
import 'package:bike_renting_app/features/renting/renting_models.dart';
import 'package:bike_renting_app/features/user/profile_controller.dart';
import 'package:bike_renting_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

class QrScanPage extends StatefulWidget {
  const QrScanPage({
    super.key,
    required this.controller,
    this.profileController,
    this.onFlowLockChanged,
    this.onRequestExit,
    this.onRequestProfile,
  });

  final RentingController controller;
  final ProfileController? profileController;
  final ValueChanged<bool>? onFlowLockChanged;
  final VoidCallback? onRequestExit;
  final VoidCallback? onRequestProfile;

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  bool _isVerificationDialogShowing = false;
  bool _requestedProfileLoad = false;

  bool _isVerified(UserProfileRecord? profile) {
    if (profile == null) return false;
    final ic = profile.icNumber?.trim();
    if (ic == null || ic.isEmpty) return false;
    return profile.icVerified;
  }

  @override
  void initState() {
    super.initState();
    widget.profileController?.addListener(_checkVerification);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVerification();
    });
  }

  @override
  void dispose() {
    widget.profileController?.removeListener(_checkVerification);
    super.dispose();
  }

  void _checkVerification() {
    if (!mounted || _isVerificationDialogShowing) return;
    final pc = widget.profileController;
    if (pc == null) return;
    if (widget.controller.stage != RentalStage.scan) return;

    final profile = pc.profile;
    if (profile == null) {
      // Profile not loaded yet. Wait for an in-flight load instead of
      // showing a false "not verified" popup to a verified user.
      if (pc.isBusy) return;
      if (_requestedProfileLoad) {
        _showVerificationDialog();
      } else {
        _requestedProfileLoad = true;
        unawaited(pc.loadProfile());
      }
      return;
    }

    if (!_isVerified(profile)) {
      _showVerificationDialog();
    } else {
      // Profile may have just finished loading; refresh the gate so the
      // scan flow is not stuck behind the loading placeholder.
      setState(() {});
    }
  }

  Future<void> _showVerificationDialog() async {
    if (!mounted || _isVerificationDialogShowing) return;
    _isVerificationDialogShowing = true;
    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          final theme = Theme.of(ctx);
          return AlertDialog(
            icon: Icon(
              Icons.verified_user_outlined,
              size: 44,
              color: theme.colorScheme.primary,
            ),
            title: Text(
              ctx.l10n.verificationRequiredTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text(
              ctx.l10n.verificationRequiredBody,
              textAlign: TextAlign.center,
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              FilledButton(
                key: const ValueKey('verification-required-modal-ok'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(120, 48),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: Text(ctx.l10n.okButton),
              ),
            ],
          );
        },
      );
      if (mounted) {
        if (widget.onRequestProfile != null) {
          widget.onRequestProfile!();
        } else {
          widget.onRequestExit?.call();
        }
      }
    } finally {
      _isVerificationDialogShowing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pc = widget.profileController;
    if (pc != null && widget.controller.stage == RentalStage.scan) {
      if (!_isVerified(pc.profile)) {
        final waitForProfile = pc.profile == null && pc.isBusy;
        return Scaffold(
          body: Center(
            child: waitForProfile
                ? const CircularProgressIndicator()
                : const SizedBox.shrink(),
          ),
        );
      }
    }

    return RentingFlowPage(
      controller: widget.controller,
      onFlowLockChanged: widget.onFlowLockChanged,
      onRequestExit: widget.onRequestExit,
    );
  }
}
