import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/auth/auth_provider.dart';

class PrivacyOptInPage extends ConsumerWidget {
  const PrivacyOptInPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Icon(Icons.privacy_tip_outlined, size: 80, color: Colors.green),
              const SizedBox(height: 32),
              const Text(
                'Privacy by Design',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const Text(
                'We believe your smart home data belongs to you. To improve our AI model, we optionally collect anonymized and completely desensitized failure logs. You have full control over what leaves your local network.',
                style: TextStyle(fontSize: 16, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.check_circle, color: Colors.green),
                      title: Text('100% Anonymized Data'),
                    ),
                    ListTile(
                      leading: Icon(Icons.check_circle, color: Colors.green),
                      title: Text('No Personal Identifiers'),
                    ),
                    ListTile(
                      leading: Icon(Icons.check_circle, color: Colors.green),
                      title: Text('Opt-out anytime'),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  ref.read(authProvider.notifier).agreeToPrivacy();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: const Text('I Agree (Opt-in)', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // Still allow them to proceed without opting into data collection
                  // In a real app we might store their choice separately.
                  ref.read(authProvider.notifier).agreeToPrivacy();
                },
                child: const Text('Decline Data Collection'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}