import 'package:flutter/material.dart';
import 'package:usewise_flutter/usewise_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Usewise.init(const UsewiseConfig(
    apiKey: 'uw_live_your_api_key_here',
    baseUrl: 'http://localhost:3705/api/v1',
    enableLogging: true,
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Usewise Example',
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _processId;

  @override
  void initState() {
    super.initState();
    Usewise.instance.track('app_opened');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Usewise Demo')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Anonymous ID: ${Usewise.instance.anonymousId}'),
            if (Usewise.instance.userId != null)
              Text('User ID: ${Usewise.instance.userId}'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Usewise.instance.track('button_click', properties: {
                  'button': 'test',
                  'timestamp': DateTime.now().toIso8601String(),
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Event tracked!')),
                );
              },
              child: const Text('Track Event'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                await Usewise.instance.identify('user_123', traits: {
                  'name': 'Test User',
                  'plan': 'pro',
                });
                setState(() {});
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User identified!')),
                  );
                }
              },
              child: const Text('Identify User'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final id = await Usewise.instance.startProcess('onboarding');
                setState(() => _processId = id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Process started: $id')),
                  );
                }
              },
              child: const Text('Start Process'),
            ),
            if (_processId != null) ...[
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  await Usewise.instance.processStep(_processId!, 'step_1');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Step recorded!')),
                    );
                  }
                },
                child: const Text('Record Step'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  await Usewise.instance.completeProcess(_processId!);
                  setState(() => _processId = null);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Process completed!')),
                    );
                  }
                },
                child: const Text('Complete Process'),
              ),
            ],
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                await Usewise.instance.flush();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Queue flushed!')),
                  );
                }
              },
              child: const Text('Flush Queue'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () async {
                await Usewise.instance.reset();
                setState(() => _processId = null);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reset! New anonymous ID generated.')),
                  );
                }
              },
              child: const Text('Reset (Logout)'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    Usewise.instance.shutdown();
    super.dispose();
  }
}
