import 'package:supreme_octo_eureka/app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.read<AppState>();

    return const Text('Profile Tab');
  }
}
