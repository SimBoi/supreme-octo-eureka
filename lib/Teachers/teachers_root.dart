import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:supreme_octo_eureka/Teachers/teachers_edit_profile_page.dart';
import 'package:supreme_octo_eureka/Teachers/teachers_pending_lessons_page.dart';
import 'package:supreme_octo_eureka/Widgets/lesson_card.dart';
import 'package:supreme_octo_eureka/app_state.dart';

class TeachersRoot extends StatelessWidget {
  const TeachersRoot({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.read<AppState>();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            const Gap(32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Schedule',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                FilledButton.tonal(
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all<EdgeInsets>(EdgeInsets.zero),
                  ),
                  child: const Icon(Icons.person),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditTeacherProfilePage()),
                    );
                  },
                ),
              ],
            ),
            const Gap(24),
            Card.filled(
              color: appState.themeData.colorScheme.tertiaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb,
                      color: appState.themeData.colorScheme.onTertiaryContainer,
                    ),
                    const Gap(8),
                    Expanded(
                      child: Text(
                        'You can view and manage your upcoming lessons on this page. Tap the button at the bottom right to accept new lessons.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: appState.themeData.colorScheme.onTertiaryContainer,
                            ),
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Gap(16),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  // MaterialPageRoute(builder: (context) => TeacherHistoryPage()), TODO
                  MaterialPageRoute(builder: (context) => Scaffold(appBar: AppBar(title: const Text('Teacher History')))),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Lessons History',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Icon(Icons.arrow_forward),
                ],
              ),
            ),
            const Gap(16),
            Selector<AppState, List<Lesson>>(
              selector: (_, appState) => appState.currentTeacher!.currentAppointments,
              builder: (context, appointments, child) {
                if (appointments.isEmpty) {
                  return Column(
                    children: [
                      const Gap(16),
                      Center(
                        child: Text(
                          'No lessons booked.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).disabledColor,
                              ),
                        ),
                      ),
                    ],
                  );
                }
                return Column(
                  children: appointments.map((lesson) {
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
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PendingLessonsPage()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Accept Lessons'),
      ),
    );
  }
}
