import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../../../core/states/ui_state.dart';
import '../models/producto_model.dart';
import '../producto_store.dart';

class ProductoListPage extends StatefulWidget {
  const ProductoListPage({super.key});

  @override
  State<ProductoListPage> createState() => _ProductoListPageState();
}

class _ProductoListPageState extends State<ProductoListPage> {
  final store = Modular.get<ProductoStore>();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    store.loadProductos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario de Productos'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_alt),
            tooltip: 'Entrada / Salida de Stock',
            onPressed: () {
              Modular.to.pushNamed('/productos/ajuste').then((_) {
                store.loadProductos();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar por Nombre o Código',
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
                        Text('Error: ${(state as ErrorState).message}'),
                        ElevatedButton(
                          onPressed: store.loadProductos,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is SuccessState<List<ProductoModel>>) {
                  final todos = state.data;
                  final productos = todos.where((p) {
                    return p.descripcion.toLowerCase().contains(_searchQuery) ||
                           (p.codigoBarras?.toLowerCase().contains(_searchQuery) ?? false);
                  }).toList();

                  if (productos.isEmpty) {
                    return const Center(child: Text('No se encontraron productos.'));
                  }

                  return RefreshIndicator(
                    onRefresh: store.loadProductos,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(10),
                      itemCount: productos.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final p = productos[index];
                        return ListTile(
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                            child: p.foto != null && p.foto!.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(File(p.foto!), fit: BoxFit.cover),
                                  )
                                : const Icon(Icons.inventory_2, color: Colors.grey),
                          ),
                          title: Text(p.descripcion, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Categoría: ${p.nombreCategoria ?? "Sin Categoría"}'),
                              Text('Código: ${p.codigoBarras ?? "S/N"}'),
                              Text(
                                'Stock: ${p.cantidad.toStringAsFixed(0)}', 
                                style: TextStyle(
                                  color: p.cantidad <= 5 ? Colors.red : Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Gs. ${p.precioVenta.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 5),
                              InkWell(
                                onTap: () => store.deleteProducto(p.id!),
                                child: const Icon(Icons.delete, color: Colors.red, size: 20),
                              ),
                            ],
                          ),
                          onTap: () {
                            Modular.to.pushNamed('/productos/form', arguments: p).then((_) => store.loadProductos());
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
        onPressed: () => Modular.to.pushNamed('/productos/form').then((_) => store.loadProductos()),
        child: const Icon(Icons.add),
      ),
    );
  }
}
