import 'package:supreme_octo_eureka/app_state.dart';
import 'package:supreme_octo_eureka/authentication/auth_main.dart';
import 'package:supreme_octo_eureka/authentication/verify.dart';
import 'package:supreme_octo_eureka/Customers/customers_root.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    AppState appState = AppState();
    appState.navigatorKey = GlobalKey<NavigatorState>();
    appState.scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
    // Dracula color scheme
    appState.themeData = ThemeData.from(
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFBD93F9),
        onPrimary: Color(0xFF282A36),
        primaryContainer: Color(0xFF44475A),
        onPrimaryContainer: Color(0xFFF8F8F2),
        secondary: Color(0xFF50FA7B),
        onSecondary: Color(0xFF282A36),
        secondaryContainer: Color(0xFF282A36),
        onSecondaryContainer: Color(0xFFF8F8F2),
        tertiary: Color(0xFFFF79C6),
        onTertiary: Color(0xFF282A36),
        tertiaryContainer: Color(0xFF44475A),
        onTertiaryContainer: Color(0xFFF8F8F2),
        error: Color(0xFFFF5555),
        onError: Color(0xFF282A36),
        errorContainer: Color(0xFF44475A),
        onErrorContainer: Color(0xFFF8F8F2),
        surface: Color(0xFF44475A),
        onSurface: Color(0xFFF8F8F2),
        surfaceContainerHighest: Color(0xFF6272A4),
        onSurfaceVariant: Color(0xFFF8F8F2),
        outline: Color(0xFF44475A),
        outlineVariant: Color(0xFF6272A4),
        shadow: Color(0xFF000000),
        scrim: Color(0x99000000),
        inverseSurface: Color(0xFF000000),
        onInverseSurface: Color(0xFFF8F8F2),
        inversePrimary: Color(0xFFBD93F9),
        surfaceTint: Color(0xFF6272A4),
      ),
      useMaterial3: true,
    );

    return ChangeNotifierProvider(
      create: (context) => appState,
      child: MaterialApp(
        routes: <String, WidgetBuilder>{
          '/': (context) => const AuthMain(),
          '/auth/verify_phone': (BuildContext context) => VerifyPhonePage(),
          '/customer/root': (BuildContext context) => const CustomersRoot(),
        },
        navigatorKey: appState.navigatorKey,
        scaffoldMessengerKey: appState.scaffoldMessengerKey,
        title: 'Supreme Octo Eureka',
        theme: appState.themeData,
      ),
    );
  }
}
