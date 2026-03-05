import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/intl.dart';
import 'package:servicio_app/src/core/states/ui_state.dart';
import '../cuenta_cobrar_store.dart';
import '../models/cuenta_cobrar_model.dart';
import '../models/cobro_model.dart';

class CuentaCobrarDetailPage extends StatefulWidget {
  final CuentaCobrarModel cuenta;
  const CuentaCobrarDetailPage({super.key, required this.cuenta});

  @override
  State<CuentaCobrarDetailPage> createState() => _CuentaCobrarDetailPageState();
}

class _CuentaCobrarDetailPageState extends State<CuentaCobrarDetailPage> {
  final store = Modular.get<CuentaCobrarStore>();
  final numberFormat =
      NumberFormat.currency(locale: 'es_PY', symbol: 'PYG', decimalDigits: 0);

  // local updated state since mobx store reload might not immediately reflect passed widget.cuenta
  CuentaCobrarModel? _cuentaActualizada;

  CuentaCobrarModel get _currentCuenta => _cuentaActualizada ?? widget.cuenta;

  void _showCobroModal() {
    final saldo = _currentCuenta.saldo;
    if (saldo <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La cuenta ya está saldada')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return _CobroModal(
          cuenta: _currentCuenta,
          onSuccess: () async {
            // refresh data
            await store.loadCuentas();
            final state = store.state;
            if (state is SuccessState<List<CuentaCobrarModel>>) {
              final List<CuentaCobrarModel> cuentas = state.data;
              final currentId = _currentCuenta.id;
              setState(() {
                _cuentaActualizada = cuentas.firstWhere(
                    (CuentaCobrarModel c) => c.id == currentId,
                    orElse: () => _currentCuenta);
              });
            }
            if (context.mounted) Navigator.pop(context); // close modal
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      final cuenta = _currentCuenta;
      final totalCobrado = cuenta.total - cuenta.saldo;

      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Código:', cuenta.id?.toString() ?? '-'),
              _buildInfoRow(
                  'Venta/Servicio:', cuenta.servicioId?.toString() ?? '-'),
              _buildInfoRow('Cliente:', cuenta.nombreCliente),
              _buildInfoRow('Vendedor:', 'ADMINISTRADOR'),
              _buildInfoRow('Vencimiento:', cuenta.fechaVencimiento),
              _buildInfoRow('Fecha de emisión:', cuenta.fechaEmision),
              _buildInfoRow(
                  'Total documento:', numberFormat.format(cuenta.total),
                  bold: true),
              _buildInfoRow(
                  'Total cobrado:', numberFormat.format(totalCobrado)),
              _buildInfoRow(
                  'Total a cobrar:', numberFormat.format(cuenta.saldo),
                  bold: true),
              const SizedBox(height: 20),
              if (cuenta.saldo > 0)
                IconButton(
                  onPressed: _showCobroModal,
                  icon: const Icon(Icons.payments,
                      size: 36, color: Colors.deepPurple),
                  tooltip: 'Hacer cobro',
                ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          color: Colors.deepPurple,
          padding: const EdgeInsets.all(16.0),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Cantidad: 1',
                        style: const TextStyle(color: Colors.white)),
                    Text('Cantidad cancelados: ${cuenta.saldo <= 0 ? 1 : 0}',
                        style: const TextStyle(color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total a cobrar: ${numberFormat.format(cuenta.saldo)}',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(
                        'Total cobrado: ${numberFormat.format(cuenta.total - cuenta.saldo)}',
                        style: const TextStyle(color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                    'Total en documentos a cobrar: ${numberFormat.format(cuenta.saldo)}',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildInfoRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(fontSize: 16)),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 16,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CobroModal extends StatefulWidget {
  final CuentaCobrarModel cuenta;
  final VoidCallback onSuccess;

  const _CobroModal({required this.cuenta, required this.onSuccess});

  @override
  State<_CobroModal> createState() => _CobroModalState();
}

class _CobroModalState extends State<_CobroModal> {
  final store = Modular.get<CuentaCobrarStore>();
  final _montoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _metodoPago = 'EFECTIVO';

  @override
  void initState() {
    super.initState();
    _montoController.text = widget.cuenta.saldo.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Colors.deepPurple,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Cobro de cuenta por cobrar de ${widget.cuenta.nombreCliente}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _metodoPago,
                dropdownColor: Colors.deepPurple.shade700,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(),
                ),
                items: ['EFECTIVO', 'TARJETA', 'TRANSFERENCIA'].map((metodo) {
                  return DropdownMenuItem(value: metodo, child: Text(metodo));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _metodoPago = val);
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _montoController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(),
                  prefixText: 'Gs. ',
                  prefixStyle: TextStyle(color: Colors.white),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Requerido';
                  final num = double.tryParse(val);
                  if (num == null || num <= 0) return 'Monto inválido';
                  if (num > widget.cuenta.saldo)
                    return 'No puede ser mayor al saldo (${widget.cuenta.saldo})';
                  return null;
                },
              ),
              const SizedBox(height: 30),
              Observer(builder: (_) {
                final loading = store.cobroState is LoadingState;
                if (loading)
                  return const CircularProgressIndicator(color: Colors.white);

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Volver',
                          style: TextStyle(color: Colors.white)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo.shade900),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final monto = double.parse(_montoController.text);
                          final cobro = CobroModel(
                            cuentaCobrarId: widget.cuenta.id ?? 0,
                            fecha: DateFormat('dd/MM/yy HH:mm')
                                .format(DateTime.now()),
                            monto: monto,
                            metodoPago: _metodoPago,
                          );
                          await store.addCobro(cobro, widget.cuenta);

                          if (store.cobroState is ErrorState) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        (store.cobroState as ErrorState)
                                            .message)),
                              );
                            }
                          } else {
                            widget.onSuccess();
                          }
                        }
                      },
                      child: const Text('Finalizar cobro',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
