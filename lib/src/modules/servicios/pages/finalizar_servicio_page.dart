import 'package:flutter/material.dart';
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
  final clienteRepo = Modular.get<ClienteRepository>();

  final _numberFormat =
      NumberFormat.currency(locale: 'es_PY', symbol: 'Gs.', decimalDigits: 0);
  final _entradaController = TextEditingController();

  double _entrada = 0.0;
  DateTime? _fechaVencimiento;
  ClienteModel? _cliente;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _entradaController.text = '0';
    _entradaController.addListener(() {
      final val = double.tryParse(_entradaController.text) ?? 0.0;
      setState(() => _entrada = val);
    });
    _loadCliente();
  }

  @override
  void dispose() {
    _entradaController.dispose();
    super.dispose();
  }

  Future<void> _loadCliente() async {
    try {
      final cliente = await clienteRepo.getById(widget.servicio.clienteId);
      if (mounted) setState(() => _cliente = cliente);
    } catch (_) {}
  }

  double get _saldo {
    final s = widget.servicio.precioTotal - _entrada;
    return s < 0 ? 0 : s;
  }

  void _limpiar() {
    _entradaController.text = '0';
    setState(() => _fechaVencimiento = null);
  }

  Future<void> _selectDate() async {
    final dt = await showDatePicker(
      context: context,
      initialDate:
          _fechaVencimiento ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (dt != null) setState(() => _fechaVencimiento = dt);
  }

  Future<void> _finalizar({bool sharePdf = false}) async {
    if (_fechaVencimiento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor seleccione una fecha de vencimiento.')),
      );
      return;
    }

    setState(() => _loading = true);

    // 1. Guardar servicio como FINALIZADO
    final servicioFinalizado = ServicioModel(
      id: widget.servicio.id,
      presupuestoId: widget.servicio.presupuestoId,
      fechaProgramada: widget.servicio.fechaProgramada,
      precioTotal: widget.servicio.precioTotal,
      estado: 'FINALIZADO',
      observacion: widget.servicio.observacion,
      clienteId: widget.servicio.clienteId,
      nombreCliente: widget.servicio.nombreCliente,
      tecnicoId: widget.servicio.tecnicoId,
      nombreTecnico: widget.servicio.nombreTecnico,
      detalles: widget.servicio.detalles,
      repuestos: widget.servicio.repuestos,
      imagenes: widget.servicio.imagenes,
    );
    await servicioStore.saveServicio(servicioFinalizado);

    // 2. Crear cuenta por cobrar
    final ahora = DateFormat('dd/MM/yy HH:mm').format(DateTime.now());
    final vencStr = DateFormat('dd/MM/yy').format(_fechaVencimiento!);

    final cuenta = CuentaCobrarModel(
      servicioId: widget.servicio.id,
      clienteId: widget.servicio.clienteId,
      nombreCliente: widget.servicio.nombreCliente ?? '-',
      rucCliente: _cliente?.ruc,
      fechaEmision: ahora,
      fechaVencimiento: vencStr,
      total: widget.servicio.precioTotal,
      saldo: _saldo,
      estado: _saldo <= 0 ? 'PAGADO' : 'PENDIENTE',
    );

    List<CobroModel> cobros = [];
    if (_entrada > 0) {
      cobros.add(CobroModel(
        cuentaCobrarId: 0,
        fecha: ahora,
        monto: _entrada,
        metodoPago: 'ENTRADA / CONTADO',
      ));
    }

    await cuentaStore.saveCuenta(cuenta, cobrosIniciales: cobros);

    if (sharePdf) {
      await PdfService.generateAndShareServicio(servicioFinalizado);
    }

    setState(() => _loading = false);

    if (mounted) {
      // Pop two levels: this page + the form page
      Modular.to.navigate('/servicios/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.inversePrimary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuenta por Cobrar - Crédito'),
        backgroundColor: primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---- Bloque Total / Saldo ----
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total:',
                            style: TextStyle(fontSize: 14, color: Colors.grey)),
                        Text(
                          _numberFormat.format(widget.servicio.precioTotal),
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Saldo a cobrar:',
                            style: TextStyle(fontSize: 14, color: Colors.grey)),
                        Text(
                          _numberFormat.format(_saldo),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: _saldo > 0 ? Colors.orange : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ---- Bloque Cliente ----
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Datos del Cliente',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                            fontSize: 15)),
                    const SizedBox(height: 12),
                    TextFormField(
                      enabled: false,
                      initialValue: _cliente?.ruc ?? '',
                      decoration: const InputDecoration(
                        labelText: 'RUC',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.badge),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      enabled: false,
                      initialValue: widget.servicio.nombreCliente ?? '',
                      decoration: const InputDecoration(
                        labelText: 'Cliente',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ---- Bloque Entrada / Vencimiento ----
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Condiciones de Crédito',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                            fontSize: 15)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _entradaController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Entrada (Gs.)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.payments),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: _selectDate,
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Vencimiento',
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.calendar_month),
                                suffixIcon: _fechaVencimiento != null
                                    ? IconButton(
                                        icon: const Icon(Icons.clear, size: 18),
                                        onPressed: () => setState(
                                            () => _fechaVencimiento = null),
                                      )
                                    : null,
                              ),
                              child: Text(
                                _fechaVencimiento != null
                                    ? DateFormat('dd/MM/yyyy')
                                        .format(_fechaVencimiento!)
                                    : 'Seleccionar...',
                                style: TextStyle(
                                  color: _fechaVencimiento != null
                                      ? null
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_fechaVencimiento == null)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          '⚠️ El vencimiento es obligatorio para guardar',
                          style: TextStyle(color: Colors.orange, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _limpiar,
                        icon: const Icon(Icons.cleaning_services,
                            color: Colors.red),
                        label: const Text('Limpiar',
                            style: TextStyle(color: Colors.red)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () => _finalizar(sharePdf: false),
                        icon:
                            const Icon(Icons.check_circle, color: Colors.white),
                        label: const Text('Finalizar',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () => _finalizar(sharePdf: true),
                        icon: const Icon(Icons.picture_as_pdf,
                            color: Colors.white),
                        label: const Text('Finalizar PDF',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
