import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:supreme_octo_eureka/Widgets/lesson_card.dart';
import 'package:supreme_octo_eureka/app_state.dart';

class PendingLessonsPage extends StatelessWidget {
  const PendingLessonsPage({super.key});

  Future<List<Lesson>> _getPendingLessons(AppState appState) async {
    var response = await appState.dbRequest(
      body: {
        'Action': 'GetPendingLessons',
        'AccountType': 'Teacher',
        'Phone': appState.currentTeacher!.phone,
        'Password': appState.currentTeacher!.password,
      },
      indicateLoading: false,
    );

    if (response.statusCode == 200) {
      try {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['Result'] == 'SUCCESS') {
          return Lesson.fromJsonArray(jsonResponse['PendingLessons']);
        } else if (jsonResponse['Result'] == 'PHONE_DOESNT_EXIST') {
          // TODO: logout
          return List.empty();
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

    return List.empty();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.read<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lesson Requests'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: RefreshIndicator(
          onRefresh: () => _getPendingLessons(appState),
          child: FutureBuilder<List<Lesson>>(
            future: _getPendingLessons(appState),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData && snapshot.data != null) {
                return ListView(
                  children: snapshot.data!.map((lesson) {
                    return Column(
                      children: [
                        LessonCard(
                          lesson: lesson,
                          isCustomer: false,
                        ),
                        const Gap(16),
                      ],
                    );
                  }).toList(),
                );
              } else {
                return const Center(child: Text('No pending lessons'));
              }
            },
          ),
        ),
      ),
    );
  }
}
