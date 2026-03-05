import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/states/ui_state.dart';
import '../models/cliente_model.dart';
import '../cliente_store.dart';

class ClienteFormPage extends StatefulWidget {
  final ClienteModel? cliente;
  const ClienteFormPage({super.key, this.cliente});

  @override
  State<ClienteFormPage> createState() => _ClienteFormPageState();
}

class _ClienteFormPageState extends State<ClienteFormPage> {
  final _formKey = GlobalKey<FormState>();
  final ClienteStore store = Modular.get<ClienteStore>();
  
  List<ReactionDisposer> _disposers = [];

  // Controllers
  final _rucController = TextEditingController();
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  final _direccionController = TextEditingController();

  // Coordenadas
  double? _latitud;
  double? _longitud;

  @override
  void initState() {
    super.initState();
    
    if (widget.cliente != null) {
      _rucController.text = widget.cliente!.ruc ?? '';
      _nombreController.text = widget.cliente!.nombre;
      _telefonoController.text = widget.cliente!.telefono ?? '';
      _emailController.text = widget.cliente!.email ?? '';
      _direccionController.text = widget.cliente!.direccion ?? '';
      _latitud = widget.cliente!.latitud;
      _longitud = widget.cliente!.longitud;
    }

    _disposers = [
      reaction(
        (_) => store.formState,
        (state) {
          if (state is SuccessState<ClienteModel?>) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cliente procesado con éxito')),
            );
            if (Navigator.of(context).canPop()) {
              Modular.to.pop(state.data);
            }
          } else if (state is ErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text((state as ErrorState).message)),
            );
          }
        },
      )
    ];
  }

  @override
  void dispose() {
    for (var d in _disposers) {
      d();
    }
    _rucController.dispose();
    _nombreController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final cliente = ClienteModel(
        id: widget.cliente?.id,
        ruc: _rucController.text.trim().isEmpty ? null : _rucController.text.trim(),
        nombre: _nombreController.text,
        telefono: _telefonoController.text,
        email: _emailController.text,
        direccion: _direccionController.text,
        latitud: _latitud,
        longitud: _longitud,
        estado: widget.cliente?.estado ?? true,
      );
      store.saveCliente(cliente);
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return null;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Ingrese un email válido';
    }
    return null;
  }

  // ---- MÉTODOS DE UBICACIÓN ----
  Future<void> _obtenerUbicacionActual() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar si el servicio de ubicación está habilitado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _mostrarMensaje('Los servicios de ubicación están deshabilitados.');
      return;
    }

    // Verificar permisos
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _mostrarMensaje('Los permisos de ubicación fueron denegados.');
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      _mostrarMensaje('Los permisos de ubicación están denegados permanentemente.');
      return;
    } 

    // Obtener ubicación
    try {
      _mostrarMensaje('Obteniendo ubicación...', isError: false);
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      
      setState(() {
        _latitud = position.latitude;
        _longitud = position.longitude;
      });
      
      _mostrarMensaje('Ubicación guardada correctamente.', isError: false);
    } catch (e) {
      _mostrarMensaje('Error al obtener ubicación: $e');
    }
  }

  Future<void> _abrirMapa() async {
    if (_latitud == null || _longitud == null) {
      _mostrarMensaje('No hay una ubicación registrada para mostrar.');
      return;
    }

    // URL universal para Google Maps
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$_latitud,$_longitud');
    
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      _mostrarMensaje('No se pudo abrir el mapa.');
    }
  }

  void _mostrarMensaje(String mensaje, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cliente == null ? 'Registrar Cliente' : 'Editar Cliente'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _rucController,
                decoration: const InputDecoration(
                  labelText: 'RUC o CI',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre o Razón Social *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _direccionController,
                decoration: const InputDecoration(
                  labelText: 'Dirección',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 10),
              
              // Fila de botones de Ubicación y Mapa
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _obtenerUbicacionActual,
                      icon: const Icon(Icons.my_location),
                      label: const Text('Ubicación'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _latitud != null ? Colors.green.shade100 : null,
                        foregroundColor: _latitud != null ? Colors.green.shade800 : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _abrirMapa,
                      icon: const Icon(Icons.map),
                      label: const Text('Mapa'),
                    ),
                  ),
                ],
              ),
              // Pequeño indicador si hay coordenadas guardadas en memoria local
              if (_latitud != null && _longitud != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Coordenadas guardadas: ${_latitud!.toStringAsFixed(4)}, ${_longitud!.toStringAsFixed(4)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 30),
              Observer(
                builder: (_) => ElevatedButton(
                  onPressed: store.formState is LoadingState ? null : _save,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: store.formState is LoadingState
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Guardar Cliente', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
