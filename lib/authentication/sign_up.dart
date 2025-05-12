import 'package:supreme_octo_eureka/Widgets/Legal.dart';
import 'package:supreme_octo_eureka/app_state.dart';
import 'package:supreme_octo_eureka/authentication/auth_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SingUpPage extends StatelessWidget {
  SingUpPage({super.key, required this.pageController});

  final PageController pageController;
  final TextEditingController _phoneController = TextEditingController(
    text: '05',
  );
  final TextEditingController _usernameController = TextEditingController();
  final ValueNotifier<bool> agreedNotifier = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    var appState = context.read<AppState>();
    var theme = Theme.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // const AspectRatio(
            //   aspectRatio: 1,
            //   child: Placeholder(),
            // ),
            const Gap(120),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.signUp,
                    style: theme.textTheme.headlineMedium!.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Gap(40),
                  SizedBox(
                    height: 56,
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      maxLength: 10,
                      onChanged: (value) {
                        if (!value.startsWith('05')) {
                          // If the user tries to delete '05', reset the value
                          _phoneController.text = '05';
                          // Move the cursor to the end of the text
                          _phoneController.selection = TextSelection.fromPosition(TextPosition(offset: _phoneController.text.length));
                        }
                      },
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        labelText: AppLocalizations.of(context)!.phone,
                        counterText: '',
                      ),
                    ),
                  ),
                  const Gap(16),
                  SizedBox(
                    height: 56,
                    child: TextField(
                      controller: _usernameController,
                      keyboardType: TextInputType.text,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'[\p{L} ]', unicode: true)),
                      ],
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        labelText: AppLocalizations.of(context)!.username,
                      ),
                    ),
                  ),
                  const Gap(16),
                  ValueListenableBuilder<bool>(
                    valueListenable: agreedNotifier,
                    builder: (context, agreed, child) {
                      return CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        title: Row(
                          children: [
                            Text(AppLocalizations.of(context)!.agreeTerms1),
                            InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const LegalPage()),
                                );
                              },
                              child: Text(
                                AppLocalizations.of(context)!.agreeTerms2,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        value: agreed,
                        onChanged: (value) {
                          agreedNotifier.value = value ?? false;
                        },
                      );
                    },
                  ),
                  const Gap(16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _onSignUpButtonPressed(context, appState),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.secondaryContainer,
                        foregroundColor: theme.colorScheme.onSecondaryContainer,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.signUp,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const Gap(16),
                  Row(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.alreadyHaveAnAccount,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Gap(2.5),
                      InkWell(
                        onTap: () {
                          // hide the keyboard
                          FocusScope.of(context).unfocus();
                          pageController.animateToPage(1, duration: const Duration(milliseconds: 500), curve: Curves.ease);
                        },
                        child: Text(
                          AppLocalizations.of(context)!.login,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSignUpButtonPressed(BuildContext context, AppState appState) async {
    var phone = _phoneController.text;
    var username = _usernameController.text;

    if (agreedNotifier.value == false) {
      appState.showErrorSnackBar(AppLocalizations.of(context)!.mustAgreeTerms);
      return;
    }

    bool result = await signup(phone, username, appState);
    if (result && context.mounted) {
      appState.showMsgSnackBar(AppLocalizations.of(context)!.accountCreated);

      if (!(await Navigator.of(context).pushNamed('/auth/verify_phone') as bool)) {
        return;
      }

      if (!(await login(phone, appState.getPassword(), appState))) {
        if (context.mounted) {
          pageController.jumpToPage(1);
        }
        return;
      }

      if (context.mounted) {
        Navigator.of(context).popUntil((route) => false);
        Navigator.of(context).pushNamed('/${appState.accountType.name}/root');
      }
    }
  }
}
