import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:supreme_octo_eureka/app_state.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supreme_octo_eureka/booking_logic.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LessonCard extends StatelessWidget {
  final Lesson lesson;
  final bool isCustomer;

  const LessonCard({
    super.key,
    required this.lesson,
    required this.isCustomer,
  });

  @override
  Widget build(BuildContext context) {
    var appState = context.read<AppState>();
    DateTime lessonDate = DateTime.fromMillisecondsSinceEpoch(lesson.startTimestamp * 1000);

    return Card(
      child: InkWell(
        onTap: () {
          if (!lesson.isPending) {
            try {
              launchUrl(Uri.parse(lesson.link));
            } catch (e) {
              appState.showErrorSnackBar(e.toString());
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.topic),
                title: Text(lesson.title),
              ),
              ListTile(
                leading: const Icon(Icons.subject),
                title: Row(
                  children: [
                    Text(lesson.subject.name(context)),
                    const Gap(16),
                    const Icon(Icons.school),
                    const Gap(16),
                    Text(lesson.grade.name(context)),
                  ],
                ),
              ),
              if (!lesson.isPending)
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Row(
                    children: [
                      Text(isCustomer ? lesson.teacherName : lesson.studentName),
                      const Gap(16),
                      const Icon(Icons.phone),
                      const Gap(16),
                      Text(isCustomer ? lesson.teacherPhone : lesson.studentPhone),
                    ],
                  ),
                ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Row(
                  children: [
                    Text('${lessonDate.day}/${lessonDate.month} ${lessonDate.hour % 12 == 0 ? 12 : lessonDate.hour % 12}:${lessonDate.minute.toString().padLeft(2, '0')} ${lessonDate.hour >= 12 ? 'PM' : 'AM'}'),
                    const Gap(16),
                    const Icon(Icons.access_time_filled),
                    const Gap(16),
                    if (lesson.durationMinutes >= 60) Text(AppLocalizations.of(context)!.hours((lesson.durationMinutes / 60).toStringAsFixed((lesson.durationMinutes % 60 == 0) ? 0 : 1))) else Text(AppLocalizations.of(context)!.minutes(lesson.durationMinutes.toString())),
                  ],
                ),
              ),
              if (lesson.isPending && isCustomer)
                ListTile(
                  title: Center(
                    child: Text(
                      AppLocalizations.of(context)!.lessonPending,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).disabledColor,
                          ),
                    ),
                  ),
                )
              else if (!lesson.isPending)
                ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text(lesson.link),
                ),
              ListTile(
                title: isCustomer
                    ? Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          onPressed: () {
                            appState.showAlertDialog(
                              content: Text(AppLocalizations.of(context)!.confirmCancelLesson),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    cancelLesson(lesson, appState);
                                    Navigator.of(appState.navigatorKey.currentContext!).pop();
                                  },
                                  child: Text(AppLocalizations.of(context)!.cancelLesson),
                                ),
                              ],
                            );
                          },
                          icon: const Icon(Icons.cancel),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (!lesson.isPending) ...[
                            IconButton(
                              onPressed: () {
                                appState.showInputDialog(
                                  message: AppLocalizations.of(context)!.enterLink,
                                  onSubmit: (link) {
                                    appState.showAlertDialog(
                                      content: Text(AppLocalizations.of(context)!.confirmEditLesson),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            editLessonLink(lesson, link, appState);
                                            Navigator.of(appState.navigatorKey.currentContext!).pop();
                                          },
                                          child: Text(AppLocalizations.of(context)!.editLink),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              icon: const Icon(Icons.edit),
                            ),
                            const Gap(8),
                          ],
                          IconButton(
                            onPressed: () {
                              if (lesson.isPending) {
                                appState.showInputDialog(
                                  message: AppLocalizations.of(context)!.enterLink,
                                  onSubmit: (link) {
                                    appState.showAlertDialog(
                                      content: Text(AppLocalizations.of(context)!.confirmAcceptLesson),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            acceptLesson(lesson, link, appState);
                                            Navigator.of(appState.navigatorKey.currentContext!).pop();
                                          },
                                          child: Text(AppLocalizations.of(context)!.acceptLesson),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } else {
                                appState.showAlertDialog(
                                  content: Text(AppLocalizations.of(context)!.confirmRejectLesson),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        rejectLesson(lesson, appState);
                                        Navigator.of(appState.navigatorKey.currentContext!).pop();
                                      },
                                      child: Text(AppLocalizations.of(context)!.rejectLesson),
                                    ),
                                  ],
                                );
                              }
                            },
                            icon: lesson.isPending ? const Icon(Icons.add_circle) : const Icon(Icons.cancel),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
