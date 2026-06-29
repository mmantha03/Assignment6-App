import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scanlog/providers/journal_provider.dart';
import 'package:scanlog/screens/home_screen.dart';

void main() {
  runApp(const ScanLogApp());
}

class ScanLogApp extends StatelessWidget {
  const ScanLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xff275f63);

    return ChangeNotifierProvider(
      create: (_) => JournalProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ScanLog',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xfff3f0e8),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xfff3f0e8),
            centerTitle: false,
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
