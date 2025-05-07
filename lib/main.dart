import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:naftapp/pages/generator/generator_page.dart';
import 'package:naftapp/pages/cargas_realizadas_page.dart';
import 'package:naftapp/pages/estadisticas_page.dart';
import 'package:naftapp/providers/my_app_state.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    // Estilo común de botón con borde redondeado
    final defaultButtonStyle = ButtonStyle(
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'NaftApp',
        theme: ThemeData(
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(),
          //scaffoldBackgroundColor: AppColors.scaffoldBackgroundColor,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Color.fromARGB(255, 255, 42, 0),
            brightness: Brightness.light,
          ),
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: defaultButtonStyle,
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: defaultButtonStyle,
          ),
          textButtonTheme: TextButtonThemeData(
            style: defaultButtonStyle,
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
        page = EstadisticasPage();
        break;
      default:
        throw UnimplementedError('No widget for $selectedIndex');
    }

    return Scaffold(
      body: SafeArea(
        child: page,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        elevation: 20,
        currentIndex: selectedIndex,
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
