import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:naftapp/models/carga.dart';
import 'package:naftapp/helpers/db_helper.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreenAccent),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  final List<Carga> _cargas = [];

  List<Carga> get cargas => List.unmodifiable(_cargas);

  MyAppState() {
    _loadCargas();
  }

  void agregarCarga(Carga carga) {
    _cargas.add(carga);
    notifyListeners();
  }

  Future<void> _loadCargas() async {
    final cargasDesdeDB = await DBHelper().getCargas();
    _cargas.addAll(cargasDesdeDB);
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
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
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: page,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
        currentIndex: selectedIndex,
        onTap: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
      ),
    );
  }
}

class CargasRealizadasPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var cargas = context.watch<MyAppState>().cargas;

    if (cargas.isEmpty) {
      return Center(child: Text('No hay cargas realizadas.'));
    }

    return ListView.builder(
      itemCount: cargas.length,
      itemBuilder: (context, index) {
        final carga = cargas[index];
        return ListTile(
          leading: Icon(Icons.local_gas_station),
          title: Text('KM/S: ${carga.kmS} - Monto: \$${carga.monto}'),
          subtitle: Text(
            'Fecha: ${carga.fecha.toLocal().toString().split(' ')[0]}',
          ),
        );
      },
    );
  }
}


class GeneratorPage extends StatefulWidget {
  @override
  State<GeneratorPage> createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage> {
  bool fechaActualChecked = true;
  DateTime? selectedDate;
  String kmSValue = '';
  String montoValue = '';
  final TextEditingController _kmSController = TextEditingController();
  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final FocusNode _kmSFocusNode = FocusNode();
  final FocusNode _montoFocusNode = FocusNode();

  @override
  void dispose() {
    _kmSController.dispose();
    _montoController.dispose();
    _fechaController.dispose();
    _kmSFocusNode.dispose();
    _montoFocusNode.dispose();
    super.dispose();
  }

  void _clearFields() {
    setState(() {
      fechaActualChecked = true;
      selectedDate = null;
      kmSValue = '';
      montoValue = '';
      _kmSController.clear();
      _montoController.clear();
      _fechaController.clear();
    });

    _kmSFocusNode.unfocus();
    _montoFocusNode.unfocus();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _fechaController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Checkbox Fecha actual
          Row(
            children: [
              Checkbox(
                value: fechaActualChecked,
                onChanged: (bool? value) {
                  setState(() {
                    fechaActualChecked = value ?? true;
                    if (fechaActualChecked) {
                      _fechaController.clear();
                      selectedDate = null;
                    }
                  });
                },
              ),
              const Text('Usar fecha actual'),
            ],
          ),

          // Selector de fecha solo si el checkbox está desmarcado
          if (!fechaActualChecked) ...[
            TextField(
              controller: _fechaController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Fecha',
                border: OutlineInputBorder(),
              ),
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 20),
          ],

          // Campo KM/S
          TextField(
            controller: _kmSController,
            focusNode: _kmSFocusNode,
            decoration: const InputDecoration(
              labelText: 'KM/S vehículo',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                kmSValue = value;
              });
            },
          ),
          const SizedBox(height: 20),

          // Campo Monto
          TextField(
            controller: _montoController,
            focusNode: _montoFocusNode,
            decoration: const InputDecoration(
              labelText: 'Monto',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                montoValue = value;
              });
            },
          ),
          const SizedBox(height: 30),

          // Botón Agregar
          ElevatedButton(
            onPressed: () async {
  DateTime fecha = fechaActualChecked
      ? DateTime.now()
      : selectedDate ?? DateTime.now();

  final nuevaCarga = Carga(
    fecha: fecha,
    kmS: kmSValue,
    monto: montoValue,
  );

  await DBHelper().insertCarga(nuevaCarga);
  context.read<MyAppState>().agregarCarga(nuevaCarga);

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Datos agregados correctamente')),
  );

  _clearFields();
},
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }
}
