import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/intl.dart';
import '../models/servicio_model.dart';
import '../servicio_store.dart';
import '../../cuentas_cobrar/cuenta_cobrar_store.dart';
import '../../cuentas_cobrar/models/cuenta_cobrar_model.dart';
import '../../cuentas_cobrar/models/cobro_model.dart';
import '../../clientes/models/cliente_model.dart';
import '../../clientes/repositories/cliente_repository.dart';
import '../../../core/services/pdf_service.dart';

class FinalizarServicioPage extends StatefulWidget {
  final ServicioModel servicio;
  const FinalizarServicioPage({super.key, required this.servicio});

  @override
  State<FinalizarServicioPage> createState() => _FinalizarServicioPageState();
}

class _FinalizarServicioPageState extends State<FinalizarServicioPage> {
  final servicioStore = Modular.get<ServicioStore>();
  final cuentaStore = Modular.get<CuentaCobrarStore>();
  final clienteRepo = Modular.get<
      ClienteRepository>(); // If you don't have this injected, we get it another way, maybe use the list of clients from setting.

  final numberFormat =
      NumberFormat.currency(locale: 'es_PY', symbol: 'PYG', decimalDigits: 0);
  final _entradaController = TextEditingController();

  double _entrada = 0.0;
  DateTime? _fechaVencimiento;
  ClienteModel? _cliente;

  @override
  void initState() {
    super.initState();
    _entradaController.text = '0';
    _entradaController.addListener(() {
      final val = double.tryParse(_entradaController.text) ?? 0.0;
      setState(() {
        _entrada = val;
      });
    });

    _loadCliente();
  }

  Future<void> _loadCliente() async {
    // try to get the full cliente info using the repo
    try {
      final cliente = await clienteRepo.getById(widget.servicio.clienteId);
      setState(() {
        _cliente = cliente;
      });
    } catch (e) {
      // ignore
    }
  }

  double get _saldo {
    final saldo = widget.servicio.precioTotal - _entrada;
    return saldo < 0 ? 0 : saldo;
  }

  void _limpiar() {
    _entradaController.text = '0';
    setState(() {
      _fechaVencimiento = null;
    });
  }

  Future<void> _finalizar({bool sharePdf = false}) async {
    if (_fechaVencimiento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor seleccione una fecha de vencimiento.')),
      );
      return;
    }

    // 1. Mark service as finalized
    final servicioFinalizado = ServicioModel(
      id: widget.servicio.id,
      presupuestoId: widget.servicio.presupuestoId,
      fechaProgramada: widget.servicio.fechaProgramada,
      precioTotal: widget.servicio.precioTotal,
      estado: 'FINALIZADO',
      clienteId: widget.servicio.clienteId,
      nombreCliente: widget.servicio.nombreCliente,
      tecnicoId: widget.servicio.tecnicoId,
      nombreTecnico: widget.servicio.nombreTecnico,
      detalles: widget.servicio.detalles,
      repuestos: widget.servicio.repuestos,
      imagenes: widget.servicio.imagenes,
    );
    await servicioStore.saveServicio(servicioFinalizado);

    // 2. Add cuenta cobrar
    final ahora = DateFormat('dd/MM/yy HH:mm').format(DateTime.now());
    final vencstr = DateFormat('dd/MM/yy').format(_fechaVencimiento!);

    final cuenta = CuentaCobrarModel(
      servicioId: widget.servicio.id,
      clienteId: widget.servicio.clienteId,
      nombreCliente: widget.servicio.nombreCliente ?? '-',
      rucCliente: _cliente?.ruc,
      fechaEmision: ahora,
      fechaVencimiento: vencstr,
      total: widget.servicio.precioTotal,
      saldo: _saldo,
      estado: _saldo <= 0 ? 'PAGADO' : 'PENDIENTE',
    );

    List<CobroModel> cobros = [];
    if (_entrada > 0) {
      cobros.add(CobroModel(
        cuentaCobrarId: 0, // Assigned inside the transaction
        fecha: ahora,
        monto: _entrada,
        metodoPago: 'ENTRADA / CONTADO',
      ));
    }

    await cuentaStore.saveCuenta(cuenta, cobrosIniciales: cobros);

    if (sharePdf) {
      await PdfService.generateAndShareServicio(servicioFinalizado);
    }

    if (mounted) {
      Navigator.pop(context); // returns to list page
    }
  }

  Future<void> _selectDate() async {
    final dt = await showDatePicker(
      context: context,
      initialDate: _fechaVencimiento ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (dt != null) {
      setState(() {
        _fechaVencimiento = dt;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      appBar: AppBar(
        title: const Text('Cuenta por cobrar'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.deepPurple.shade400,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white24)),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total:',
                  style: TextStyle(color: Colors.white70, fontSize: 16)),
              Row(
                children: [
                  const Text('🇵🇾 ', style: TextStyle(fontSize: 24)),
                  Text(
                      numberFormat
                          .format(widget.servicio.precioTotal)
                          .replaceAll('PYG', '')
                          .trim(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const Divider(color: Colors.white30, height: 30),
              const Text('Saldo:',
                  style: TextStyle(color: Colors.white70, fontSize: 16)),
              Row(
                children: [
                  const Text('🇵🇾 ', style: TextStyle(fontSize: 24)),
                  Text(numberFormat.format(_saldo).replaceAll('PYG', '').trim(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                ],
              ),

              const SizedBox(height: 30),

              // Client info block
              Container(
                decoration: BoxDecoration(
                    color: Colors.deepPurple.shade900.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      enabled: false,
                      controller:
                          TextEditingController(text: _cliente?.ruc ?? ''),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'RUC',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      enabled: false,
                      controller: TextEditingController(
                          text: widget.servicio.nombreCliente),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Cliente',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _entradaController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Entrada',
                              labelStyle: TextStyle(color: Colors.white70),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            onTap: _selectDate,
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Venc.',
                                labelStyle: TextStyle(color: Colors.white70),
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                _fechaVencimiento != null
                                    ? DateFormat('dd/MM/yy')
                                        .format(_fechaVencimiento!)
                                    : 'Seleccione',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.deepPurple,
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: _limpiar,
                  child: const Text('Limpiar',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: () => _finalizar(sharePdf: false),
                  child: const Text('Finalizar',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () => _finalizar(sharePdf: true),
                  child: const Text('Finalizar\nPDF',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 11)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
