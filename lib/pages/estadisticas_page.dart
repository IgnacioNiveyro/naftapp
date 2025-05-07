import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:naftapp/providers/my_app_state.dart';

class EstadisticasPage extends StatefulWidget {
  const EstadisticasPage({Key? key}) : super(key: key);

  @override
  State<EstadisticasPage> createState() => _EstadisticasPageState();
}

class _EstadisticasPageState extends State<EstadisticasPage> {
  // Datos
  List<double> litros = List.filled(12, 0);
  double maxLitros = 0;
  bool cargando = true;
  bool sinDatos = false;
  int anioActual = DateTime.now().year;
  
  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  void cargarDatos() {
    final cargas = Provider.of<MyAppState>(context, listen: false).cargas;
    
    // Reiniciar datos
    litros = List.filled(12, 0);
    maxLitros = 0;
    bool hayDatos = false;
    
    // Procesar cargas del año actual
    for (var carga in cargas) {
      if (carga.fecha.year == anioActual) {
        final mes = carga.fecha.month - 1;
        
        if (carga.precio > 0 && carga.monto > 0) {
          double litrosCarga = carga.monto / carga.precio;
          litros[mes] += litrosCarga;
          hayDatos = true;
          
          if (litros[mes] > maxLitros) {
            maxLitros = litros[mes];
          }
        }
      }
    }
    
    setState(() {
      cargando = false;
      sinDatos = !hayDatos;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Consumo $anioActual'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: cargarDatos,
            tooltip: 'Actualizar datos',
          ),
        ],
      ),
      body: cargando 
        ? const Center(child: CircularProgressIndicator())
        : sinDatos 
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 60, color: Colors.grey),
                  const SizedBox(height: 20),
                  Text(
                    'No hay datos para mostrar',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Litros consumidos por mes',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: Grafico(litros: litros, maxLitros: maxLitros),
                  ),
                ],
              ),
            ),
    );
  }
}

class Grafico extends StatelessWidget {
  final List<double> litros;
  final double maxLitros;
  
  const Grafico({
    Key? key,
    required this.litros,
    required this.maxLitros,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BarChart(
          BarChartData(
            maxY: maxLitros * 1.2,
            minY: 0,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  String mes = _getNombreMes(group.x.toInt());
                  return BarTooltipItem(
                    '$mes\n${litros[group.x.toInt()].toStringAsFixed(1)} L',
                    const TextStyle(color: Colors.white),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final meses = ['E', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(meses[value.toInt()]),
                    );
                  },
                  reservedSize: 30,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    if (value == 0) return const Text('');
                    return Text(value.toInt().toString());
                  },
                ),
              ),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: _calcularIntervalo(),
            ),
            barGroups: _crearBarras(context),
          ),
        ),
        // Etiquetas de valores encima de las barras
        _EtiquetasValores(litros: litros, maxLitros: maxLitros),
      ],
    );
  }

  List<BarChartGroupData> _crearBarras(BuildContext context) {
    return List.generate(12, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: litros[index],
            color: Theme.of(context).primaryColor,
            width: 20,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(3),
              topRight: Radius.circular(3),
            ),
          ),
        ],
      );
    });
  }

  double _calcularIntervalo() {
    if (maxLitros <= 10) return 2;
    if (maxLitros <= 50) return 10;
    if (maxLitros <= 100) return 20;
    return 50;
  }

  String _getNombreMes(int mes) {
    final meses = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return meses[mes];
  }
}

class _EtiquetasValores extends StatelessWidget {
  final List<double> litros;
  final double maxLitros;

  const _EtiquetasValores({
    required this.litros,
    required this.maxLitros,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final anchoBarra = constraints.maxWidth / 12;
        final alturaTotal = constraints.maxHeight;
        
        return Stack(
          children: List.generate(12, (index) {
            if (litros[index] <= 0) return const SizedBox.shrink();
            
            // Calcular posición X (centro de la barra)
            final posX = (index * anchoBarra) + (anchoBarra / 2);
            
            // Calcular posición Y (arriba de la barra)
            final ratio = litros[index] / (maxLitros * 1.2);
            final posY = alturaTotal - (alturaTotal * ratio) - 20;
            
            return Positioned(
              left: posX - 15,
              top: posY,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.shade800,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${litros[index].toStringAsFixed(1)} L',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}