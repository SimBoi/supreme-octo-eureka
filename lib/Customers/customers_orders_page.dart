import 'package:supreme_octo_eureka/app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supreme_octo_eureka/authentication/auth_logic.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CustomerOrdersPage extends StatefulWidget {
  const CustomerOrdersPage({super.key});

  @override
  State<CustomerOrdersPage> createState() => _CustomerOrdersPageState();
}

class _CustomerOrdersPageState extends State<CustomerOrdersPage> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.myOrders),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: RefreshIndicator(
          onRefresh: () async {
            await login(appState.currentCustomer!.phone, appState.currentCustomer!.password, appState);
            setState(() {});
          },
          child: ListView.builder(
            itemCount: appState.currentCustomer!.orders.length,
            itemBuilder: (context, index) {
              var order = appState.currentCustomer!.orders[appState.currentCustomer!.orders.length - 1 - index];
              return Card(
                child: ListTile(
                  title: Text(AppLocalizations.of(context)!.orderId(order.id)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(AppLocalizations.of(context)!.dateTime(Lesson.getDateTimeString(context, order.orderTimestamp))),
                      Text(AppLocalizations.of(context)!.lessonDurationDateTime(
                        order.isImmediate ? "Live" : Lesson.getDateTimeString(context, order.lessonTimestamp),
                        order.durationMinutes,
                      )),
                      Text(AppLocalizations.of(context)!.price(order.price)),
                      // 0 = paayment failed, 1 = processing payment, 2 = paid, 3 = pending refund, 4 = processing refund, 5 = refunded
                      if (order.status == 0) ...[
                        Text(AppLocalizations.of(context)!.statusPaymentFailed),
                      ] else if (order.status == 1) ...[
                        Text(AppLocalizations.of(context)!.statusProcessingPayment),
                      ] else if (order.status == 2) ...[
                        Text(AppLocalizations.of(context)!.statusPaid),
                      ] else if (order.status == 3) ...[
                        Text(AppLocalizations.of(context)!.statusPendingRefund),
                      ] else if (order.status == 4) ...[
                        Text(AppLocalizations.of(context)!.statusProcessingRefund),
                      ] else if (order.status == 5) ...[
                        Text(AppLocalizations.of(context)!.statusRefunded),
                      ],
                    ],
                  ),
                  isThreeLine: true,
                  onTap: () {
                    // TODO: retry payment or request refund
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
