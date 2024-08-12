import 'package:flutter/material.dart';
import 'package:flutter_video_app/camera_page.dart';


void main() {
  runApp(const MyApp());
}

//definicao do tema claro
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.blue,
  hintColor: Colors.blueAccent,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black),
    bodyMedium: TextStyle(color: Colors.black),
  ),
  buttonTheme: const ButtonThemeData(
    buttonColor: Colors.blueAccent,
    textTheme: ButtonTextTheme.primary,
  ),
);
//definicao do tema escuro
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.grey[900],
  hintColor: Colors.blueAccent,
  scaffoldBackgroundColor: Colors.grey[850],
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.grey,
    foregroundColor: Colors.white,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white),
  ),
  buttonTheme: const ButtonThemeData(
    buttonColor: Colors.blueAccent,
    textTheme: ButtonTextTheme.primary,
  ),
);

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _setTheme(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.light(), // Tema claro
      darkTheme: ThemeData.dark(), // Tema escuro
      themeMode: _themeMode,
      home: CameraPage(onThemeChanged: _setTheme), // Passar função para mudar o tema
    );
  }
}
