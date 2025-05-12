import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:supreme_octo_eureka/Widgets/lesson_card.dart';
import 'package:supreme_octo_eureka/app_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:supreme_octo_eureka/authentication/auth_logic.dart';

class PendingLessonsPage extends StatefulWidget {
  const PendingLessonsPage({super.key});

  @override
  State<PendingLessonsPage> createState() => _PendingLessonsPageState();
}

class _PendingLessonsPageState extends State<PendingLessonsPage> {
  List<Lesson>? _pendingLessons;
  bool _isRefreshing = false;
  List<Lesson>? _filteredLessons;
  Subject _subjectFilter = Subject.any;
  Grade _minGradeFilter = Grade.any;
  Grade _maxGradeFilter = Grade.any;

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
          List<Lesson> decodedLessons = Lesson.fromJsonArray(jsonResponse['PendingLessons']);
          decodedLessons.sort((a, b) => a.startTimestamp.compareTo(b.startTimestamp));
          setState(() {
            _isRefreshing = false;
            _pendingLessons = decodedLessons;
          });
          _applyFilters();
          return;
        } else if (jsonResponse['Result'] == 'PHONE_DOESNT_EXIST') {
          logout(appState);
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

  void _applyFilters() {
    int minGrade = _minGradeFilter == Grade.any ? 0 : _minGradeFilter.index;
    int maxGrade = _maxGradeFilter == Grade.any ? Grade.values.length - 1 : _maxGradeFilter.index;

    if (_pendingLessons == null) {
      setState(() => _filteredLessons = null);
    } else {
      setState(() => _filteredLessons = _pendingLessons!.where((lesson) {
            return (_subjectFilter == Subject.any || lesson.subject == _subjectFilter) && (minGrade <= lesson.grade.index && lesson.grade.index <= maxGrade);
          }).toList());
    }
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
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: DropdownMenu<Subject>(
                initialSelection: _subjectFilter,
                label: Text(AppLocalizations.of(context)!.subject),
                onSelected: (value) {
                  _subjectFilter = value ?? Subject.any;
                  _applyFilters();
                },
                dropdownMenuEntries: Subject.values.map((subject) {
                  return DropdownMenuEntry(
                    value: subject,
                    label: subject.name(context),
                  );
                }).toList(),
              ),
            ),
            const Gap(16),
            Wrap(
              runSpacing: 16,
              children: [
                Row(
                  children: [
                    DropdownMenu<Grade>(
                      initialSelection: _minGradeFilter,
                      label: Text(AppLocalizations.of(context)!.fromGrade),
                      onSelected: (value) {
                        _minGradeFilter = value ?? Grade.any;
                        _applyFilters();
                      },
                      dropdownMenuEntries: Grade.values.map((grade) {
                        return DropdownMenuEntry(
                          value: grade,
                          label: grade.name(context),
                        );
                      }).toList(),
                    ),
                    const Gap(4),
                    const Text('-'),
                    const Gap(4),
                  ],
                ),
                DropdownMenu<Grade>(
                  initialSelection: _maxGradeFilter,
                  label: Text(AppLocalizations.of(context)!.toGrade),
                  onSelected: (value) {
                    _maxGradeFilter = value ?? Grade.any;
                    _applyFilters();
                  },
                  dropdownMenuEntries: Grade.values.map((grade) {
                    return DropdownMenuEntry(
                      value: grade,
                      label: grade.name(context),
                    );
                  }).toList(),
                ),
              ],
            ),
            const Gap(16),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _refreshPendingLessons(appState),
                child: _isRefreshing
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredLessons != null && _filteredLessons!.isNotEmpty
                        ? ListView(
                            children: _filteredLessons!.map((lesson) {
                              return Column(
                                children: [
                                  LessonCard(
                                    lesson: lesson,
                                    isCustomer: false,
                                    viewOnly: false,
                                    onAcceptPressed: (result) {
                                      _refreshPendingLessons(appState);
                                      if (result == true && lesson.isImmediate) {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => LiveLessonWaitingPage(lesson: lesson),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                  const Gap(16),
                                ],
                              );
                            }).toList(),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
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
          ],
        ),
      ),
    );
  }
}
