import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'auth/login_screen.dart';
import 'gpa_calculator_screen.dart';
import 'about_screen.dart';

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final bool isPrimary;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color:
          isPrimary
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      isPrimary
                          ? colorScheme.primary
                          : colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color:
                      isPrimary
                          ? colorScheme.onPrimary
                          : colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withAlpha(178),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color:
                    isPrimary
                        ? colorScheme.onPrimaryContainer.withAlpha(204)
                        : colorScheme.onSurfaceVariant.withAlpha(204),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Logo and Title
              Icon(
                Icons.school_rounded,
                size: 80,
                color: colorScheme.primary,
              ).animate().fadeIn(duration: 600.ms).scale(),
              const SizedBox(height: 24),
              Text(
                'GradeMate',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn().slideY(begin: 0.3, duration: 500.ms),
              const SizedBox(height: 8),
              Text(
                'Your Academic Success Companion',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn().slideY(begin: 0.3, delay: 200.ms),
              const Spacer(),

              // Main Actions
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ActionButton(
                    icon: Icons.calculate_rounded,
                    label: 'Quick Calculator',
                    subtitle: 'Calculate GPA without signing in',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => const GpaCalculatorScreen(isGuest: true),
                        ),
                      );
                    },
                    isPrimary: true,
                  ).animate(delay: 400.ms).fadeIn().slideX(begin: -0.3),
                  const SizedBox(height: 12),
                  _ActionButton(
                    icon: Icons.person_rounded,
                    label: 'Sign In',
                    subtitle: 'Access all features with your account',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                  ).animate(delay: 600.ms).fadeIn().slideX(begin: 0.3),
                  const SizedBox(height: 12),
                  _ActionButton(
                    icon: Icons.info_outline_rounded,
                    label: 'About GradeMate',
                    subtitle: 'Learn more about the app',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AboutScreen()),
                      );
                    },
                  ).animate(delay: 800.ms).fadeIn().slideX(begin: -0.3),
                ],
              ).animate().fadeIn().scale(
                duration: 400.ms,
                curve: Curves.easeOut,
              ),
              const Spacer(),
              // Footer text
              Text(
                'Made with ❤️ for TTU Students',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 1000.ms),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
