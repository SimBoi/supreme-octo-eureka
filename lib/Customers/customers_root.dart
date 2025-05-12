import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:supreme_octo_eureka/Customers/customers_edit_profile_page.dart';
import 'package:supreme_octo_eureka/Customers/customers_orders_page.dart';
import 'package:supreme_octo_eureka/Customers/customers_order_lesson_page.dart';
import 'package:flutter/material.dart';
import 'package:supreme_octo_eureka/Widgets/lesson_card.dart';
import 'package:supreme_octo_eureka/app_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:supreme_octo_eureka/authentication/auth_logic.dart';

class CustomersRoot extends StatefulWidget {
  const CustomersRoot({super.key});

  @override
  State<CustomersRoot> createState() => _CustomersRootState();
}

class _CustomersRootState extends State<CustomersRoot> {
  @override
  Widget build(BuildContext context) {
    var appState = context.read<AppState>();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: RefreshIndicator(
          onRefresh: () async {
            await login(appState.currentCustomer!.phone, appState.currentCustomer!.password, appState);
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
                    AppLocalizations.of(context)!.darrisni,
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
                          AppLocalizations.of(context)!.myLessonsDescription,
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
              const Divider(),
              const Gap(16),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CustomerOrdersPage()),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.ordersHistory,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Icon(Icons.arrow_forward),
                  ],
                ),
              ),
              const Gap(16),
              const Divider(),
              const Gap(16),
              Text(
                AppLocalizations.of(context)!.myLessons,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Gap(16),
              Selector<AppState, int>(
                selector: (_, appState) => appState.lessonsListVersion,
                builder: (context, version, _) {
                  List<Lesson> appointments = appState.currentCustomer!.currentAppointments;
                  if (appointments.isEmpty) {
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
                    children: appointments.map((lesson) {
                      return Column(
                        children: [
                          LessonCard(
                            lesson: lesson,
                            isCustomer: true,
                            viewOnly: false,
                          ),
                          const Gap(16),
                        ],
                      );
                    }).toList(),
                  );
                },
              ),
              const Gap(30),
            ],
          ),
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
        label: Text(AppLocalizations.of(context)!.orderLesson),
      ),
    );
  }
}
