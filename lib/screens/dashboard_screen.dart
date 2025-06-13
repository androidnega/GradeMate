import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/semester_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../widgets/semester_tile.dart';
import '../controllers/app_state.dart';
import 'auth/login_screen.dart';
import 'add_semester_screen.dart';
import 'cgpa_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Stream<List<SemesterModel>> _semestersStream;

  @override
  void initState() {
    super.initState();
    _semestersStream = FirestoreService.semestersStream(
      AuthService.currentUser!.uid,
    );
  }

  Future<void> _signOut() async {
    try {
      // Use AppState to handle logout
      await Provider.of<AppState>(context, listen: false).signOut();

      if (mounted) {
        // Clear navigation stack and go to login
        await Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GradeMate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calculate),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CGPAScreen()),
              );
            },
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: _signOut),
        ],
      ),
      body: StreamBuilder<List<SemesterModel>>(
        stream: _semestersStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final semesters = snapshot.data ?? [];

          if (semesters.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No semesters yet',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add your first semester',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: semesters.length,
            itemBuilder:
                (context, index) => SemesterTile(semester: semesters[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddSemesterScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
