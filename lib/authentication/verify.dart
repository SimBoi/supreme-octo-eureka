import 'package:supreme_octo_eureka/app_state.dart';
import 'package:flutter/material.dart';
import 'package:supreme_octo_eureka/authentication/auth_logic.dart';
import 'package:flutter/services.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

class VerifyPhonePage extends StatelessWidget {
  VerifyPhonePage({super.key});

  final PageController pageController = PageController(initialPage: 0);
  final TextEditingController _codeController = TextEditingController();
  final GlobalKey<ResendTimerState> resendTimerKey = GlobalKey<ResendTimerState>();

  @override
  Widget build(BuildContext context) {
    var appState = context.read<AppState>();
    var theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        Navigator.of(context).pop(false);
      },
      child: Scaffold(
        body: Column(
          children: [
            const AspectRatio(
              aspectRatio: 1,
              child: Placeholder(),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                child: Column(
                  children: <Widget>[
                    Text(
                      'Verify Phone Number',
                      style: theme.textTheme.headlineMedium!.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Gap(40),
                    Expanded(
                      child: PageView(
                        physics: const NeverScrollableScrollPhysics(),
                        controller: pageController,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'We need to verify your phone number before you can continue.\n\nWe will send you a verification code using whatsapp to the following number:',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onBackground,
                                ),
                              ),
                              const Gap(20),
                              Text(
                                appState.getPhoneLocalFormat(),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onBackground,
                                ),
                              ),
                              const Gap(40),
                              SizedBox(
                                height: 56,
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => _onRequestCodeButtonPressed(appState),
                                  child: const Text('Send Verification Code'),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(
                                width: double.maxFinite,
                                height: 56,
                                child: TextField(
                                  controller: _codeController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  maxLength: AppState.verificationCodeLength,
                                  onChanged: (value) {
                                    if (value.length == AppState.verificationCodeLength) {
                                      _onConfirmCodeButtonPressed(context, appState);
                                    }
                                  },
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(10)),
                                    ),
                                    labelText: 'Verification Code',
                                    counterText: '',
                                  ),
                                ),
                              ),
                              const Gap(32),
                              SizedBox(
                                width: double.maxFinite,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: () => _onConfirmCodeButtonPressed(context, appState),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.secondary,
                                    foregroundColor: theme.colorScheme.onSecondary,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(10)),
                                    ),
                                  ),
                                  child: Text(
                                    'Confirm',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: theme.colorScheme.onSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              const Gap(15),
                              ResendTimer(
                                key: resendTimerKey,
                                resendCode: () => _onRequestCodeButtonPressed(appState),
                              ),
                              const Gap(40),
                              SizedBox(
                                width: double.infinity,
                                child: Text(
                                  'A ${AppState.verificationCodeLength}-digit verification code has been sent to ${appState.getPhoneLocalFormat()}',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.outlineVariant,
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
            ),
          ],
        ),
      ),
    );
  }

  void _onRequestCodeButtonPressed(AppState appState) async {
    var (
      result,
      cooldown
    ) = await requestVerification(appState.getPhoneInternationalFormat(), appState.getPassword(), appState);
    if (result) {
      if (pageController.page == 0) {
        pageController.animateToPage(1, duration: const Duration(milliseconds: 500), curve: Curves.ease);

        // wait for the page to build before starting the timer
        await Future.delayed(const Duration(milliseconds: 100));
      }
      resendTimerKey.currentState?.resetTimer(cooldown);
    }
  }

  void _onConfirmCodeButtonPressed(BuildContext context, AppState appState) async {
    if (_codeController.text.length != AppState.verificationCodeLength) {
      appState.showErrorSnackBar('Verification code must be ${AppState.verificationCodeLength} digits long!');
      return;
    }
    bool result = await verifyPhone(appState.getPhoneInternationalFormat(), appState.getPassword(), _codeController.text, appState);
    if (result && context.mounted) {
      Navigator.of(context).pop(true);
    }
  }
}

class ResendTimer extends StatefulWidget {
  const ResendTimer({
    super.key,
    required this.resendCode,
  });

  final Function resendCode;

  @override
  State<ResendTimer> createState() => ResendTimerState();
}

class ResendTimerState extends State<ResendTimer> {
  int cooldown = 30;
  bool isTimerRunning = false;

  void resetTimer(int cooldown) {
    print('resetting timer to $cooldown');
    setState(() {
      this.cooldown = cooldown;
      isTimerRunning = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    // if the timer is still running, show the timer
    // if the timer ended, show the resend button

    List<Widget> children = [];
    if (isTimerRunning) {
      children = [
        Text(
          'Resend  ',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w400,
          ),
        ),
        TimerCountdown(
          spacerWidth: 0,
          enableDescriptions: false,
          colonsTextStyle: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w400,
          ),
          timeTextStyle: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w400,
          ),
          format: CountDownTimerFormat.minutesSeconds,
          endTime: DateTime.now().add(
            Duration(seconds: cooldown),
          ),
          onEnd: () {
            setState(() {
              isTimerRunning = false;
            });
          },
        ),
      ];
    } else {
      children = [
        TextButton(
          onPressed: () {
            widget.resendCode();
          },
          child: Text(
            'Resend Code',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ];
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }
}
