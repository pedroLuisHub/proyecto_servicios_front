import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../../../core/states/ui_state.dart';
import '../models/tecnico_model.dart';
import '../tecnico_store.dart';

class TecnicoListPage extends StatefulWidget {
  const TecnicoListPage({super.key});

  @override
  State<TecnicoListPage> createState() => _TecnicoListPageState();
}

class _TecnicoListPageState extends State<TecnicoListPage> {
  final store = Modular.get<TecnicoStore>();

  @override
  void initState() {
    super.initState();
    store.loadTecnicos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Técnicos'),
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
                    onPressed: store.loadTecnicos,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is SuccessState<List<TecnicoModel>>) {
            final tecnicos = state.data;

            if (tecnicos.isEmpty) {
              return const Center(child: Text('No hay técnicos registrados.'));
            }

            return RefreshIndicator(
              onRefresh: store.loadTecnicos,
              child: ListView.builder(
                itemCount: tecnicos.length,
                itemBuilder: (context, index) {
                  final tecnico = tecnicos[index];
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(tecnico.nombreCompleto),
                    subtitle: Text('${tecnico.especialidad} - ${tecnico.documento}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(tecnico),
                    ),
                    onTap: () {
                      // Ir a edición (pendiente)
                    },
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Modular.to.pushNamed('/tecnicos/form'),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(TecnicoModel tecnico) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar'),
        content: Text('¿Desea eliminar al técnico ${tecnico.nombreCompleto}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              store.deleteTecnico(tecnico.id!);
              Navigator.pop(context);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
