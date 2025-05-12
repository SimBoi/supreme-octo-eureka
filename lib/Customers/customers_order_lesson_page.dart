import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:supreme_octo_eureka/Widgets/legal.dart';
import 'package:supreme_octo_eureka/app_state.dart';
import 'package:supreme_octo_eureka/authentication/auth_logic.dart';
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
  final int _pagesCount = 5;

  final TextEditingController _titleController = TextEditingController(text: '');
  Subject? _subject;
  Grade? _grade;
  bool _isImmediate = false;
  DateTime _dateTime = DateTime.now().subtract(Duration(seconds: DateTime.now().second, milliseconds: DateTime.now().millisecond, microseconds: DateTime.now().microsecond)).add(const Duration(minutes: 60));
  int _duration = 60;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _animateToPage(int offset) {
    int newPage = _currentPage + offset;
    if (newPage >= 0 && newPage < _pagesCount) {
      _pageController.animateToPage(
        newPage,
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

  void _setDetails(Subject? subject, Grade? grade) {
    setState(() {
      _subject = subject;
      _grade = grade;
    });
  }

  void _setType(bool isImmediate) {
    setState(() {
      _isImmediate = isImmediate;
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

        if (_currentPage == 3) {
          // if currently on duration page then go back to type page
          _pageController.animateToPage(
            1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else if (_currentPage > 0) {
          // otherwise go back 1 page
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
              animateToPage: _animateToPage,
              titleController: _titleController,
              initialSubject: _subject,
              initialGrade: _grade,
            ),
            OrderLessonTypePage(
              onTypeSelected: _setType,
              animateToPage: _animateToPage,
            ),
            OrderLessonDateTimePage(
              onDateTimeSelected: _setDateTime,
              animateToPage: _animateToPage,
              initialDateTime: _dateTime,
            ),
            OrderLessonDurationPage(
              onDurationSelected: _setDuration,
              animateToPage: _animateToPage,
              initialDuration: _duration,
            ),
            OrderLessonConfirmationPage(
              title: _titleController.text,
              subject: _subject,
              grade: _grade,
              isImmediate: _isImmediate,
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
  final Function(Subject?, Grade?) onDetailsSelected;
  final Function(int offset) animateToPage;
  final TextEditingController? titleController;
  final Subject? initialSubject;
  final Grade? initialGrade;

  const OrderLessonDetailsPage({
    super.key,
    required this.onDetailsSelected,
    required this.animateToPage,
    this.titleController,
    this.initialSubject,
    this.initialGrade,
  });

  @override
  Widget build(BuildContext context) {
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
              controller: titleController,
              // only allow letters, numbers, spaces and punctuation. TODO: remove this restriction
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\p{L}0-9 .,!?]', unicode: true)),
              ],
              maxLines: null,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.title,
                border: const OutlineInputBorder(),
              ),
            ),
            const Gap(16.0),
            DropdownMenu<Subject>(
              initialSelection: subject,
              hintText: AppLocalizations.of(context)!.subjectHint,
              onSelected: (Subject? newValue) {
                if (newValue != null) {
                  subject = newValue;
                  onDetailsSelected(subject, grade);
                }
              },
              dropdownMenuEntries: Subject.values.skip(1).map((Subject subject) {
                return DropdownMenuEntry<Subject>(
                  value: subject,
                  label: subject.name(context),
                );
              }).toList(),
            ),
            const Gap(16.0),
            DropdownMenu<Grade>(
              initialSelection: grade,
              hintText: AppLocalizations.of(context)!.gradeHint,
              onSelected: (Grade? newValue) {
                if (newValue != null) {
                  grade = newValue;
                  onDetailsSelected(subject, grade);
                }
              },
              dropdownMenuEntries: Grade.values.skip(1).map((Grade grade) {
                return DropdownMenuEntry<Grade>(
                  value: grade,
                  label: grade.name(context),
                );
              }).toList(),
            ),
            const Gap(16.0),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  onDetailsSelected(subject, grade);
                  if (titleController!.text.isNotEmpty && subject != null && grade != null) {
                    animateToPage(1);
                  } else {
                    appState.showErrorSnackBar(AppLocalizations.of(context)!.titleCannotBeEmpty);
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(AppLocalizations.of(context)!.next),
                    const Gap(8.0),
                    const Icon(Icons.arrow_forward),
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

// a page with two buttons: one for immediate lessons that navigates to the duration page and one for scheduled lessons that navigates to the date time page
class OrderLessonTypePage extends StatelessWidget {
  final Function(bool isImmediate) onTypeSelected;
  final Function(int offset) animateToPage;

  const OrderLessonTypePage({
    super.key,
    required this.onTypeSelected,
    required this.animateToPage,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Text(AppLocalizations.of(context)!.orderLessonType), // TODO: localize
            const Text("Please select the type of lesson you want to order"),
            const Gap(16.0),
            ElevatedButton(
              onPressed: () {
                onTypeSelected(true);
                animateToPage(2);
              },
              // child: Text(AppLocalizations.of(context)!.immediateLesson), // TODO: localize
              child: const Text("Get a lesson right now"),
            ),
            const Gap(16.0),
            ElevatedButton(
              onPressed: () {
                onTypeSelected(false);
                animateToPage(1);
              },
              // child: Text(AppLocalizations.of(context)!.scheduledLesson), // TODO: localize
              child: const Text("Schedule a lesson for a later time (Recommended)"),
            ),
          ],
        ),
      ),
    );
  }
}

// TODO: dont allow times between 00:00 and 08:00
class OrderLessonDateTimePage extends StatelessWidget {
  final Function(DateTime) onDateTimeSelected;
  final Function(int offset) animateToPage;
  final DateTime initialDateTime;

  const OrderLessonDateTimePage({
    super.key,
    required this.onDateTimeSelected,
    required this.animateToPage,
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
              initialDate: initialDateTime,
              firstDate: DateTime.now().subtract(Duration(seconds: DateTime.now().second, milliseconds: DateTime.now().millisecond, microseconds: DateTime.now().microsecond)).add(const Duration(minutes: 30)),
              onDateTimeChanged: (DateTime dateTime) {
                selectedDateTime = dateTime;
              },
              minutesInterval: 5,
              is24HourMode: true,
            ),
            const Gap(16.0),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  onDateTimeSelected(selectedDateTime);
                  if (selectedDateTime.isAfter(DateTime.now().add(const Duration(minutes: 18)))) {
                    animateToPage(1);
                  } else {
                    appState.showErrorSnackBar(AppLocalizations.of(context)!.dateTimeMustBeInTheFuture(20));
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(AppLocalizations.of(context)!.next),
                    const Gap(8.0),
                    const Icon(Icons.arrow_forward),
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

class OrderLessonDurationPage extends StatelessWidget {
  final Function(int) onDurationSelected;
  final Function(int offset) animateToPage;
  final int initialDuration;

  const OrderLessonDurationPage({
    super.key,
    required this.onDurationSelected,
    required this.animateToPage,
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
            DropdownMenu<int>(
              initialSelection: initialDuration,
              hintText: AppLocalizations.of(context)!.selectDuration,
              onSelected: (int? newValue) {
                if (newValue != null) {
                  onDurationSelected(newValue);
                }
              },
              dropdownMenuEntries: [
                DropdownMenuEntry<int>(value: 15, label: AppLocalizations.of(context)!.minutes(15)),
                DropdownMenuEntry<int>(value: 30, label: AppLocalizations.of(context)!.minutes(30)),
                DropdownMenuEntry<int>(value: 45, label: AppLocalizations.of(context)!.minutes(45)),
                DropdownMenuEntry<int>(value: 60, label: AppLocalizations.of(context)!.hours(1)),
                DropdownMenuEntry<int>(value: 90, label: AppLocalizations.of(context)!.hours(1.5)),
                DropdownMenuEntry<int>(value: 120, label: AppLocalizations.of(context)!.hours(2)),
                DropdownMenuEntry<int>(value: 180, label: AppLocalizations.of(context)!.hours(3)),
              ],
            ),
            const Gap(16),
            ElevatedButton(
              onPressed: () {
                animateToPage(1);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppLocalizations.of(context)!.next),
                  const Gap(8.0),
                  const Icon(Icons.arrow_forward),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderLessonConfirmationPage extends StatefulWidget {
  final String title;
  final Subject? subject;
  final Grade? grade;
  final bool isImmediate;
  final DateTime dateTime;
  final int duration;

  const OrderLessonConfirmationPage({
    super.key,
    required this.title,
    required this.subject,
    required this.grade,
    required this.isImmediate,
    required this.dateTime,
    required this.duration,
  });

  @override
  State<OrderLessonConfirmationPage> createState() => _OrderLessonConfirmationPageState();
}

class _OrderLessonConfirmationPageState extends State<OrderLessonConfirmationPage> {
  final TextEditingController couponController = TextEditingController();
  double? newPrice;

  @override
  void dispose() {
    couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppState appState = context.read<AppState>();
    ThemeData theme = Theme.of(context);
    double originalPrice = appState.getLessonPrice(widget.duration);
    double displayPrice = newPrice ?? originalPrice;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Order Summary Card
            Card.outlined(
              shape: RoundedRectangleBorder(
                side: BorderSide(color: theme.colorScheme.onSurface),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.orderSummary,
                      style: theme.textTheme.headlineMedium,
                    ),
                    const Gap(16),
                    Row(
                      children: [
                        const Icon(Icons.topic),
                        const Gap(8),
                        Text(widget.title),
                      ],
                    ),
                    const Gap(16),
                    Row(
                      children: [
                        const Icon(Icons.subject),
                        const Gap(8),
                        Text(widget.subject!.name(context)),
                      ],
                    ),
                    const Gap(16),
                    Row(
                      children: [
                        const Icon(Icons.school),
                        const Gap(8),
                        Text(widget.grade!.name(context)),
                      ],
                    ),
                    const Gap(16),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today),
                        const Gap(8),
                        widget.isImmediate ? const Text("Live Lesson") : Text(Lesson.getDateTimeString(context, widget.dateTime.millisecondsSinceEpoch ~/ 1000)), // TODO: localize
                      ],
                    ),
                    const Gap(16),
                    Row(
                      children: [
                        const Icon(Icons.access_time),
                        const Gap(8),
                        Text(Lesson.getDurationString(context, widget.duration)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Gap(16),
            // Coupon Code Card
            Card.outlined(
              shape: RoundedRectangleBorder(
                side: BorderSide(color: theme.colorScheme.onSurface),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.discount),
                        const Gap(8),
                        // Coupon code text field linked to a controller
                        Expanded(
                          child: TextField(
                            controller: couponController,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[\p{L}0-9]', unicode: true)),
                            ],
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.couponCode,
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const Gap(8),
                        ElevatedButton(
                          onPressed: () async {
                            // Read coupon code from the text field
                            String couponCode = couponController.text;
                            double updatedPrice = await testCoupon(couponCode, originalPrice, appState);
                            setState(() {
                              newPrice = updatedPrice < 0 ? null : updatedPrice;
                            });
                          },
                          child: Text(AppLocalizations.of(context)!.apply),
                        ),
                      ],
                    ),
                    const Gap(8),
                    const Divider(),
                    const Gap(8),
                    Row(
                      children: [
                        const Icon(Icons.monetization_on),
                        const Gap(8),
                        if (newPrice != null) ...[
                          Text(
                            '$originalPrice₪',
                            style: TextStyle(
                              decoration: TextDecoration.lineThrough,
                              decorationColor: theme.colorScheme.error,
                              decorationThickness: 2,
                              color: theme.colorScheme.error,
                            ),
                          ),
                          const Gap(8),
                        ] else
                          ...[],
                        Text('$displayPrice₪'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Gap(16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(AppLocalizations.of(context)!.agreeRefundPolicy1),
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LegalPage()),
                    );
                  },
                  child: Text(
                    AppLocalizations.of(context)!.agreeRefundPolicy2,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(16),
            ElevatedButton(
              onPressed: () async {
                Lesson lesson = Lesson(
                  orderID: 0,
                  studentID: appState.currentCustomer!.id,
                  studentName: appState.currentCustomer!.username,
                  studentPhone: appState.currentCustomer!.phone,
                  teacherID: 0,
                  teacherName: '',
                  teacherPhone: '',
                  title: widget.title,
                  subject: widget.subject!,
                  grade: widget.grade!,
                  isImmediate: widget.isImmediate,
                  startTimestamp: widget.dateTime.millisecondsSinceEpoch ~/ 1000,
                  durationMinutes: widget.duration,
                  isPending: true,
                  link: '',
                );
                String? success = await createOrderRequest(
                    lesson,
                    couponController.text, // TODO: use last applied coupon
                    appState);
                if (success != null) {
                  if (context.mounted) {
                    Navigator.of(context)
                      ..pop()
                      ..push(MaterialPageRoute(builder: (context) => OrderLessonPaymentPage(lesson: lesson)));
                  }
                }
              },
              child: Text(AppLocalizations.of(context)!.confirmAndPay), // TODO: change text back to "Confirm and proceed to payment"
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
        if (didPop) {
          Future.delayed(Duration.zero, () {
            login(appState.currentCustomer!.phone, appState.currentCustomer!.password, appState);
          });
          return;
        }

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
              Text('Lesson: ${lesson.title}, id: ${lesson.orderID}, After confirming, a teacher will be assigned to you and will contact you via WhatsApp.'),
              ElevatedButton(
                onPressed: () async {
                  if (await confirmOrder(lesson, appState) && context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Confirm and send order'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
