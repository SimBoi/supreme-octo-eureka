import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:supreme_octo_eureka/Widgets/lesson_card.dart';
import 'package:supreme_octo_eureka/app_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PendingLessonsPage extends StatefulWidget {
  const PendingLessonsPage({super.key});

  @override
  State<PendingLessonsPage> createState() => _PendingLessonsPageState();
}

class _PendingLessonsPageState extends State<PendingLessonsPage> {
  List<Lesson>? _pendingLessons = null;
  bool _isRefreshing = false;

  Future<void> _refreshPendingLessons(AppState appState) async {
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);

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
          setState(() {
            _isRefreshing = false;
            _pendingLessons = Lesson.fromJsonArray(jsonResponse['PendingLessons']);
          });
          return;
        } else if (jsonResponse['Result'] == 'PHONE_DOESNT_EXIST') {
          // TODO: logout
        } else {
          throw jsonResponse['Result'];
        }
      } on FormatException {
        appState.showErrorSnackBar(AppLocalizations.of(appState.rootContext!)!.jsonFormatError);
      } catch (e) {
        appState.showErrorSnackBar(e.toString());
      }
    } else {
      appState.showErrorSnackBar('${response.statusCode}: ${AppLocalizations.of(appState.rootContext!)!.unexpectedError}');
    }

    setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.read<AppState>();

    if (_pendingLessons == null) {
      _refreshPendingLessons(appState);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.lessonRequests),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: RefreshIndicator(
          onRefresh: () => _refreshPendingLessons(appState),
          child: _isRefreshing
              ? const Center(child: CircularProgressIndicator())
              : _pendingLessons != null && _pendingLessons!.isNotEmpty
                  ? ListView(
                      children: _pendingLessons!.map((lesson) {
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
                    )
                  : Center(
                      child: Column(
                        children: [
                          Text(AppLocalizations.of(context)!.noPendingLessons),
                          const Gap(16),
                          ElevatedButton(
                            onPressed: () => _refreshPendingLessons(appState),
                            child: Text(AppLocalizations.of(context)!.refresh),
                          ),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }
}
