import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:supreme_octo_eureka/app_state.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supreme_octo_eureka/booking_logic.dart';

// lesson card widget
// A card that contains vertically stacked components, if the user is a customer, the card contains:
// - a title for the lesson
// - a person icon followed by the name of the teacher (no teacher name if the lesson is pending) followed by a phone icon followed by the phone number of the teacher
// - a schedule icon followed by the start date and time of the lesson followed by a clock icon followed by the duration of the lesson
// - a location icon followed by the link for the virtual lesson ("Lesson Pending" if the lesson is pending)
// - a button to cancel the lesson in the bottom right corner of the card
// If the user is a teacher, the card contains:
// - a title for the lesson
// - a person icon followed by the name of the student followed by a phone icon followed by the phone number of the student
// - a schedule icon followed by the start date and time of the lesson followed by a clock icon followed by the duration of the lesson
// - a location icon followed by the link for the virtual lesson
// - a button to accept/reject the lesson in the bottom right corner of the card
// - a button to edit the link for the virtual lesson in the bottom left corner of the card
// The card is clickable and navigates to the link for the virtual lesson
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
              ListTile(title: Text(lesson.title)),
              if (!lesson.isPending)
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Row(
                    children: [
                      Text(isCustomer ? lesson.teacherName : lesson.studentName),
                      const Gap(8),
                      const Icon(Icons.phone),
                      const Gap(8),
                      Text(isCustomer ? lesson.teacherPhone : lesson.studentPhone),
                    ],
                  ),
                ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Row(
                  children: [
                    Text('${lessonDate.day}/${lessonDate.month} ${lessonDate.hour % 12 == 0 ? 12 : lessonDate.hour % 12}:${lessonDate.minute.toString().padLeft(2, '0')} ${lessonDate.hour >= 12 ? 'PM' : 'AM'}'),
                    const Gap(8),
                    const Icon(Icons.access_time),
                    const Gap(8),
                    Text('${lesson.durationMinutes} mins'),
                  ],
                ),
              ),
              if (lesson.isPending)
                ListTile(
                  title: Center(
                    child: Text(
                      'Lesson pending...\n A teacher will be assigned soon',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).disabledColor,
                          ),
                    ),
                  ),
                )
              else
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
                              content: const Text('Are you sure you want to cancel this lesson?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    cancelLesson(lesson, appState);
                                    Navigator.of(appState.navigatorKey.currentContext!).pop();
                                  },
                                  child: const Text('Cancel Lesson'),
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
                                  message: 'Enter the link for the virtual lesson:',
                                  onSubmit: (link) {
                                    appState.showAlertDialog(
                                      content: const Text('Are you sure you want to edit this lesson?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            editLessonLink(lesson, link, appState);
                                            Navigator.of(appState.navigatorKey.currentContext!).pop();
                                          },
                                          child: const Text('Edit Link'),
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
                                  message: 'Enter the link for the virtual lesson:',
                                  onSubmit: (link) {
                                    appState.showAlertDialog(
                                      content: const Text('Are you sure you want to accept this lesson?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            acceptLesson(lesson, link, appState);
                                            Navigator.of(appState.navigatorKey.currentContext!).pop();
                                          },
                                          child: const Text('Accept Lesson'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } else {
                                appState.showAlertDialog(
                                  content: const Text('Are you sure you want to reject this lesson?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        rejectLesson(lesson, appState);
                                        Navigator.of(appState.navigatorKey.currentContext!).pop();
                                      },
                                      child: const Text('Reject Lesson'),
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
