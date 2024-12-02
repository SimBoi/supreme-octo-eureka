import 'package:onesignal_flutter/onesignal_flutter.dart';
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

    // initialize OneSignal
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose); //Remove this method to stop OneSignal Debugging
    OneSignal.initialize("e7d7a2bd-815c-4bd9-92dd-9b1f772b20c9");
    // The promptForPushNotificationsWithUserResponse function will show the iOS or Android push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
    OneSignal.Notifications.requestPermission(true);
    OneSignal.User.addObserver(
      (stateChanges) => appState.oneSignalID = stateChanges.current.onesignalId ?? '',
    );

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
