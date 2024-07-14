import 'package:supreme_octo_eureka/app_state.dart';
import 'package:supreme_octo_eureka/authentication/auth_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

class SingUpPage extends StatelessWidget {
  SingUpPage({super.key, required this.pageController});

  final PageController pageController;
  final TextEditingController _phoneController = TextEditingController(
    text: '05',
  );
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _repassController = TextEditingController();

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
                  'Sign Up',
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
                const Gap(25),
                SizedBox(
                  height: 56,
                  child: TextField(
                    controller: _usernameController,
                    keyboardType: TextInputType.text,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp("[a-zA-Zs]")),
                    ],
                    onChanged: (value) {
                      if (!RegExp(r'^[a-zA-Z\s]*$').hasMatch(value)) {
                        // If the user tries to enter a non-letter or non-space character, reset the value
                        _usernameController.text = value.replaceAll(RegExp(r'[^a-zA-Z\s]'), '');
                        // Move the cursor to the end of the text
                        _usernameController.selection = TextSelection.fromPosition(TextPosition(offset: _usernameController.text.length));
                      }
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      labelText: 'Name',
                    ),
                  ),
                ),
                const Gap(25),
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: TextField(
                          controller: _passController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            labelText: 'Password',
                          ),
                        ),
                      ),
                    ),
                    const Gap(15),
                    Expanded(
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: TextField(
                          controller: _repassController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            labelText: 'Confirm Password',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(25),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!isPasswordStrong(_passController.text, appState)) {
                        return;
                      } else if (_passController.text != _repassController.text) {
                        appState.showErrorSnackBar('Passwords do not match!');
                      } else {
                        bool result = await signup(_phoneController.text, _passController.text, _usernameController.text, appState);
                        if (result && context.mounted) {
                          appState.showMsgSnackBar('Account created successfully!');
                          pageController.jumpToPage(1);
                          Navigator.of(context).pushNamed('/auth/verify_phone');
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary,
                      foregroundColor: theme.colorScheme.onSecondary,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    child: Text(
                      'Create account',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const Gap(15),
                Row(
                  children: [
                    Text(
                      'have an account?',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outlineVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Gap(2.5),
                    InkWell(
                      onTap: () {
                        pageController.animateToPage(1, duration: const Duration(milliseconds: 500), curve: Curves.ease);
                      },
                      child: Text(
                        'Log In ',
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
}
