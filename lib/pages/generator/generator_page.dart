import 'package:flutter/material.dart';
import 'package:naftapp/pages/generator/controllers/generator_controller.dart';
import 'package:naftapp/pages/generator/widgets/seleccion_fecha.dart';
import 'package:naftapp/pages/generator/widgets/formulario_combustible.dart';

/// Pantalla para generar nuevas cargas de combustible
/// Esta clase se encarga solo de construir la UI y delega la lógica al controlador
class GeneratorPage extends StatefulWidget {
  @override
  State<GeneratorPage> createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage> {
  late final GeneratorController _controller;
  // Usado para ayudar a evitar el enfoque automático
  final FocusNode _dummyFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Ya no intentamos mostrar el teclado automáticamente
    
    // Inicializar el controlador que maneja la lógica de negocio
    _controller = GeneratorController(context: context);
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    _dummyFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Cuando se toca fuera de un campo, quitar el foco para cerrar el teclado
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          // Configurar para que el teclado no se cierre automáticamente al desplazarse
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _controller.formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Widget para seleccionar fecha actual o personalizada
                  DateSelectorWidget(
                    fechaController: _controller.fechaController,
                    selectDate: () => _controller.selectDate(context),
                  ),
                  
                  const SizedBox(height: 25),
                  
                  // Campos de formulario para datos de combustible
                  FuelFormFields(
                    precioController: _controller.precioController,
                    kmSController: _controller.kmSController,
                    montoController: _controller.montoController,
                    precioFocusNode: _controller.precioFocusNode,
                    kmsFocusNode: _controller.kmsFocusNode,
                    montoFocusNode: _controller.montoFocusNode,
                    onPrecioChanged: _controller.setPrecioValue,
                    onKmsChanged: _controller.setKmSValue,
                    onMontoChanged: _controller.setMontoValue,
                  ),
                  
                  const SizedBox(height: 25),
                  
                  // Botón de agregar con manejo especial de foco
                  Focus(
                    focusNode: _dummyFocusNode,
                    child: ElevatedButton(
                      onPressed: () {
                        // Asegurar que el foco esté en este nodo dummy antes de procesar
                        FocusScope.of(context).unfocus();
                        _dummyFocusNode.requestFocus();
                        
                        // Procesamos el formulario después de un pequeño delay
                        // para dar tiempo a que el teclado se cierre completamente
                        Future.delayed(Duration(milliseconds: 50), () {
                          if (mounted) {
                            _controller.procesarFormulario();
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      ),
                      child: Text('Agregar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}