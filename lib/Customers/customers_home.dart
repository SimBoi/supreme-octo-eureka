import 'package:supreme_octo_eureka/app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.read<AppState>();

    return const Text('Home Tab');
  }
}
