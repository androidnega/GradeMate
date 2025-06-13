import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/about_service.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("About GradeMate")),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: AboutService.fetchAboutData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Default values if Firestore data isn't available
          final data = snapshot.data ?? {
            'appName': 'GradeMate',
            'version': '1.0.0',
            'description': 'GradeMate is a GPA/CGPA/CWA calculator made for TTU students to track and classify their academic performance with ease.',
            'developer': 'Manuel – BTech I.T (Computer Science), Takoradi Technical University',
            'github': 'https://github.com/androidnega',
            'email': 'grademate@manuelcode.info',
            'whatsapp': 'https://wa.me/233541069241',
          };

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Column(
                children: [
                  Icon(Icons.school, size: 60, color: Theme.of(context).primaryColor),
                  const SizedBox(height: 12),
                  Text(
                    data['appName'],
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Version ${data['version']}", 
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              const Divider(height: 32),
              const Text(
                "About the App", 
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(data['description']),
              const SizedBox(height: 24),
              const Text(
                "Developer", 
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(data['developer']),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.code),
                title: const Text("GitHub"),
                subtitle: Text(data['github']),
                onTap: () async {
                  final url = Uri.parse(data['github']);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text("Email"),
                subtitle: Text(data['email']),
                onTap: () async {
                  final url = Uri.parse("mailto:${data['email']}?subject=GradeMate%20Feedback");
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.chat),
                title: const Text("WhatsApp"),
                subtitle: const Text("+233 541069241"),
                onTap: () async {
                  final url = Uri.parse(data['whatsapp']);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
              ),              const Divider(height: 32),
              const Text(
                "Preferences", 
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) {
                  return SwitchListTile(
                    title: const Text("Dark Mode"),
                    value: themeProvider.themeMode == ThemeMode.dark,
                    onChanged: (value) {
                      themeProvider.toggleTheme(value);
                    },
                    secondary: const Icon(Icons.dark_mode),
                  );
                },
              ),
              const Divider(height: 32),
              const Text(
                "More", 
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.star_rate),
                title: const Text("Rate this app"),
                onTap: () async {
                  const url = "https://manuelcode.info/rate"; // Replace with Play Store link later
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text("Share with a friend"),
                onTap: () {
                  Share.share(
                    "🎓 Hey! Check out GradeMate – a smart CGPA/GPA/CWA calculator built for TTU students. Try it now: https://manuelcode.info",
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.feedback_outlined),
                title: const Text("Send Feedback"),
                onTap: () async {
                  final subject = Uri.encodeComponent("GradeMate Feedback");
                  final body = Uri.encodeComponent(
                    "Hello Manuel,\n\nI'd like to share the following feedback:\n\n"
                  );
                  final mailUrl = Uri.parse(
                    "mailto:${data['email']}?subject=$subject&body=$body"
                  );

                  if (await canLaunchUrl(mailUrl)) {
                    await launchUrl(mailUrl);
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Unable to open email client.")),
                      );
                    }
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
