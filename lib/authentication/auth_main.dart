import 'package:supreme_octo_eureka/app_state.dart';
import 'package:supreme_octo_eureka/authentication/auth_logic.dart';
import 'package:supreme_octo_eureka/authentication/login.dart';
import 'package:supreme_octo_eureka/authentication/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class AuthMain extends StatefulWidget {
  const AuthMain({
    super.key,
  });

  @override
  State<AuthMain> createState() => _AuthMainState();
}

class _AuthMainState extends State<AuthMain> {
  final PageController pageController = PageController(initialPage: 0);
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    var appState = context.read<AppState>();
    loadSavedCredentials(appState).then((value) {
      if (value == false) {
        setState(() {
          isLoading = false;
        });
      }
      if ((appState.accountType == AccountType.customer && appState.currentCustomer!.isVerified) || (appState.accountType == AccountType.barber)) {
        Navigator.of(context).popUntil((route) => false);
        Navigator.of(context).pushNamed('/${appState.accountType.name}/root');
      } else {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: CircularProgressIndicator(),
      );
    } else {
      return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;
          if (pageController.page?.round() == 0) {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              SystemNavigator.pop();
            }
            return;
          } else {
            pageController.previousPage(
              duration: const Duration(milliseconds: 500),
              curve: Curves.ease,
            );
            return;
          }
        },
        child: Scaffold(
          body: PageView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 2,
            controller: pageController,
            itemBuilder: (context, index) {
              if (index == 0) {
                return SingUpPage(
                  pageController: pageController,
                );
              } else {
                return LoginPage(
                  pageController: pageController,
                );
              }
            },
          ),
        ),
      );
    }
  }
}
