import 'package:flutter/material.dart';

Duration motionDuration(BuildContext context, int milliseconds) {
  return reduceMotion(context)
      ? Duration.zero
      : Duration(milliseconds: milliseconds);
}

bool reduceMotion(BuildContext context) {
  final mediaQuery = MediaQuery.maybeOf(context);

  if (mediaQuery == null) {
    return false;
  }

  return mediaQuery.disableAnimations || mediaQuery.accessibleNavigation;
}
