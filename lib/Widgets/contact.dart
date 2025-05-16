import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
              "Support Email: support@darrisni.com",
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
                } else if (context.mounted) {
                  // copy email to clipboard instead
                  Clipboard.setData(const ClipboardData(text: 'support@darrisni.com'));

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.couldntOpenEmail)),
                  );
                }
              },
              child: Text(AppLocalizations.of(context)!.sendEmail),
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
                } else if (context.mounted) {
                  // copy WhatsApp number to clipboard instead
                  Clipboard.setData(const ClipboardData(text: '+972528800120'));

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.couldntOpenWhatsApp)),
                  );
                }
              },
              child: Text(AppLocalizations.of(context)!.messageOnWhatsApp),
            ),
            const Gap(20),
            Text(
              AppLocalizations.of(context)!.businessAddress("קורטבה 11, קלנסווה, ישראל", "ת.ד. 694, מיקוד 4064000"),
              style: const TextStyle(fontSize: 16),
            ),
            const Gap(10),
            // line separator
            const Divider(
              color: Colors.grey,
              thickness: 1,
            ),
            const Gap(10),
            Text(
              AppLocalizations.of(context)!.deleteAccountDescription,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
