import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:supreme_octo_eureka/app_state.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supreme_octo_eureka/booking_logic.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LessonCard extends StatelessWidget {
  final Lesson lesson;
  final bool isCustomer;
  final bool viewOnly;
  final void Function(bool)? onAcceptPressed;
  final void Function(bool)? onRejectPressed;
  final void Function(bool)? onCancelPressed;

  const LessonCard({
    super.key,
    required this.lesson,
    required this.isCustomer,
    required this.viewOnly,
    this.onAcceptPressed,
    this.onRejectPressed,
    this.onCancelPressed,
  });

  @override
  Widget build(BuildContext context) {
    var appState = context.read<AppState>();

    Widget cardContent = InkWell(
      onTap: () {
        // clicking on the card will open the lesson link if available, otherwise it will open the live lesson waiting page
        if (!lesson.isPending) {
          try {
            launchUrl(Uri.parse(lesson.link));
          } catch (e) {
            appState.showErrorSnackBar(e.toString());
          }
        } else if (lesson.isImmediate) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => LiveLessonWaitingPage(lesson: lesson),
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            // the lesson title
            ListTile(
              leading: const Icon(Icons.topic),
              title: Text(lesson.title),
            ),

            // the lesson subject and grade
            ListTile(
              leading: const Icon(Icons.subject),
              title: Wrap(
                children: [
                  Text(lesson.subject.name(context)),
                  const SizedBox(width: 16),
                  const Icon(Icons.school),
                  const SizedBox(width: 16),
                  Text(lesson.grade.name(context)),
                ],
              ),
            ),

            // the student name and phone number if the user is a teacher
            if (!isCustomer)
              ListTile(
                leading: const Icon(Icons.person),
                title: Wrap(
                  children: [
                    Text(lesson.studentName),
                    const SizedBox(width: 16),
                    const Icon(Icons.phone),
                    const SizedBox(width: 16),
                    Text(appState.getPhoneLocalFormat(phone: lesson.studentPhone)),
                  ],
                ),
              )

            // the teacher name and phone number if the user is a customer and the lesson is not pending
            else if (!lesson.isPending)
              ListTile(
                leading: const Icon(Icons.person),
                title: Wrap(
                  children: [
                    Text(lesson.teacherName),
                    const SizedBox(width: 16),
                    const Icon(Icons.phone),
                    const SizedBox(width: 16),
                    Text(appState.getPhoneLocalFormat(phone: lesson.teacherPhone)),
                  ],
                ),
              ),

            // the lesson date and duration
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Wrap(
                children: [
                  (lesson.isImmediate && lesson.link.isEmpty) ? Text(AppLocalizations.of(context)!.liveLesson) : Text(Lesson.getDateTimeString(context, lesson.startTimestamp)),
                  const SizedBox(width: 16),
                  const Icon(Icons.access_time_filled),
                  const SizedBox(width: 16),
                  Text(Lesson.getDurationString(context, lesson.durationMinutes)),
                ],
              ),
            ),

            // if no teacher is assigned yet and the user is a customer, show a message
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

            // if the lesson is not pending, show the lesson link if it exists, otherwise show a message
            else if (!lesson.isPending && lesson.link.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.location_on),
                title: Text(lesson.link),
              )
            else if (!lesson.isPending)
              ListTile(
                title: Center(
                  child: Text(
                    AppLocalizations.of(context)!.noLink,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).disabledColor,
                        ),
                  ),
                ),
              ),

            // show the actions buttons
            if (!viewOnly)
              ListTile(
                title: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    // join/copy lesson link button for lessons with a non-empty link
                    if (lesson.link.isNotEmpty) ...[
                      OutlinedButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: lesson.link)).then((_) {
                            appState.showMsgSnackBar(AppLocalizations.of(context)!.lessonURLCopied);
                          });
                        },
                        child: Text(AppLocalizations.of(context)!.copyLessonURL),
                      ),
                      FilledButton.tonal(
                        onPressed: () {
                          launchUrl(Uri.parse(lesson.link));
                        },
                        child: Text(AppLocalizations.of(context)!.joinLesson),
                      ),
                    ],

                    // cancel lesson button for customers
                    if (isCustomer) ...[
                      OutlinedButton(
                        style: ButtonStyle(
                          foregroundColor: WidgetStateProperty.all(appState.themeData.colorScheme.errorContainer),
                        ),
                        onPressed: () {
                          appState.showAlertDialog(
                            content: Text(AppLocalizations.of(context)!.confirmCancelLesson),
                            actions: [
                              TextButton(
                                onPressed: () async {
                                  bool result = await cancelLesson(lesson, appState);
                                  Navigator.of(appState.navigatorKey.currentContext!).pop();
                                  onCancelPressed?.call(result);
                                },
                                child: Text(AppLocalizations.of(context)!.cancelLesson),
                              ),
                            ],
                          );
                        },
                        child: Text(AppLocalizations.of(context)!.cancelLesson),
                      ),
                    ],

                    // accept/reject lesson button for teachers
                    if (!isCustomer) ...[
                      lesson.isPending
                          ? OutlinedButton(
                              onPressed: () {
                                appState.showAlertDialog(
                                  content: Text(AppLocalizations.of(context)!.confirmAcceptLesson),
                                  actions: [
                                    TextButton(
                                      onPressed: () async {
                                        bool result = await acceptLesson(lesson, appState);
                                        Navigator.of(appState.navigatorKey.currentContext!).pop();
                                        onAcceptPressed?.call(result);
                                      },
                                      child: Text(AppLocalizations.of(context)!.acceptLesson),
                                    ),
                                  ],
                                );
                              },
                              child: Text(AppLocalizations.of(context)!.acceptLesson),
                            )
                          : OutlinedButton(
                              style: ButtonStyle(
                                foregroundColor: WidgetStateProperty.all(appState.themeData.colorScheme.errorContainer),
                              ),
                              onPressed: () {
                                appState.showAlertDialog(
                                  content: Text(AppLocalizations.of(context)!.confirmRejectLesson),
                                  actions: [
                                    TextButton(
                                      onPressed: () async {
                                        bool result = await rejectLesson(lesson, appState);
                                        Navigator.of(appState.navigatorKey.currentContext!).pop();
                                        onRejectPressed?.call(result);
                                      },
                                      child: Text(AppLocalizations.of(context)!.rejectLesson),
                                    ),
                                  ],
                                );
                              },
                              child: Text(AppLocalizations.of(context)!.rejectLesson),
                            ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );

    if (lesson.isImmediate) {
      return Card.outlined(
        shape: (Theme.of(context).cardTheme.shape as RoundedRectangleBorder? ?? const RoundedRectangleBorder()).copyWith(
          side: BorderSide(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        child: cardContent,
      );
    } else {
      return Card(
        child: cardContent,
      );
    }
  }
}

// Live Lesson Waiting Page
// when clicking on the card, it will open a page with text in the middle saying "A teacher will be assigned to you shortly, please keep this page open"
// while the page is open and no link is available yet, every 5 seconds it will call Future<bool> getLiveLessonLink(int orderID, AppState appState) async to check if a lesson link is available, when it is available
// when the link is available, a button will appear in place of the text saying "Join Lesson" and when clicked it will open the link
class LiveLessonWaitingPage extends StatefulWidget {
  final Lesson lesson;
  const LiveLessonWaitingPage({super.key, required this.lesson});

  @override
  State<LiveLessonWaitingPage> createState() => _LiveLessonWaitingPageState();
}

class _LiveLessonWaitingPageState extends State<LiveLessonWaitingPage> {
  String lessonLink = "";
  AppState? appState;

  @override
  void initState() {
    super.initState();
    appState = context.read<AppState>();
    lessonLink = widget.lesson.link;

    // long-polling for the lesson link
    () async {
      while (mounted && lessonLink.isEmpty) {
        if (appState?.lifecycleState != AppLifecycleState.resumed) {
          await Future.delayed(const Duration(seconds: 1));
          continue;
        }

        final success = await longPollLiveLessonLink(
          widget.lesson.orderID,
          appState!,
          isBackground: true,
        );
        if (success) {
          setState(() {
            lessonLink = widget.lesson.link;
          });
          break;
        }
      }
    }();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.joinLiveLesson),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: lessonLink.isNotEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.lessonStartsAt(
                        Lesson.getDateTimeString(
                          context,
                          widget.lesson.startTimestamp,
                          showDate: false,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(16),
                    ElevatedButton(
                      onPressed: () {
                        launchUrl(Uri.parse(lessonLink));
                      },
                      child: Text(AppLocalizations.of(context)!.joinLesson),
                    ),
                    const Gap(16),
                    ElevatedButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: lessonLink)).then((_) {
                          appState?.showMsgSnackBar(AppLocalizations.of(context)!.lessonURLCopied);
                        });
                      },
                      child: Text(AppLocalizations.of(context)!.copyLessonURL),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.waitingForTeacher,
                      textAlign: TextAlign.center,
                    ),
                    const Gap(16),
                    const CircularProgressIndicator(),
                  ],
                ),
        ),
      ),
    );
  }
}
