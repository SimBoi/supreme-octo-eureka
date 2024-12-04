import 'dart:convert';
import 'package:gap/gap.dart';
import 'package:supreme_octo_eureka/app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supreme_octo_eureka/authentication/auth_logic.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditTeacherProfilePage extends StatelessWidget {
  EditTeacherProfilePage({super.key});

  final ValueNotifier<bool> isChanged = ValueNotifier<bool>(false);
  final ValueNotifier<String> newName = ValueNotifier<String>('');

  void checkIfChanged(AppState appState) {
    isChanged.value = newName.value != appState.currentTeacher!.username;
  }

  Future<bool> updateProfile(AppState appState) async {
    var response = await appState.dbRequest(
      body: {
        'Action': 'UpdateProfile',
        'AccountType': 'Teacher',
        'Phone': appState.currentTeacher!.phone,
        'Password': appState.currentTeacher!.password,
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
          // TODO: logout
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
              initialValue: appState.currentTeacher!.username,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.username,
                border: const OutlineInputBorder(),
              ),
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
                        Navigator.of(context).popUntil((route) => false);
                        Navigator.of(context).pushNamed('/');
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
          ],
        ),
      ),
    );
  }
}
