import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:notes/firebase_options.dart';
import 'package:notes/screens/note_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    await FlutterConfig.loadEnvVariables();
  }
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? isDarkMode = prefs.getBool('isDarkMode');
  runApp(MyApp(isDarkMode: isDarkMode ?? false));
}

class MyApp extends StatefulWidget {
  final bool isDarkMode;
  const MyApp({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
  }

  void _toggleTheme(bool value) async {
    setState(() {
      _isDarkMode = value;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', value);
  }

  ThemeData _buildLightTheme() {
    final base = ThemeData.light();
    return base.copyWith(
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.deepPurple,
        accentColor: Colors.orange,
      ),
      primaryColor: Colors.deepPurple,
      scaffoldBackgroundColor: Colors.white,
      cardColor: Colors.white, // Mengubah warna card menjadi ungu muda
      textTheme: _buildTextTheme(base.textTheme, Colors.black),
      iconTheme: IconThemeData(color: Colors.deepPurple),
      buttonTheme: ButtonThemeData(buttonColor: Colors.deepPurple),
    );
  }

  ThemeData _buildDarkTheme() {
    final base = ThemeData.dark();
    return base.copyWith(
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.deepPurple,
        accentColor: Colors.orange,
        brightness: Brightness.dark,
      ),
      primaryColor: Colors.deepPurple,
      scaffoldBackgroundColor: Colors.black,
      cardColor: Colors.grey[800],
      textTheme: _buildTextTheme(base.textTheme, Colors.white),
      iconTheme: IconThemeData(color: Colors.orange),
      buttonTheme: ButtonThemeData(buttonColor: Colors.deepPurple),
    );
  }

  TextTheme _buildTextTheme(TextTheme base, Color color) {
    return base.apply(
      displayColor: color,
      bodyColor: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notes App',
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      home: NoteListScreen(
        isDarkMode: _isDarkMode,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}
