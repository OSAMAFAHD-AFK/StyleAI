import 'package:flutter/material.dart';

/// Official Google "G" logo asset for the login button.
class GoogleLogoIcon extends StatelessWidget {
  const GoogleLogoIcon({super.key, this.size = 22});

  static const _asset = 'assets/icons/google_logo.png';

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}
