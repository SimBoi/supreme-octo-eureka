import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:supreme_octo_eureka/Customers/customers_edit_profile_page.dart';
import 'package:supreme_octo_eureka/Customers/customers_order_lesson_page.dart';
import 'package:flutter/material.dart';
import 'package:supreme_octo_eureka/Widgets/lesson_card.dart';
import 'package:supreme_octo_eureka/app_state.dart';

class CustomersRoot extends StatelessWidget {
  const CustomersRoot({super.key});

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
                  'My Lessons',
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
                      MaterialPageRoute(builder: (context) => EditCustomerProfilePage()),
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
                        'You can view and manage your ordered lessons on this page. Tap the button at the bottom right to order a new lesson.',
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
            Selector<
                AppState,
                ({
                  int version,
                  List<Lesson> appointments
                })>(
              selector: (_, appState) => (
                version: appState.lessonsListVersion,
                appointments: appState.currentCustomer!.currentAppointments
              ),
              builder: (context, data, _) {
                if (data.appointments.isEmpty) {
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
                  children: data.appointments.map((lesson) {
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OrderLessonPage()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Order Lesson'),
      ),
    );
  }
}
