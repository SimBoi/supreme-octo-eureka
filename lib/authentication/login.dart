import 'package:supreme_octo_eureka/app_state.dart';
import 'package:supreme_octo_eureka/authentication/auth_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key, required this.pageController});

  final PageController pageController;
  // phone should always begin with 05
  final TextEditingController _phoneController = TextEditingController(
    text: '05',
  );

  @override
  Widget build(BuildContext context) {
    var appState = context.read<AppState>();
    var theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          const AspectRatio(
            aspectRatio: 1,
            child: Placeholder(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Login',
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
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      labelText: 'Phone',
                      counterText: '',
                    ),
                  ),
                ),
                const Gap(16),
                SizedBox(
                  width: double.maxFinite,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => _onLoginButtonPressed(context, appState),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondaryContainer,
                      foregroundColor: theme.colorScheme.onSecondaryContainer,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    child: Text(
                      'Login',
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
                      'Don’t have an account?',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Gap(2.5),
                    InkWell(
                      onTap: () {
                        pageController.animateToPage(0, duration: const Duration(milliseconds: 500), curve: Curves.ease);
                      },
                      child: Text(
                        'Sign Up',
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
    );
  }

  void _onLoginButtonPressed(BuildContext context, AppState appState) async {
    String phone = _phoneController.text;

    // check if phone is valid
    if (phone == '') {
      appState.showErrorSnackBar('Phone is required!');
      return;
    } else if (phone.length != 10) {
      appState.showErrorSnackBar('Phone number must be 10 digits!');
      return;
    }

    String response = await getAccountType(phone, appState);
    if (response == 'Customer') {
      appState.accountType = AccountType.customer;
      appState.currentCustomer = Customer(
        id: 0,
        username: '',
        phone: phone,
        password: '',
        oneSignalID: '',
        currentAppointments: [],
      );
    } else if (response == 'Teacher') {
      appState.accountType = AccountType.teacher;
      appState.currentTeacher = Teacher(
        id: 0,
        username: '',
        phone: phone,
        password: '',
        oneSignalID: '',
        currentAppointments: [],
      );
    } else if (response == 'None') {
      appState.accountType = AccountType.none;
      appState.showErrorSnackBar('Phone number is not associated with any account!');
      return;
    } else {
      return;
    }

    if (context.mounted) {
      if (!(await Navigator.of(context).pushNamed('/auth/verify_phone') as bool)) {
        return;
      }

      if (!(await login(phone, appState.getPassword(), appState))) {
        return;
      }

      if (context.mounted) {
        Navigator.of(context).popUntil((route) => false);
        Navigator.of(context).pushNamed('/${appState.accountType.name}/root');
      }
    }
  }
}
