import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/orrery_api_service.dart';
import 'screens/chat_screen.dart';

void main() async {
  await dotenv.load();
  
  final apiService = OrreryApiService(
    baseUrl: dotenv.env['ORRERY_API_URL'] ?? 'https://lara.ruiningmediocrity.com',
    apiToken: dotenv.env['ORRERY_API_TOKEN'] ?? '',
  );

  try {
    final health = await apiService.checkHealth();
    print('Server health status: $health');
    
    final personalities = await apiService.getPersonalities();
    print('Available personalities: ${personalities.length}');
  } catch (e) {
    print('Diagnostic check failed: $e');
  }

  runApp(MyApp(apiService: apiService));
}

class MyApp extends StatelessWidget {
  final OrreryApiService apiService;

  const MyApp({
    Key? key,
    required this.apiService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Orrery',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: ChatScreen(apiService: apiService),
    );
  }
}
