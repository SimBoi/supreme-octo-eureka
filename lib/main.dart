import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:supreme_octo_eureka/Teachers/teachers_root.dart';
import 'package:supreme_octo_eureka/app_state.dart';
import 'package:supreme_octo_eureka/authentication/auth_main.dart';
import 'package:supreme_octo_eureka/authentication/verify.dart';
import 'package:supreme_octo_eureka/Customers/customers_root.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supreme_octo_eureka/theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    AppState appState = AppState();

    // Check if OneSignal is available on the current platform
    if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android) {
      // Initialize OneSignal
      OneSignal.initialize("e7d7a2bd-815c-4bd9-92dd-9b1f772b20c9");
      // Prompt for push notifications
      OneSignal.Notifications.requestPermission(true);
      OneSignal.User.addObserver(
        (stateChanges) => appState.oneSignalID = stateChanges.current.onesignalId ?? '',
      );
    }

    // Set up global keys for navigation and messaging
    appState.navigatorKey = GlobalKey<NavigatorState>();
    appState.scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

    // Determine theme based on platform brightness
    final brightness = View.of(context).platformDispatcher.platformBrightness;
    TextTheme textTheme = Theme.of(context).textTheme;
    MaterialTheme theme = MaterialTheme(textTheme);
    appState.themeData = brightness == Brightness.light ? theme.light() : theme.dark();

    return ChangeNotifierProvider(
      create: (context) => appState,
      child: MaterialApp(
        routes: <String, WidgetBuilder>{
          '/': (context) => const AuthMain(),
          '/auth/verify_phone': (BuildContext context) => VerifyPhonePage(),
          '/customer/root': (BuildContext context) => const CustomersRoot(),
          '/teacher/root': (BuildContext context) => const TeachersRoot(),
        },
        navigatorKey: appState.navigatorKey,
        scaffoldMessengerKey: appState.scaffoldMessengerKey,
        title: 'Supreme Octo Eureka',
        theme: appState.themeData,

        // Localization setup
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'), // English
          Locale('ar'), // Arabic
          Locale('he'), // Hebrew
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          if (locale != null) {
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale.languageCode) {
                return supportedLocale;
              }
            }
          }
          // Default to English if locale not supported
          return const Locale('en');
        },
      ),
    );
  }
}
