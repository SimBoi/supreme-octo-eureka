import 'dart:convert';
import 'package:supreme_octo_eureka/Widgets/lesson_card.dart';
import 'package:supreme_octo_eureka/app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supreme_octo_eureka/authentication/auth_logic.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TeachersHistoryPage extends StatefulWidget {
  const TeachersHistoryPage({super.key});

  @override
  _TeachersHistoryPageState createState() => _TeachersHistoryPageState();
}

class _TeachersHistoryPageState extends State<TeachersHistoryPage> {
  List<Lesson> lessons = [];

  Future<void> _refreshOrders(BuildContext context) async {
    var appState = context.read<AppState>();
    bool success = await getHistory(appState);
    if (success) {
      setState(() {});
    }
  }

  Future<bool> getHistory(AppState appState) async {
    var response = await appState.dbRequest(
      body: {
        'Action': 'GetLessonsHistory',
        'AccountType': 'Teacher',
        'Phone': appState.currentCustomer!.phone,
        'Password': appState.currentCustomer!.password,
      },
    );

    if (response.statusCode == 200) {
      try {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['Result'] == 'SUCCESS') {
          lessons.clear();
          Lesson.fromJsonArray(jsonResponse['LessonsHistory']).forEach((lesson) {
            lessons.add(lesson); // TODO: test this
          });
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
    var appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.lessonsHistory),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: RefreshIndicator(
          onRefresh: () => _refreshOrders(context),
          child: ListView.builder(
            itemCount: lessons.length,
            itemBuilder: (context, index) {
              var lesson = lessons[lessons.length - 1 - index];
              return LessonCard(
                lesson: lesson,
                isCustomer: false,
                viewOnly: true,
              );
            },
          ),
        ),
      ),
    );
  }
}
