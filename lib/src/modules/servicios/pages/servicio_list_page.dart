import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../core/states/ui_state.dart';
import '../../../core/services/pdf_service.dart';
import '../models/servicio_model.dart';
import '../servicio_store.dart';

class ServicioListPage extends StatefulWidget {
  const ServicioListPage({super.key});

  @override
  State<ServicioListPage> createState() => _ServicioListPageState();
}

class _ServicioListPageState extends State<ServicioListPage> {
  final store = Modular.get<ServicioStore>();

  @override
  void initState() {
    super.initState();
    store.loadServicios();
  }

  void _confirmFinalize(ServicioModel servicio) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finalizar Servicio'),
        content: const Text('¿Desea marcar este servicio como FINALIZADO?\n\nAl hacerlo, se descontarán automáticamente los repuestos del inventario.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Clonamos el modelo cambiando únicamente el estado
              final servicioFinalizado = ServicioModel(
                id: servicio.id,
                presupuestoId: servicio.presupuestoId,
                fechaProgramada: servicio.fechaProgramada,
                precioTotal: servicio.precioTotal,
                estado: 'FINALIZADO',
                clienteId: servicio.clienteId,
                nombreCliente: servicio.nombreCliente,
                tecnicoId: servicio.tecnicoId,
                nombreTecnico: servicio.nombreTecnico,
                detalles: servicio.detalles,
                repuestos: servicio.repuestos,
                imagenes: servicio.imagenes,
              );
              store.saveServicio(servicioFinalizado);
            },
            child: const Text('Finalizar', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(ServicioModel servicio) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar'),
        content: Text('¿Desea eliminar el servicio #${servicio.id}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              store.deleteServicio(servicio.id!);
              Navigator.pop(context);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Servicios'),
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
                    onPressed: store.loadServicios,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is SuccessState<List<ServicioModel>>) {
            final servicios = state.data;

            if (servicios.isEmpty) {
              return const Center(child: Text('No hay servicios registrados.'));
            }

            return RefreshIndicator(
              onRefresh: store.loadServicios,
              child: ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: servicios.length,
                itemBuilder: (context, index) {
                  final servicio = servicios[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Slidable(
                        // Panel que se desliza desde la derecha
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (_) => PdfService.generateAndShareServicio(servicio),
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              icon: Icons.share,
                              label: 'PDF',
                            ),
                            SlidableAction(
                              onPressed: (_) => _confirmDelete(servicio),
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Borrar',
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                          title: Text('Servicio #${servicio.id ?? "-"}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 5),
                              Text('Cliente: ${servicio.nombreCliente ?? "Desconocido"}'),
                              Text('Técnico: ${servicio.nombreTecnico ?? "Sin asignar"}'),
                              const SizedBox(height: 5),
                              Text(
                                'Total: Gs. ${servicio.precioTotal.toStringAsFixed(0)}',
                                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _StatusBadge(status: servicio.estado),
                              if (servicio.estado != 'FINALIZADO') ...[
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.check_circle_outline, color: Colors.green, size: 28),
                                  tooltip: 'Marcar como Finalizado',
                                  onPressed: () => _confirmFinalize(servicio),
                                ),
                              ],
                            ],
                          ),
                          onTap: () {
                            Modular.to.pushNamed('/servicios/form', arguments: servicio);
                          },
                        ),
                      ),
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
        onPressed: () => Modular.to.pushNamed('/servicios/form'),
        child: const Icon(Icons.add),
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
      case 'PENDIENTE': color = Colors.orange; break;
      case 'PROCESO': color = Colors.blue; break;
      case 'FINALIZADO': color = Colors.green; break;
      case 'CANCELADO': color = Colors.red; break;
      default: color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
      child: Text(status, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
