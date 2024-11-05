import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:supreme_octo_eureka/app_state.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supreme_octo_eureka/booking_logic.dart';

// lesson card widget
// A card that contains vertically stacked components, if the user is a customer, the card contains:
// 1. a title for the lesson followed by a person icon followed by the name of the teacher/student (no teacher name if the lesson is pending)
// 2. a schedule icon followed by the start date and time of the lesson followed by a clock icon followed by the duration of the lesson
// 3. a location icon followed by the link for the virtual lesson ("Lesson Pending" if the lesson is pending)
// 4. a button to cancel the lesson in the bottom right corner of the card
// If the user is a teacher, the card contains:
// 1. a title for the lesson followed by a person icon followed by the name of the student
// 2. a schedule icon followed by the start date and time of the lesson followed by a clock icon followed by the duration of the lesson
// 3. a location icon followed by the link for the virtual lesson
// 4. a button to accept/reject the lesson in the bottom right corner of the card
// 5. a button to edit the link for the virtual lesson in the bottom left corner of the card
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
            launchUrl(Uri.parse(lesson.link));
          }
        },
        child: Column(
          children: <Widget>[
            ListTile(
              title: lesson.isPending
                  ? Text(lesson.title)
                  : Row(
                      children: [
                        Text(lesson.title),
                        const Gap(8),
                        const Icon(Icons.person),
                        const Gap(8),
                        Text(isCustomer ? lesson.teacherName : lesson.studentName),
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
              Center(
                child: Text(
                  'Lesson pending...\n A teacher will be assigned soon',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).disabledColor,
                      ),
                ),
              )
            else
              ListTile(
                leading: const Icon(Icons.location_on),
                title: Text(lesson.link),
              ),
            if (isCustomer)
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
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
                  child: const Icon(Icons.cancel),
                ),
              )
            else ...[
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
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
                  child: lesson.isPending ? const Text('Accept') : const Icon(Icons.cancel),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: ElevatedButton(
                  onPressed: () {
                    // Edit link logic here
                  },
                  child: const Icon(Icons.edit),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
