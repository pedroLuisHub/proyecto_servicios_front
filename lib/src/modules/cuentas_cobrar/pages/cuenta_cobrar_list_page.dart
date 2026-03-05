import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/intl.dart';
import 'package:servicio_app/src/core/states/ui_state.dart';
import '../cuenta_cobrar_store.dart';
import '../models/cuenta_cobrar_model.dart';

class CuentaCobrarListPage extends StatefulWidget {
  const CuentaCobrarListPage({super.key});

  @override
  State<CuentaCobrarListPage> createState() => _CuentaCobrarListPageState();
}

class _CuentaCobrarListPageState extends State<CuentaCobrarListPage> {
  final store = Modular.get<CuentaCobrarStore>();
  final _fmt =
      NumberFormat.currency(locale: 'es_PY', symbol: 'Gs.', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    store.loadCuentas();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.inversePrimary;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuentas por Cobrar'),
        backgroundColor: primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: store.loadCuentas,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: Observer(
        builder: (_) {
          final state = store.state;

          if (state is LoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 10),
                  Text('Error: ${(state as ErrorState).message}'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: store.loadCuentas,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is SuccessState<List<CuentaCobrarModel>>) {
            final cuentas = state.data;

            if (cuentas.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long, size: 60, color: Colors.grey),
                    SizedBox(height: 12),
                    Text('No hay cuentas registradas.',
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            }

            // Summary footer totals
            final totalCobrar = cuentas.fold(0.0, (sum, c) => sum + c.saldo);
            final totalCobrado =
                cuentas.fold(0.0, (sum, c) => sum + (c.total - c.saldo));

            return Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: store.loadCuentas,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: cuentas.length,
                      itemBuilder: (context, index) {
                        final cuenta = cuentas[index];
                        final cobrado = cuenta.total - cuenta.saldo;
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 8),
                            leading: CircleAvatar(
                              backgroundColor: cuenta.estado == 'PAGADO'
                                  ? Colors.green
                                  : Colors.orange,
                              child: Icon(
                                cuenta.estado == 'PAGADO'
                                    ? Icons.check
                                    : Icons.hourglass_empty,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              cuenta.nombreCliente,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                    'Emisión: ${cuenta.fechaEmision}  |  Venc.: ${cuenta.fechaVencimiento}'),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text('Total: ${_fmt.format(cuenta.total)}',
                                        style: const TextStyle(fontSize: 12)),
                                    const SizedBox(width: 8),
                                    Text('Cobrado: ${_fmt.format(cobrado)}',
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.green)),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _StatusBadge(status: cuenta.estado),
                                const SizedBox(height: 4),
                                Text(
                                  _fmt.format(cuenta.saldo),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: cuenta.saldo > 0
                                        ? Colors.orange
                                        : Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () => Modular.to.pushNamed('/cuentas/detail',
                                arguments: cuenta),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Footer resumen
                Container(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  padding: const EdgeInsets.all(12),
                  child: SafeArea(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _FooterStat(
                            label: 'Total Cuentas', value: '${cuentas.length}'),
                        _FooterStat(
                            label: 'Cobrado', value: _fmt.format(totalCobrado)),
                        _FooterStat(
                            label: 'A Cobrar', value: _fmt.format(totalCobrar)),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _FooterStat extends StatelessWidget {
  final String label;
  final String value;
  const _FooterStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.white70)),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.white)),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Text(status,
          style: const TextStyle(
              color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
