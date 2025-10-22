import 'package:flutter/material.dart';
import 'ui/screens/folders_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CardOrganizerApp());
}

class CardOrganizerApp extends StatelessWidget {
  const CardOrganizerApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Card Organizer',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent), useMaterial3: true),
      home: const FoldersScreen(),
    );
  }
}
