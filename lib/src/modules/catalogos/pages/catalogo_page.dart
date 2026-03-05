import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';
import '../../../core/states/ui_state.dart';
import '../../../core/widgets/catalogo_dropdown.dart';
import '../models/catalogo_model.dart';
import '../catalogo_store.dart';

class CatalogoPage extends StatefulWidget {
  final String title;
  final String tableName;

  const CatalogoPage({super.key, required this.title, required this.tableName});

  @override
  State<CatalogoPage> createState() => _CatalogoPageState();
}

class _CatalogoPageState extends State<CatalogoPage> {
  final store = Modular.get<CatalogoStore>();
  final searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    store.init(widget.tableName);
  }

  void _showFormDialog([CatalogoModel? item]) {
    final formKey = GlobalKey<FormState>();
    final descCtrl = TextEditingController(text: item?.descripcion ?? '');
    bool estado = item?.estado ?? true;
    int? marcaId = item?.parentId;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return AlertDialog(
              title: Text(item == null ? 'Nuevo Registro' : 'Editar Registro'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.tableName == 'modelos')
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: CatalogoDropdown(
                          label: 'Marca',
                          tableName: 'marcas',
                          value: marcaId,
                          onChanged: (v) {
                            setStateModal(() {
                              marcaId = v;
                            });
                          },
                        ),
                      ),
                    TextFormField(
                      controller: descCtrl,
                      decoration: const InputDecoration(labelText: 'Descripción *', border: OutlineInputBorder()),
                      validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 15),
                    SwitchListTile(
                      title: const Text('Estado Activo'),
                      value: estado,
                      onChanged: (v) {
                        setStateModal(() {
                          estado = v;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                Observer(
                  builder: (_) {
                    final isSaving = store.formState is LoadingState;
                    return ElevatedButton(
                      onPressed: isSaving ? null : () async {
                        if (formKey.currentState!.validate()) {
                          if (widget.tableName == 'modelos' && marcaId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Debe seleccionar una Marca')),
                            );
                            return;
                          }
                          final model = CatalogoModel(
                            id: item?.id,
                            descripcion: descCtrl.text,
                            estado: estado,
                            parentId: marcaId,
                          );
                          await store.saveCatalogo(model);
                          if (store.formState is SuccessState) {
                            if (mounted) Navigator.pop(context);
                          } else if (store.formState is ErrorState) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text((store.formState as ErrorState).message)),
                              );
                            }
                          }
                        }
                      },
                      child: isSaving ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Guardar'),
                    );
                  }
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _confirmDelete(CatalogoModel item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('¿Está seguro de que desea eliminar "${item.descripcion}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              store.deleteCatalogo(item.id!);
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
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchCtrl,
              decoration: InputDecoration(
                hintText: 'Buscar...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchCtrl.clear();
                    store.setSearchQuery('');
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              onChanged: store.setSearchQuery,
            ),
          ),
          Expanded(
            child: Observer(
              builder: (_) {
                final state = store.listState;
                if (state is LoadingState) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ErrorState) {
                  return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
                } else if (state is SuccessState<List<CatalogoModel>>) {
                  final list = state.data;
                  if (list.isEmpty) return const Center(child: Text('No hay registros.'));

                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final item = list[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: ListTile(
                          title: Text(item.descripcion),
                          subtitle: Text(item.estado ? 'Activo' : 'Inactivo', style: TextStyle(color: item.estado ? Colors.green : Colors.red)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showFormDialog(item),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _confirmDelete(item),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
