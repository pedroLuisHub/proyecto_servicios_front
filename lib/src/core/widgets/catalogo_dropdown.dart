import 'package:flutter/material.dart';
import '../../modules/catalogos/models/catalogo_model.dart';
import '../../modules/catalogos/repositories/catalogo_repository.dart';

class CatalogoDropdown extends StatefulWidget {
  final String label;
  final String tableName;
  final int? value;
  final void Function(int?) onChanged;
  final Map<String, dynamic>? filters;
  final Map<String, dynamic>? extraData;
  final bool isRequired;

  const CatalogoDropdown({
    super.key,
    required this.label,
    required this.tableName,
    required this.value,
    required this.onChanged,
    this.filters,
    this.extraData,
    this.isRequired = true,
  });

  @override
  State<CatalogoDropdown> createState() => _CatalogoDropdownState();
}

class _CatalogoDropdownState extends State<CatalogoDropdown> {
  late CatalogoRepository _repository;
  List<CatalogoModel> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repository = CatalogoRepository(widget.tableName);
    _loadItems();
  }

  @override
  void didUpdateWidget(CatalogoDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tableName != oldWidget.tableName || 
        widget.filters?.toString() != oldWidget.filters?.toString()) {
      _repository = CatalogoRepository(widget.tableName);
      _loadItems();
    }
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    final items = await _repository.getAll(filters: widget.filters);
    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  Future<void> _showAddDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nuevo ${widget.label}'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Descripción',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      final newItem = CatalogoModel(
        descripcion: result,
        parentId: widget.extraData?['marcaId'],
      );
      final savedItem = await _repository.save(newItem);
      await _loadItems();
      widget.onChanged(savedItem.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _isLoading 
            ? const SizedBox(
                height: 55, 
                child: Center(child: CircularProgressIndicator())
              )
            : DropdownButtonFormField<int>(
            value: widget.value,
            decoration: InputDecoration(
              labelText: widget.label,
              border: const OutlineInputBorder(),
            ),
            items: _items
                    .map((e) => DropdownMenuItem(
                          value: e.id,
                          child: Text(e.descripcion),
                        ))
                    .toList(),
            onChanged: widget.onChanged,
            validator: widget.isRequired ? (v) => v == null ? 'Seleccione ${widget.label}' : null : null,
          ),
        ),
        const SizedBox(width: 10),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: IconButton.filled(
            onPressed: _showAddDialog,
            icon: const Icon(Icons.add),
            tooltip: 'Añadir ${widget.label}',
          ),
        ),
      ],
    );
  }
}
