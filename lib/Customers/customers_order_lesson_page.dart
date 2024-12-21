import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:supreme_octo_eureka/app_state.dart';
import 'package:supreme_octo_eureka/booking_logic.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OrderLessonPage extends StatefulWidget {
  const OrderLessonPage({super.key});

  @override
  _OrderLessonPageState createState() => _OrderLessonPageState();
}

class _OrderLessonPageState extends State<OrderLessonPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  String _title = '';
  Subject? _subject;
  Grade? _grade;
  DateTime _dateTime = DateTime.now().subtract(Duration(seconds: DateTime.now().second, milliseconds: DateTime.now().millisecond, microseconds: DateTime.now().microsecond)).add(const Duration(minutes: 60));
  int _duration = 60;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  void _onPageChanged(int page) {
    // hide keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      _currentPage = page;
    });
  }

  void _setDetails(String title, Subject? subject, Grade? grade) {
    setState(() {
      _title = title;
      _subject = subject;
      _grade = grade;
    });
  }

  void _setDateTime(DateTime dateTime) {
    setState(() {
      _dateTime = dateTime;
    });
  }

  void _setDuration(int duration) {
    setState(() {
      _duration = duration;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;

        if (_currentPage > 0) {
          _pageController.previousPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.orderLesson),
          automaticallyImplyLeading: true,
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          physics: const NeverScrollableScrollPhysics(),
          children: <Widget>[
            OrderLessonDetailsPage(
              onDetailsSelected: _setDetails,
              nextPage: _nextPage,
              initialTitle: _title,
              initialSubject: _subject,
              initialGrade: _grade,
            ),
            OrderLessonDateTimePage(
              onDateTimeSelected: _setDateTime,
              nextPage: _nextPage,
              initialDateTime: _dateTime,
            ),
            OrderLessonDurationPage(
              onDurationSelected: _setDuration,
              nextPage: _nextPage,
              initialDuration: _duration,
            ),
            OrderLessonConfirmationPage(
              title: _title,
              subject: _subject,
              grade: _grade,
              dateTime: _dateTime,
              duration: _duration,
            ),
          ],
        ),
      ),
    );
  }
}

class OrderLessonDetailsPage extends StatelessWidget {
  final Function(String, Subject?, Grade?) onDetailsSelected;
  final VoidCallback nextPage;
  final String initialTitle;
  final Subject? initialSubject;
  final Grade? initialGrade;

  const OrderLessonDetailsPage({
    super.key,
    required this.onDetailsSelected,
    required this.nextPage,
    this.initialTitle = '',
    this.initialSubject,
    this.initialGrade,
  });

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController(text: initialTitle);
    Subject? subject = initialSubject;
    Grade? grade = initialGrade;
    AppState appState = context.read<AppState>();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: controller,
              maxLines: null,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.title,
                border: const OutlineInputBorder(),
              ),
            ),
            const Gap(16.0),
            DropdownButton<Subject>(
              value: subject,
              hint: Text(AppLocalizations.of(context)!.subjectHint),
              items: Subject.values.skip(1).map((Subject subject) {
                return DropdownMenuItem<Subject>(value: subject, child: Text(subject.name(context)));
              }).toList(),
              onChanged: (Subject? newValue) {
                if (newValue != null) {
                  subject = newValue;
                  onDetailsSelected(controller.text, subject, grade);
                }
              },
            ),
            const Gap(16.0),
            DropdownButton<Grade>(
              value: grade,
              hint: Text(AppLocalizations.of(context)!.gradeHint),
              items: Grade.values.skip(1).map((Grade grade) {
                return DropdownMenuItem<Grade>(value: grade, child: Text(grade.name(context)));
              }).toList(),
              onChanged: (Grade? newValue) {
                if (newValue != null) {
                  grade = newValue;
                  onDetailsSelected(controller.text, subject, grade);
                }
              },
            ),
            const Gap(16.0),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  onDetailsSelected(controller.text, subject, grade);
                  if (controller.text.isNotEmpty && subject != null && grade != null) {
                    nextPage();
                  } else {
                    appState.showErrorSnackBar(AppLocalizations.of(context)!.titleCannotBeEmpty);
                  }
                },
                child: const Icon(Icons.arrow_forward),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderLessonDateTimePage extends StatelessWidget {
  final Function(DateTime) onDateTimeSelected;
  final VoidCallback nextPage;
  final DateTime initialDateTime;

  const OrderLessonDateTimePage({
    super.key,
    required this.onDateTimeSelected,
    required this.nextPage,
    required this.initialDateTime,
  });

  @override
  Widget build(BuildContext context) {
    DateTime selectedDateTime = initialDateTime;
    AppState appState = context.read<AppState>();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            OmniDateTimePicker(
              firstDate: DateTime.now().subtract(Duration(seconds: DateTime.now().second, milliseconds: DateTime.now().millisecond, microseconds: DateTime.now().microsecond)).add(const Duration(minutes: 30)),
              initialDate: initialDateTime,
              onDateTimeChanged: (DateTime dateTime) {
                selectedDateTime = dateTime;
              },
            ),
            const Gap(16.0),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  onDateTimeSelected(selectedDateTime);
                  if (selectedDateTime.isAfter(DateTime.now().add(const Duration(minutes: 30)))) {
                    nextPage();
                  } else {
                    // appState.showErrorSnackBar('Date and time must be more than {30} minutes in the future');
                    appState.showErrorSnackBar(AppLocalizations.of(context)!.dateTimeMustBeInTheFuture(30));
                  }
                },
                child: const Icon(Icons.arrow_forward),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderLessonDurationPage extends StatelessWidget {
  final Function(int) onDurationSelected;
  final VoidCallback nextPage;
  final int initialDuration;

  const OrderLessonDurationPage({
    super.key,
    required this.onDurationSelected,
    required this.nextPage,
    this.initialDuration = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(AppLocalizations.of(context)!.selectDuration),
            const SizedBox(height: 16),
            DropdownButton<int>(
              value: initialDuration,
              items: [
                DropdownMenuItem(value: 30, child: Text(AppLocalizations.of(context)!.minutes(30))),
                DropdownMenuItem(value: 60, child: Text(AppLocalizations.of(context)!.hours(1))),
                DropdownMenuItem(value: 90, child: Text(AppLocalizations.of(context)!.hours(1.5))),
                DropdownMenuItem(value: 120, child: Text(AppLocalizations.of(context)!.hours(2))),
                DropdownMenuItem(value: 180, child: Text(AppLocalizations.of(context)!.hours(3))),
              ],
              onChanged: (int? newValue) {
                if (newValue != null) {
                  onDurationSelected(newValue);
                }
              },
            ),
            const Gap(16),
            ElevatedButton(
              onPressed: () {
                nextPage();
              },
              child: const Icon(Icons.arrow_forward),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderLessonConfirmationPage extends StatelessWidget {
  final String title;
  final Subject? subject;
  final Grade? grade;
  final DateTime dateTime;
  final int duration;

  const OrderLessonConfirmationPage({
    super.key,
    required this.title,
    required this.subject,
    required this.grade,
    required this.dateTime,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IntrinsicWidth(
              child: Card.outlined(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.topic),
                          const Gap(8),
                          Text(title),
                        ],
                      ),
                      const Gap(16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.subject),
                          const Gap(8),
                          Text(subject!.name(context)),
                        ],
                      ),
                      const Gap(16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.school),
                          const Gap(8),
                          Text(grade!.name(context)),
                        ],
                      ),
                      const Gap(16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.calendar_today),
                          const Gap(8),
                          Text('${dateTime.day}/${dateTime.month} ${dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.hour >= 12 ? 'PM' : 'AM'}'),
                        ],
                      ),
                      const Gap(16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.access_time),
                          const Gap(8),
                          if (duration >= 60) Text('${(duration / 60).toStringAsFixed((duration % 60 == 0) ? 0 : 1)} hours') else Text(AppLocalizations.of(context)!.minutes(duration)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Gap(16),
            ElevatedButton(
              onPressed: () async {
                AppState appState = context.read<AppState>();
                Lesson lesson = Lesson(
                  orderID: 0,
                  studentID: appState.currentCustomer!.id,
                  studentName: appState.currentCustomer!.username,
                  studentPhone: appState.currentCustomer!.phone,
                  teacherID: 0,
                  teacherName: '',
                  teacherPhone: '',
                  title: title,
                  subject: subject!,
                  grade: grade!,
                  startTimestamp: dateTime.millisecondsSinceEpoch ~/ 1000,
                  durationMinutes: duration,
                  isPending: true,
                  link: '',
                );
                String? success = await createOrderRequest(lesson, appState);
                if (success != null) {
                  if (context.mounted) {
                    Navigator.of(context)
                      ..pop()
                      ..push(MaterialPageRoute(builder: (context) => OrderLessonPaymentPage(lesson: lesson)));
                  }
                }
              },
              child: Text(AppLocalizations.of(context)!.confirmAndPay),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderLessonPaymentPage extends StatelessWidget {
  final Lesson lesson;

  const OrderLessonPaymentPage({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    AppState appState = context.read<AppState>();

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        appState.showAlertDialog(
          content: Text(AppLocalizations.of(context)!.confirmLeavePaymentPage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context)
                  ..pop()
                  ..pop();
              },
              child: Text(AppLocalizations.of(context)!.leave),
            ),
          ],
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Payment'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Payment Page for ${lesson.title}, id: ${lesson.orderID}'),
              ElevatedButton(
                onPressed: () async {
                  if (await confirmOrder(lesson, appState) && context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Confirm Payment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
