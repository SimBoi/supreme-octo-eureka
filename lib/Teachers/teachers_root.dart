import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:supreme_octo_eureka/Widgets/lesson_card.dart';
import 'package:supreme_octo_eureka/app_state.dart';

// Main Widget for the app
// A vertically scrollable page that contains:
// 1. the app title
// 2. a card with the customer's profile information (just the name currently), clickable to navigate to the EditProfilePage page
// 3. a "Booked Lessons" title
// 4. a list of LessonCards created from the app state's currentTeacher's currentAppointments list
// 5. an "Order Lesson" persistent button on the bottom of the screen
class TeachersRoot extends StatelessWidget {
  const TeachersRoot({super.key});

  @override
  Widget build(BuildContext context) {
    // var appState = context.read<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Supreme Octo Eureka'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            Card(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    // MaterialPageRoute(builder: (context) => EditTeacherProfilePage()), TODO
                    MaterialPageRoute(builder: (context) => Scaffold(appBar: AppBar(title: const Text('Teacher Profile')))),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Selector<AppState, String>(
                      selector: (_, appState) => appState.currentTeacher!.username,
                      builder: (context, username, child) {
                        return Text(username);
                      },
                    ),
                    trailing: const Icon(Icons.arrow_forward),
                  ),
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
            Text(
              'Upcoming Lessons',
              style: Theme.of(context).textTheme.titleMedium,
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
                          isCustomer: true,
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
      floatingActionButton: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            // MaterialPageRoute(builder: (context) => const PendingLessonsPage()), TODO
            MaterialPageRoute(builder: (context) => Scaffold(appBar: AppBar(title: const Text('Lesson Requests')))),
          );
        },
        child: const Text('View Lesson Requests'),
      ),
    );
  }
}
