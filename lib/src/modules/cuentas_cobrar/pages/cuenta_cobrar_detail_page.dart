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
  final _fmt =
      NumberFormat.currency(locale: 'es_PY', symbol: 'Gs.', decimalDigits: 0);

  CuentaCobrarModel? _cuentaActualizada;
  CuentaCobrarModel get _cuenta => _cuentaActualizada ?? widget.cuenta;

  void _showCobroModal() {
    if (_cuenta.saldo <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La cuenta ya está saldada')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => _CobroModal(
        cuenta: _cuenta,
        onSuccess: () async {
          await store.loadCuentas();
          final state = store.state;
          if (state is SuccessState<List<CuentaCobrarModel>>) {
            final List<CuentaCobrarModel> cuentas = state.data;
            final currentId = widget.cuenta.id;
            if (mounted) {
              setState(() {
                _cuentaActualizada = cuentas.firstWhere(
                    (CuentaCobrarModel c) => c.id == currentId,
                    orElse: () => _cuenta);
              });
            }
          }
          if (ctx.mounted) Navigator.pop(ctx);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.inversePrimary;
    final totalCobrado = _cuenta.total - _cuenta.saldo;

    return Observer(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Cuenta #${_cuenta.id ?? "-"}'),
          backgroundColor: primary,
          actions: [
            if (_cuenta.saldo > 0)
              IconButton(
                icon: const Icon(Icons.payments),
                onPressed: _showCobroModal,
                tooltip: 'Registrar cobro',
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---- Resumen ----
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _Row('Código:', _cuenta.id?.toString() ?? '-'),
                      const Divider(height: 16),
                      _Row('Venta / Servicio:',
                          _cuenta.servicioId?.toString() ?? '-'),
                      _Row('Cliente:', _cuenta.nombreCliente, bold: true),
                      _Row('Vendedor:', 'ADMINISTRADOR'),
                      _Row('Vencimiento:', _cuenta.fechaVencimiento),
                      _Row('Fecha de emisión:', _cuenta.fechaEmision),
                      const Divider(height: 16),
                      _Row('Total documento:', _fmt.format(_cuenta.total),
                          bold: true),
                      _Row('Total cobrado:', _fmt.format(totalCobrado),
                          valueColor: Colors.green),
                      _Row('Total a cobrar:', _fmt.format(_cuenta.saldo),
                          bold: true,
                          valueColor:
                              _cuenta.saldo > 0 ? Colors.orange : Colors.green),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ---- Estado ----
              Row(
                children: [
                  const Text('Estado: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  _StatusChip(status: _cuenta.estado),
                ],
              ),

              const SizedBox(height: 24),

              // ---- Botón cobrar ----
              if (_cuenta.saldo > 0)
                ElevatedButton.icon(
                  onPressed: _showCobroModal,
                  icon: const Icon(Icons.payments, color: Colors.white),
                  label: Text(
                    'Registrar Cobro  (${_fmt.format(_cuenta.saldo)})',
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Cuenta completamente saldada',
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          color: primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Cantidad: 1',
                        style: TextStyle(color: Colors.white, fontSize: 12)),
                    Text('Cancelados: ${_cuenta.saldo <= 0 ? 1 : 0}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('A cobrar: ${_fmt.format(_cuenta.saldo)}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                    Text('Cobrado: ${_fmt.format(totalCobrado)}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Total en documentos: ${_fmt.format(_cuenta.saldo)}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;
  const _Row(this.label, this.value, {this.bold = false, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 14)),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toUpperCase()) {
      case 'PENDIENTE':
        color = Colors.orange;
        break;
      case 'PAGADO':
        color = Colors.green;
        break;
      case 'ANULADO':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return Chip(
      label: Text(status,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
      backgroundColor: color,
      padding: EdgeInsets.zero,
    );
  }
}

// ============================
// Modal de Cobro
// ============================
class _CobroModal extends StatefulWidget {
  final CuentaCobrarModel cuenta;
  final VoidCallback onSuccess;
  const _CobroModal({required this.cuenta, required this.onSuccess});

  @override
  State<_CobroModal> createState() => _CobroModalState();
}

class _CobroModalState extends State<_CobroModal> {
  final store = Modular.get<CuentaCobrarStore>();
  final _montoCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _metodoPago = 'EFECTIVO';

  @override
  void initState() {
    super.initState();
    _montoCtrl.text = widget.cuenta.saldo.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _montoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.inversePrimary;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.payments, color: Colors.white, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      'Cobro de cuenta\n${widget.cuenta.nombreCliente}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: _metodoPago,
                decoration: const InputDecoration(
                  labelText: 'Método de pago',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.credit_card),
                ),
                items: ['EFECTIVO', 'TARJETA', 'TRANSFERENCIA']
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _metodoPago = v);
                },
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _montoCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Monto a cobrar (Gs.)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Requerido';
                  final n = double.tryParse(v);
                  if (n == null || n <= 0) return 'Monto inválido';
                  if (n > widget.cuenta.saldo) {
                    return 'No puede superar el saldo (${widget.cuenta.saldo.toStringAsFixed(0)})';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              Observer(builder: (_) {
                if (store.cobroState is LoadingState) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Volver'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final monto = double.parse(_montoCtrl.text);
                            final cobro = CobroModel(
                              cuentaCobrarId: widget.cuenta.id ?? 0,
                              fecha: DateTime.now().toIso8601String(),
                              monto: monto,
                              metodoPago: _metodoPago,
                            );
                            await store.addCobro(cobro, widget.cuenta);

                            if (store.cobroState is ErrorState && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          (store.cobroState as ErrorState)
                                              .message)));
                            } else {
                              widget.onSuccess();
                            }
                          }
                        },
                        icon: const Icon(Icons.check, color: Colors.white),
                        label: const Text('Finalizar cobro',
                            style: TextStyle(color: Colors.white)),
                      ),
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
