import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:supreme_octo_eureka/Widgets/contact.dart';
import 'package:supreme_octo_eureka/app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supreme_octo_eureka/authentication/auth_logic.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditCustomerProfilePage extends StatelessWidget {
  EditCustomerProfilePage({super.key});

  final ValueNotifier<bool> isChanged = ValueNotifier<bool>(false);
  final ValueNotifier<String> newName = ValueNotifier<String>('');

  void checkIfChanged(AppState appState) {
    isChanged.value = newName.value != appState.currentCustomer!.username;
  }

  Future<bool> updateProfile(AppState appState) async {
    var response = await appState.dbRequest(
      body: {
        'Action': 'UpdateProfile',
        'AccountType': 'Customer',
        'Phone': appState.currentCustomer!.phone,
        'Password': appState.currentCustomer!.password,
        'NewUsername': newName.value,
      },
    );

    if (response.statusCode == 200) {
      try {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['Result'] == 'SUCCESS') {
          appState.updateProfile(newName.value);
          appState.showMsgSnackBar(AppLocalizations.of(appState.rootContext!)!.profileUpdated);
          return true;
        } else if (jsonResponse['Result'] == 'PHONE_DOESNT_EXIST') {
          logout(appState);
          return false;
        }
        throw jsonResponse['Result'];
      } on FormatException {
        appState.showErrorSnackBar(AppLocalizations.of(appState.rootContext!)!.jsonFormatError);
      } catch (e) {
        appState.showErrorSnackBar(e.toString());
      }
    } else {
      appState.showErrorSnackBar('${response.statusCode}: ${AppLocalizations.of(appState.rootContext!)!.unexpectedError}');
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.read<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.editProfile),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Gap(16),
            TextFormField(
              initialValue: appState.currentCustomer!.username,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.username,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.text,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[\p{L} ]', unicode: true)),
              ],
              onChanged: (value) {
                newName.value = value;
                checkIfChanged(appState);
              },
            ),
            const Gap(16),
            ValueListenableBuilder<bool>(
              valueListenable: isChanged,
              builder: (context, value, child) {
                return value
                    ? ElevatedButton(
                        onPressed: () {
                          appState.showAlertDialog(
                            content: Text(AppLocalizations.of(context)!.confirmSaveChanges),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(AppLocalizations.of(context)!.cancel),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  if (await updateProfile(appState) && context.mounted) {
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: Text(AppLocalizations.of(context)!.saveChanges),
                              ),
                            ],
                          );
                        },
                        child: Text(AppLocalizations.of(context)!.saveChanges),
                      )
                    : const Gap(0);
              },
            ),
            const Gap(16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ContactPage()),
                );
              },
              child: const Text("Contact Us"),
            ),
            const Gap(16),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(appState.themeData.colorScheme.errorContainer),
              ),
              onPressed: () {
                appState.showAlertDialog(
                  content: Text(AppLocalizations.of(context)!.confirmLogout),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(AppLocalizations.of(context)!.cancel),
                    ),
                    TextButton(
                      onPressed: () {
                        logout(appState);
                      },
                      child: Text(AppLocalizations.of(context)!.logout),
                    ),
                  ],
                );
              },
              child: Text(
                AppLocalizations.of(context)!.logout,
                style: TextStyle(color: appState.themeData.colorScheme.onErrorContainer),
              ),
            ),
            const Gap(16),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.transparent),
                foregroundColor: WidgetStateProperty.all(appState.themeData.colorScheme.errorContainer),
                side: WidgetStateProperty.all(BorderSide(color: appState.themeData.colorScheme.errorContainer)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ContactPage()),
                );
              },
              child: Text(AppLocalizations.of(context)!.requestAccountDeletion),
            ),
          ],
        ),
      ),
    );
  }
}
