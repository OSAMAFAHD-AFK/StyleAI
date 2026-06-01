import 'package:flutter/material.dart';

import 'widgets/profile_setup_view_body.dart';

class ProfileSetupView extends StatelessWidget {
  const ProfileSetupView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ProfileSetupViewBody(),
    );
  }
}
