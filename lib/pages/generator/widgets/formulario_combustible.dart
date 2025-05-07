import 'package:flutter/material.dart';
import 'package:naftapp/utils/validacion_input.dart';

/// Widget que contiene los campos de entrada para la información de combustible
class FuelFormFields extends StatelessWidget {
  final TextEditingController precioController;
  final TextEditingController kmSController;
  final TextEditingController montoController;
  
  final FocusNode precioFocusNode;
  final FocusNode kmsFocusNode;
  final FocusNode montoFocusNode;
  
  final Function(String) onPrecioChanged;
  final Function(String) onKmsChanged;
  final Function(String) onMontoChanged;

  const FuelFormFields({
    Key? key,
    required this.precioController,
    required this.kmSController,
    required this.montoController,
    required this.precioFocusNode,
    required this.kmsFocusNode,
    required this.montoFocusNode,
    required this.onPrecioChanged,
    required this.onKmsChanged,
    required this.onMontoChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Campo de precio por litro
        _buildPriceField(context),
        
        const SizedBox(height: 25),
        
        // Campo de kilómetros
        _buildKilometersField(context),
        
        const SizedBox(height: 25),
        
        // Campo de monto
        _buildAmountField(context),
      ],
    );
  }

  /// Construye el campo de precio por litro
  Widget _buildPriceField(BuildContext context) {
    return TextFormField(
      controller: precioController,
      focusNode: precioFocusNode,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: 'Precio NAFTA por litro*',
        hintText: 'Ingrese precio por litro',
        border: OutlineInputBorder(),
        prefixText: '\$ ',
      ),
      validator: InputValidators.validarPrecio,
      onChanged: onPrecioChanged,
      onEditingComplete: () {
        // Solo cambiar el foco si el nodo puede recibir foco
        if (kmsFocusNode.canRequestFocus) {
          FocusScope.of(context).requestFocus(kmsFocusNode);
        } else {
          FocusScope.of(context).unfocus();
        }
      },
      // Evitar que se abra el teclado automáticamente
      showCursor: true,
      autofocus: false,
    );
  }

  /// Construye el campo de kilómetros
  Widget _buildKilometersField(BuildContext context) {
    return TextFormField(
      controller: kmSController,
      focusNode: kmsFocusNode,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: 'Kilómetros vehículo *',
        hintText: 'Ingrese los km de su vehículo',
        border: OutlineInputBorder(),
      ),
      validator: InputValidators.validarKilometros,
      onChanged: onKmsChanged,
      onEditingComplete: () {
        // Solo cambiar el foco si el nodo puede recibir foco
        if (montoFocusNode.canRequestFocus) {
          FocusScope.of(context).requestFocus(montoFocusNode);
        } else {
          FocusScope.of(context).unfocus();
        }
      },
      // Evitar que se abra el teclado automáticamente
      showCursor: true,
      autofocus: false,
    );
  }

  /// Construye el campo de monto
  Widget _buildAmountField(BuildContext context) {
    return TextFormField(
      controller: montoController,
      focusNode: montoFocusNode,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      decoration: const InputDecoration(
        labelText: 'Monto *',
        hintText: 'Ingrese monto a cargar',
        prefixText: '\$ ',
        border: OutlineInputBorder(),
      ),
      validator: InputValidators.validarMonto,
      onChanged: onMontoChanged,
      onEditingComplete: () {
        // Siempre quitar el foco al finalizar la edición
        FocusScope.of(context).unfocus();
      },
      // Evitar que se abra el teclado automáticamente
      showCursor: true,
      autofocus: false,
    );
  }
}