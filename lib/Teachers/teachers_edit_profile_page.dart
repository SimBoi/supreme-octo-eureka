import 'dart:convert';
import 'package:gap/gap.dart';
import 'package:supreme_octo_eureka/app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supreme_octo_eureka/authentication/auth_logic.dart';

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
          appState.showMsgSnackBar('Profile updated successfully');
          return true;
        } else if (jsonResponse['Result'] == 'PHONE_DOESNT_EXIST') {
          // TODO: logout
          return false;
        }
        throw jsonResponse['Result'];
      } on FormatException {
        appState.showErrorSnackBar('Json Format Error');
      } catch (e) {
        appState.showErrorSnackBar(e.toString());
      }
    } else {
      appState.showErrorSnackBar('Error ${response.statusCode}');
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.read<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Gap(16),
            TextFormField(
              initialValue: appState.currentTeacher!.username,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
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
                            content: const Text('Are you sure you want to save changes?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  if (await updateProfile(appState) && context.mounted) {
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: const Text('Save Changes'),
                              ),
                            ],
                          );
                        },
                        child: const Text('Save Changes'),
                      )
                    : const Gap(0);
              },
            ),
            const Gap(16),
            ElevatedButton(
              onPressed: () {
                appState.showAlertDialog(
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        logout(appState);
                        Navigator.of(context).popUntil((route) => false);
                        Navigator.of(context).pushNamed('/');
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                );
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
