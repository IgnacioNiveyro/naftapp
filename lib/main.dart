import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:naftapp/pages/generator_page.dart';
import 'package:naftapp/pages/cargas_realizadas_page.dart';
import 'package:naftapp/providers/my_app_state.dart';
import 'package:google_fonts/google_fonts.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'NaftApp',
        theme: ThemeData(
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(),
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.black,
            primary: Colors.black,
            secondary: Colors.grey.shade200,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: Colors.white, // Fondo blanco
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey.shade200, // Fondo gris para los inputs
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            labelStyle: TextStyle(color: Colors.black87),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black, // Botón negro
              foregroundColor: Colors.white, // Texto blanco
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = CargasRealizadasPage();
        break;
      case 2:
        page = Placeholder();
        break;
      default:
        throw UnimplementedError('No widget for $selectedIndex');
    }

    return Scaffold(
  backgroundColor: Colors.white,
  body: SafeArea(
    child: page,
  ),
  bottomNavigationBar: BottomNavigationBar(
    backgroundColor: const Color.fromARGB(179, 189, 189, 189),
    elevation: 20,
    currentIndex: selectedIndex,
    selectedItemColor: Colors.black,
    unselectedItemColor: Colors.grey.shade200,
    selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
    onTap: (value) => setState(() => selectedIndex = value),
    items: const [
      BottomNavigationBarItem(
        icon: Icon(Icons.local_gas_station_outlined),
        activeIcon: Icon(Icons.local_gas_station),
        label: 'Agregar Carga',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.history_outlined),
        activeIcon: Icon(Icons.history),
        label: 'Historial',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.analytics_outlined),
        activeIcon: Icon(Icons.analytics),
        label: 'Estadísticas',
      ),
    ],
  ),
);
  }
}
