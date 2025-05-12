import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class LegalPage extends StatelessWidget {
  const LegalPage({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Legal Information'),
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildPolicyCard(
              title: 'Privacy Policy',
              icon: Icons.privacy_tip,
              children: [
                _buildSectionHeader('Information We Collect', 'What data we store and why', theme),
                _buildDetailPoint('Account Data', 'Username and phone number for account identification', theme),
                _buildDetailPoint('Authentication', 'Secure session tokens for login management', theme),
                _buildDetailPoint('Lesson Recordings', 'Stored by teachers for 30 days after lesson completion for dispute resolution', theme),
                _buildSectionHeader('Data Security', 'How we protect your information', theme),
                _buildDetailPoint('Encryption', 'All data transmitted via HTTPS with secure session tokens', theme),
                _buildDetailPoint('Payment Processing', 'Handled exclusively by Invoice4u (PCI-DSS compliant)', theme),
                _buildSectionHeader('Your Rights', 'Control over your data', theme),
                _buildDetailPoint('Data Access', 'Request correction/deletion via account settings or support', theme),
                _buildDetailPoint('Opt-Out', 'Unsubscribe from notifications at any time', theme),
              ],
              theme: theme,
            ),
            const Gap(30),
            _buildPolicyCard(
              title: 'Terms of Service',
              icon: Icons.assignment,
              children: [
                _buildSectionHeader('Account Requirements', 'Creating and managing your profile', theme),
                _buildDetailPoint('Registration', 'Valid phone number required for account creation', theme),
                _buildDetailPoint('Minors', 'Users under 18 must have parent-managed accounts', theme),
                _buildSectionHeader('Payments & Refunds', 'Financial agreements', theme),
                _buildDetailPoint('Lesson Bookings', 'Full payment required before scheduling', theme),
                _buildDetailPoint('Dispute Resolution', '48-hour window for teachers to contest refund requests', theme),
                _buildSectionHeader('Content Policy', 'Intellectual property rights', theme),
                _buildDetailPoint('Lesson Materials', 'Teachers retain ownership but grant Darrisni usage rights', theme),
                _buildDetailPoint('Recordings', 'Stored by teachers for 30 days after lesson completion for dispute resolution', theme),
              ],
              theme: theme,
            ),
            const Gap(30),
            _buildPolicyCard(
              title: 'Refund Policy',
              icon: Icons.monetization_on,
              children: [
                _buildDetailPoint('', 'Cancellation of a transaction in accordance with the Consumer Protection Regulations (Transaction Cancellation), התשע"א-2010 and the Consumer Protection Law, התשמ"א-1981', theme),
              ],
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }

  // Keep existing helper methods unchanged
  Widget _buildPolicyCard({required String title, required IconData icon, required List<Widget> children, required ThemeData theme}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: Icon(icon),
        title: Text(title, style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w600)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String main, String sub, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          main,
          style: theme.textTheme.headlineMedium!.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          sub,
          style: theme.textTheme.bodyLarge!.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const Gap(8),
      ],
    );
  }

  Widget _buildDetailPoint(String title, String detail, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const Gap(4),
          Text(
            detail,
            style: theme.textTheme.bodyMedium!.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const Gap(12),
        ],
      ),
    );
  }
}
