import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import '../../../core/states/ui_state.dart';
import '../models/ajuste_model.dart';
import '../models/producto_model.dart';
import '../ajuste_store.dart';

import 'package:dropdown_search/dropdown_search.dart';

class AjusteFormPage extends StatefulWidget {
  const AjusteFormPage({super.key});

  @override
  State<AjusteFormPage> createState() => _AjusteFormPageState();
}

class _AjusteFormPageState extends State<AjusteFormPage> {
  final store = Modular.get<AjusteStore>();
  late ReactionDisposer _disposer;

  final _observacionController = TextEditingController();
  final _cantidadController = TextEditingController();

  String _tipoAjuste = 'ENTRADA'; // 'ENTRADA' o 'SALIDA'
  int? _productoSeleccionadoId;
  ProductoModel? _productoSeleccionado;

  final List<AjusteDetalleModel> _detalles = [];

  @override
  void initState() {
    super.initState();
    store.loadProductos();

    _disposer = reaction(
      (_) => store.formState,
      (state) {
        if (state is SuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ajuste de inventario guardado')));
          Modular.to.pop();
        } else if (state is ErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text((state as ErrorState).message)));
        }
      },
    );
  }

  @override
  void dispose() {
    _disposer();
    _observacionController.dispose();
    _cantidadController.dispose();
    super.dispose();
  }

  Future<void> _escanearCodigo() async {
    var res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SimpleBarcodeScannerPage(),
      ),
    );
    if (res is String && res != '-1') {
      // Buscar el producto en la lista cargada
      if (store.productosState is SuccessState<List<ProductoModel>>) {
        final productos = (store.productosState as SuccessState<List<ProductoModel>>).data;
        try {
          final p = productos.firstWhere((element) => element.codigoBarras == res);
          setState(() {
            _productoSeleccionadoId = p.id;
            _productoSeleccionado = p;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Producto detectado: ${p.descripcion}')));
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Producto no encontrado')));
        }
      }
    }
  }

  void _agregarItem() {
    if (_productoSeleccionadoId == null || _productoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seleccione un producto')));
      return;
    }
    final double cantidad = double.tryParse(_cantidadController.text) ?? 0;
    if (cantidad <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingrese una cantidad válida mayor a 0')));
      return;
    }

    if (_tipoAjuste == 'SALIDA' && _productoSeleccionado!.cantidad < cantidad) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Stock insuficiente para la salida')));
      return;
    }

    setState(() {
      _detalles.add(AjusteDetalleModel(
        productoId: _productoSeleccionadoId!,
        nombreProducto: _productoSeleccionado!.descripcion,
        cantidad: cantidad,
      ));
      
      // Limpiar campos
      _productoSeleccionadoId = null;
      _productoSeleccionado = null;
      _cantidadController.clear();
    });
  }

  void _guardarAjuste() {
    if (_detalles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Agregue al menos un producto al ajuste')));
      return;
    }
    
    final observacion = _observacionController.text.trim();
    if (observacion.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingrese una observación para este movimiento')));
      return;
    }

    final ajuste = AjusteInventarioModel(
      tipo: _tipoAjuste,
      observacion: observacion,
      fecha: DateTime.now(),
      detalles: _detalles,
    );

    store.saveAjuste(ajuste);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entrada / Salida de Stock'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            // Palanca ENTRADA / SALIDA
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() {
                        _tipoAjuste = 'ENTRADA';
                        _detalles.clear(); // Limpiamos detalles al cambiar de tipo
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: _tipoAjuste == 'ENTRADA' ? Colors.green : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'ENTRADA',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _tipoAjuste == 'ENTRADA' ? Colors.white : Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() {
                        _tipoAjuste = 'SALIDA';
                        _detalles.clear();
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: _tipoAjuste == 'SALIDA' ? Colors.red : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'SALIDA',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _tipoAjuste == 'SALIDA' ? Colors.white : Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: _observacionController,
              decoration: const InputDecoration(labelText: 'Observación / Motivo *', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),

            // Selector de Producto y Escáner
            Row(
              children: [
                Expanded(
                  child: Observer(
                    builder: (_) {
                      final state = store.productosState;
                      if (state is SuccessState<List<ProductoModel>>) {
                        final productos = state.data;
                        final productoActual = productos.cast<ProductoModel?>().firstWhere((p) => p?.id == _productoSeleccionadoId, orElse: () => null);

                        return DropdownSearch<ProductoModel>(
                          selectedItem: productoActual,
                          items: (filter, loadProps) => productos,
                          itemAsString: (ProductoModel p) => p.descripcion,
                          decoratorProps: const DropDownDecoratorProps(
                            decoration: InputDecoration(
                              labelText: 'Producto',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          popupProps: const PopupProps.menu(
                            showSearchBox: true,
                            searchFieldProps: TextFieldProps(
                              decoration: InputDecoration(
                                hintText: 'Buscar por nombre o código...',
                                prefixIcon: Icon(Icons.search),
                              ),
                            ),
                          ),
                          onChanged: (ProductoModel? v) {
                            setState(() {
                              _productoSeleccionadoId = v?.id;
                              _productoSeleccionado = v;
                            });
                          },
                        );
                      }
                      return const LinearProgressIndicator();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filled(
                  onPressed: _escanearCodigo,
                  icon: const Icon(Icons.qr_code_scanner),
                  tooltip: 'Escanear',
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Mostrar existencia actual
            if (_productoSeleccionado != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Row(
                  children: [
                    const Text('Existencia Actual: ', style: TextStyle(color: Colors.grey)),
                    Text(
                      _productoSeleccionado!.cantidad.toStringAsFixed(0),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),

            // Cantidad a Ajustar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cantidadController,
                    decoration: const InputDecoration(labelText: 'Cantidad', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _agregarItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar'),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // Lista de Ítems
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Ítems a ajustar:', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const Divider(),
            Expanded(
              child: _detalles.isEmpty
                  ? const Center(child: Text('No hay ítems en la lista'))
                  : ListView.builder(
                      itemCount: _detalles.length,
                      itemBuilder: (context, index) {
                        final item = _detalles[index];
                        return ListTile(
                          title: Text(item.nombreProducto),
                          subtitle: Text('Cantidad: ${item.cantidad.toStringAsFixed(0)}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () => setState(() => _detalles.removeAt(index)),
                          ),
                        );
                      },
                    ),
            ),
            
            // Botón Guardar
            SizedBox(
              width: double.infinity,
              child: Observer(
                builder: (_) => ElevatedButton(
                  onPressed: store.formState is LoadingState ? null : _guardarAjuste,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: store.formState is LoadingState
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('Guardar ${_tipoAjuste}', style: const TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
