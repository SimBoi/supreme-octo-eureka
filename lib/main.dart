import 'package:supreme_octo_eureka/Teachers/teachers_root.dart';
import 'package:supreme_octo_eureka/app_state.dart';
import 'package:supreme_octo_eureka/authentication/auth_main.dart';
import 'package:supreme_octo_eureka/authentication/verify.dart';
import 'package:supreme_octo_eureka/Customers/customers_root.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supreme_octo_eureka/theme.dart';

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
      ),
    );
  }
}
