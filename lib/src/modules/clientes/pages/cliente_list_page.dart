import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../../../core/states/ui_state.dart';
import '../models/cliente_model.dart';
import '../cliente_store.dart';

class ClienteListPage extends StatefulWidget {
  const ClienteListPage({super.key});

  @override
  State<ClienteListPage> createState() => _ClienteListPageState();
}

class _ClienteListPageState extends State<ClienteListPage> {
  final ClienteStore store = Modular.get<ClienteStore>();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    store.loadClientes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consulta de Clientes'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar por Nombre o RUC/CI',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: Observer(
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text('Error: ${(state as ErrorState).message}', textAlign: TextAlign.center),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: store.loadClientes,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is SuccessState<List<ClienteModel>>) {
                  final todosLosClientes = state.data;
                  final clientes = todosLosClientes.where((c) {
                    return c.nombre.toLowerCase().contains(_searchQuery) ||
                           c.ruc.toLowerCase().contains(_searchQuery);
                  }).toList();

                  if (clientes.isEmpty) {
                    return const Center(child: Text('No se encontraron clientes.'));
                  }

                  return RefreshIndicator(
                    onRefresh: store.loadClientes,
                    child: ListView.separated(
                      itemCount: clientes.length,
                      padding: const EdgeInsets.only(bottom: 80),
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final cliente = clientes[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            child: const Icon(Icons.business),
                          ),
                          title: Text(cliente.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('RUC/CI: ${cliente.ruc}'),
                              if (cliente.telefono != null && cliente.telefono!.isNotEmpty) 
                                Text('Tel: ${cliente.telefono}'),
                            ],
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Modular.to.pushNamed('/clientes/form', arguments: cliente).then((_) => store.loadClientes());
                          },
                        );
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Modular.to.pushNamed('/clientes/form').then((_) => store.loadClientes()),
        child: const Icon(Icons.person_add),
      ),
    );
  }
}

