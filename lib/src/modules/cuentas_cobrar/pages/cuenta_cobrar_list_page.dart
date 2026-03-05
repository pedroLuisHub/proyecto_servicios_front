import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:servicio_app/src/core/states/ui_state.dart';
import '../cuenta_cobrar_store.dart';
import '../models/cuenta_cobrar_model.dart';
import 'package:intl/intl.dart';

class CuentaCobrarListPage extends StatefulWidget {
  const CuentaCobrarListPage({super.key});

  @override
  State<CuentaCobrarListPage> createState() => _CuentaCobrarListPageState();
}

class _CuentaCobrarListPageState extends State<CuentaCobrarListPage> {
  final store = Modular.get<CuentaCobrarStore>();
  final numberFormat =
      NumberFormat.currency(locale: 'es_PY', symbol: 'Gs.', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    store.loadCuentas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuentas por Cobrar'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Observer(
        builder: (_) {
          final state = store.state;

          if (state is LoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ErrorState) {
            return Center(
                child: Text('Error: ${(state as ErrorState).message}'));
          }

          if (state is SuccessState<List<CuentaCobrarModel>>) {
            final cuentas = state.data;

            if (cuentas.isEmpty) {
              return const Center(child: Text('No hay cuentas registradas.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: cuentas.length,
              itemBuilder: (context, index) {
                final cuenta = cuentas[index];
                return Card(
                  child: ListTile(
                    title: Text(cuenta.nombreCliente),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Fecha Emisión: ${cuenta.fechaEmision}'),
                        Text('Fecha Venc.: ${cuenta.fechaVencimiento}'),
                        const SizedBox(height: 5),
                        Text(
                            'Saldo: ${numberFormat.format(cuenta.saldo)} / Total: ${numberFormat.format(cuenta.total)}'),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: _StatusBadge(status: cuenta.estado),
                    onTap: () {
                      Modular.to
                          .pushNamed('/cuentas/detail', arguments: cuenta);
                    },
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
      child: Text(status,
          style: const TextStyle(
              color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
