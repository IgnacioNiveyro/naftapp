import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:naftapp/providers/my_app_state.dart';

class CargasRealizadasPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var cargas = context.watch<MyAppState>().cargas;
    final dateFormat = DateFormat('dd/MM/yyyy');

    if (cargas.isEmpty) {
      return Center(child: Text('No hay cargas realizadas.'));
    }

    List<Widget> items = [];
    for (int i = 0; i < cargas.length; i++) {
      final carga = cargas[i];
      final litros = double.parse(carga.monto) / carga.precio;

      items.add(
        Card(
          color: Colors.grey[300],
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Carga ${dateFormat.format(carga.fecha)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    _buildDeleteButton(context, carga),
                  ],
                ),
                
                SizedBox(height: 8),
                Text(
                  'KM: ${carga.kmS} - Monto: \$${carga.monto}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Precio: \$${carga.precio}/L - Litros: ${litros.toStringAsFixed(2)}L',
                ),
                
                // Mostrar rendimiento SOLO si no es la carga más reciente (i > 0)
                if (i > 0) ...[
                  SizedBox(height: 12),
                  _buildRendimientoText(cargas[i-1].kmS, carga.kmS, i),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return ListView(
      children: items,
    );
  }

Widget _buildRendimientoText(String kmCargaAnterior, String kmCargaActual, int index) {
  final kmAnterior = int.tryParse(kmCargaAnterior) ?? 0;
  final kmActual = int.tryParse(kmCargaActual) ?? 0;
  final diferenciaKm = kmAnterior - kmActual;

  return Container(
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.grey[50],
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Kilometros recorridos: ',
            style: TextStyle(color: Colors.grey[800]),
          ),
          TextSpan(
            text: '$diferenciaKm km',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: diferenciaKm > 0 ? Colors.green[700] : Colors.red[700],
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildDeleteButton(BuildContext context, carga) {
    return Align(
      alignment: Alignment.centerRight,
      child: IconButton(
        icon: const Icon(Icons.delete, color: Colors.black),
        onPressed: () async {
          final confirmacion = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Confirmar eliminación'),
              content: const Text('¿Desea eliminar esta carga de combustible?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );

          if (confirmacion == true) {
            context.read<MyAppState>().eliminarCarga(carga);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Carga eliminada correctamente'),
                backgroundColor: Colors.black,
              ),
            );
          }
        },
      ),
    );
  }
}