import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:supreme_octo_eureka/Teachers/teachers_edit_profile_page.dart';
import 'package:supreme_octo_eureka/Teachers/teachers_pending_lessons_page.dart';
import 'package:supreme_octo_eureka/Widgets/lesson_card.dart';
import 'package:supreme_octo_eureka/app_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:supreme_octo_eureka/authentication/auth_logic.dart';

class TeachersRoot extends StatefulWidget {
  const TeachersRoot({super.key});

  @override
  State<TeachersRoot> createState() => _TeachersRootState();
}

class _TeachersRootState extends State<TeachersRoot> {
  @override
  Widget build(BuildContext context) {
    var appState = context.read<AppState>();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: RefreshIndicator(
          onRefresh: () async {
            await login(appState.currentTeacher!.phone, appState.currentTeacher!.password, appState);
            setState(() {});
          },
          child: ListView(
            children: <Widget>[
              const Gap(32),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.mySchedule,
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
                          AppLocalizations.of(context)!.myScheduleDescription,
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
              Selector<
                  AppState,
                  ({
                    int version,
                    List<Lesson> appointments
                  })>(
                selector: (_, appState) => (
                  version: appState.lessonsListVersion,
                  appointments: appState.currentTeacher!.currentAppointments
                ),
                builder: (context, data, _) {
                  if (data.appointments.isEmpty) {
                    return Column(
                      children: [
                        const Gap(16),
                        Center(
                          child: Text(
                            AppLocalizations.of(context)!.noLessons,
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
                    children: data.appointments.map((lesson) {
                      return Column(
                        children: [
                          LessonCard(
                            lesson: lesson,
                            isCustomer: false,
                            viewOnly: false,
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PendingLessonsPage()),
          );
        },
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.of(context)!.acceptLessons),
      ),
    );
  }
}
