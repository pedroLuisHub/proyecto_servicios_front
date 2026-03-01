import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../../../core/states/ui_state.dart';
import '../../../core/services/pdf_service.dart';
import '../models/presupuesto_model.dart';
import '../presupuesto_store.dart';

class PresupuestoListPage extends StatefulWidget {
  const PresupuestoListPage({super.key});

  @override
  State<PresupuestoListPage> createState() => _PresupuestoListPageState();
}

class _PresupuestoListPageState extends State<PresupuestoListPage> {
  final store = Modular.get<PresupuestoStore>();

  @override
  void initState() {
    super.initState();
    store.loadPresupuestos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Presupuestos'),
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 10),
                  Text('Error: ${(state as ErrorState).message}'),
                  ElevatedButton(
                    onPressed: store.loadPresupuestos,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is SuccessState<List<PresupuestoModel>>) {
            final presupuestos = state.data;

            if (presupuestos.isEmpty) {
              return const Center(child: Text('No hay presupuestos registrados.'));
            }

            return RefreshIndicator(
              onRefresh: store.loadPresupuestos,
              child: ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: presupuestos.length,
                itemBuilder: (context, index) {
                  final p = presupuestos[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      title: Text('Presupuesto #${p.id ?? "-"}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Cliente: ${p.nombreCliente ?? "Desconocido"}'),
                          Text('Total: Gs. ${p.precioTotal.toStringAsFixed(0)}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: p.estado == 'APROBADO' ? Colors.green : Colors.orange,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(p.estado, style: const TextStyle(color: Colors.white, fontSize: 10)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.share, color: Colors.blue),
                            onPressed: () => PdfService.generateAndSharePresupuesto(p),
                            tooltip: 'Compartir PDF',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => store.deletePresupuesto(p.id!),
                            tooltip: 'Eliminar',
                          ),
                        ],
                      ),
                      onTap: () {
                         Modular.to.pushNamed('/presupuestos/form', arguments: p);
                      },
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Modular.to.pushNamed('/presupuestos/form'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
