import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.contactUs),
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Support Email: support@darrisni.com", // TODO: localize
              style: theme.textTheme.bodyLarge,
            ),
            const Gap(10),
            ElevatedButton(
              onPressed: () async {
                final Uri emailUri = Uri(
                  scheme: 'mailto',
                  path: 'support@darrisni.com',
                );
                if (await canLaunchUrl(emailUri)) {
                  await launchUrl(emailUri);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not open email app.')), // TODO: localize
                  );
                }
              },
              child: const Text("Send Email"), // TODO: localize
            ),
            const Gap(20),
            Text(
              "WhatsApp Business: +972528800120",
              style: theme.textTheme.bodyLarge,
            ),
            const Gap(10),
            ElevatedButton(
              onPressed: () async {
                final Uri whatsappUri = Uri.parse("https://wa.me/+972528800120");
                if (await canLaunchUrl(whatsappUri)) {
                  await launchUrl(whatsappUri);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not open WhatsApp.')), // TODO: localize
                  );
                }
              },
              child: const Text("Message on WhatsApp"), // TODO: localize
            ),
            const Gap(20),
            const Text(
              "Business Physical Address:\nקורטבה 11, קלנסווה, ישראל,\nת.ד. 694, מיקוד 4064000", // TODO: localize
              style: TextStyle(fontSize: 16),
            ),
            const Gap(10),
            // line separator
            const Divider(
              color: Colors.grey,
              thickness: 1,
            ),
            const Gap(10),
            const Text(
              "To delete your account, please contact us via email or WhatsApp.", // TODO: localize
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
