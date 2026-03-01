import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../../../core/states/ui_state.dart';
import '../../../core/widgets/catalogo_dropdown.dart';
import '../../../core/models/item_detalle_model.dart';
import '../../../core/models/repuesto_detalle_model.dart';
import '../../clientes/models/cliente_model.dart';
import '../../productos/models/producto_model.dart';
import '../models/presupuesto_model.dart';
import '../presupuesto_store.dart';

class PresupuestoFormPage extends StatefulWidget {
  final PresupuestoModel? presupuesto;
  const PresupuestoFormPage({super.key, this.presupuesto});

  @override
  State<PresupuestoFormPage> createState() => _PresupuestoFormPageState();
}

class _PresupuestoFormPageState extends State<PresupuestoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final store = Modular.get<PresupuestoStore>();
  late ReactionDisposer _disposer;

  String _estado = 'PENDIENTE';
  int? _clienteId;
  
  List<ItemDetalleModel> _detalles = [];
  List<RepuestoDetalleModel> _repuestos = [];

  @override
  void initState() {
    super.initState();
    store.loadClientes();
    store.loadProductos();
    
    if (widget.presupuesto != null) {
      _estado = widget.presupuesto!.estado;
      _clienteId = widget.presupuesto!.clienteId;
      _detalles = List.from(widget.presupuesto!.detalles);
      _repuestos = List.from(widget.presupuesto!.repuestos);
    }

    _disposer = reaction(
      (_) => store.formState,
      (state) {
        if (state is SuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Guardado con éxito')));
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
    super.dispose();
  }

  double get _precioTotalTrabajos => _detalles.fold(0, (sum, item) => sum + item.precio);
  double get _precioTotalRepuestos => _repuestos.fold(0, (sum, item) => sum + item.subtotal);
  double get _precioTotal => _precioTotalTrabajos + _precioTotalRepuestos;

  void _save() {
    if (_formKey.currentState!.validate() && _clienteId != null) {
      if (_detalles.isEmpty && _repuestos.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Agregue al menos un Trabajo o un Repuesto')));
        return;
      }

      final p = PresupuestoModel(
        id: widget.presupuesto?.id,
        clienteId: _clienteId!,
        precioTotal: _precioTotal,
        fecha: widget.presupuesto?.fecha ?? DateTime.now(),
        estado: _estado,
        detalles: _detalles,
        repuestos: _repuestos,
      );
      store.savePresupuesto(p);
    } else if (_clienteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seleccione un cliente')));
    }
  }

  Future<void> _showAddDetalleModal() async {
    int? tipoServicioId;
    int? tipoDispositivoId;
    int? marcaId;
    int? modeloId;
    final descripcionCtrl = TextEditingController();
    final precioCtrl = TextEditingController();
    final modalFormKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20, left: 20, right: 20,
          ),
          child: Form(
            key: modalFormKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Nuevo Trabajo a Realizar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  CatalogoDropdown(
                    label: 'Tipo de Servicio',
                    tableName: 'tipos_servicio',
                    value: tipoServicioId,
                    onChanged: (v) => tipoServicioId = v,
                  ),
                  const SizedBox(height: 10),
                  CatalogoDropdown(
                    label: 'Tipo de Dispositivo',
                    tableName: 'tipos_dispositivo',
                    value: tipoDispositivoId,
                    onChanged: (v) => tipoDispositivoId = v,
                  ),
                  const SizedBox(height: 10),
                  CatalogoDropdown(
                    label: 'Marca',
                    tableName: 'marcas',
                    value: marcaId,
                    onChanged: (v) => marcaId = v,
                  ),
                  const SizedBox(height: 10),
                  CatalogoDropdown(
                    label: 'Modelo',
                    tableName: 'modelos',
                    value: modeloId,
                    onChanged: (v) => modeloId = v,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: descripcionCtrl,
                    decoration: const InputDecoration(labelText: 'Descripción / Falla *', border: OutlineInputBorder()),
                    maxLines: 2,
                    validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: precioCtrl,
                    decoration: const InputDecoration(labelText: 'Precio Estimado (Gs.) *', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (modalFormKey.currentState!.validate()) {
                        setState(() {
                          _detalles.add(ItemDetalleModel(
                            tipoServicioId: tipoServicioId,
                            tipoDispositivoId: tipoDispositivoId,
                            marcaId: marcaId,
                            modeloId: modeloId,
                            descripcion: descripcionCtrl.text,
                            precio: double.parse(precioCtrl.text),
                            nombreServicio: tipoServicioId != null ? "Catálogo" : null, 
                          ));
                        });
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Agregar Trabajo'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showAddRepuestoModal() async {
    int? productoId;
    ProductoModel? prodSeleccionado;
    final cantidadCtrl = TextEditingController(text: '1');
    final modalFormKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20, left: 20, right: 20,
              ),
              child: Form(
                key: modalFormKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Añadir Repuesto / Producto', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      Observer(
                        builder: (_) {
                          final state = store.productosState;
                          if (state is SuccessState<List<ProductoModel>>) {
                            return DropdownSearch<ProductoModel>(
                              items: (filter, loadProps) => state.data.where((p) => p.estado).toList(),
                              itemAsString: (ProductoModel p) => '${p.descripcion} (Stock: ${p.cantidad.toStringAsFixed(0)})',
                              decoratorProps: const DropDownDecoratorProps(
                                decoration: InputDecoration(
                                  labelText: 'Buscar Producto',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              popupProps: const PopupProps.menu(
                                showSearchBox: true,
                                searchFieldProps: TextFieldProps(
                                  decoration: InputDecoration(
                                    hintText: 'Escriba para buscar...',
                                    prefixIcon: Icon(Icons.search),
                                  ),
                                ),
                              ),
                              onChanged: (ProductoModel? v) {
                                setModalState(() {
                                  productoId = v?.id;
                                  prodSeleccionado = v;
                                });
                              },
                            );
                          }
                          return const LinearProgressIndicator();
                        },
                      ),
                      const SizedBox(height: 15),
                      if (prodSeleccionado != null) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Precio Unitario: Gs. ${prodSeleccionado!.precioVenta.toStringAsFixed(0)}'),
                            Text('En Stock: ${prodSeleccionado!.cantidad.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: cantidadCtrl,
                          decoration: const InputDecoration(labelText: 'Cantidad Sugerida *', border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Requerido';
                            final qty = double.tryParse(v);
                            if (qty == null || qty <= 0) return 'Cantidad inválida';
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          if (modalFormKey.currentState!.validate() && prodSeleccionado != null) {
                            final qty = double.parse(cantidadCtrl.text);
                            setState(() {
                              _repuestos.add(RepuestoDetalleModel(
                                productoId: productoId!,
                                nombreProducto: prodSeleccionado!.descripcion,
                                cantidad: qty,
                                precioUnitario: prodSeleccionado!.precioVenta,
                                subtotal: qty * prodSeleccionado!.precioVenta,
                              ));
                            });
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Agregar Repuesto'),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          }
        );
      },
    );
  }

  Future<void> _quickRegisterCliente() async {
    final newCliente = await Modular.to.pushNamed('/clientes/form');
    if (newCliente != null && newCliente is ClienteModel) {
      await store.loadClientes();
      setState(() {
        _clienteId = newCliente.id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateTime fechaAMostrar = widget.presupuesto?.fecha ?? DateTime.now();
    final String fechaFormateada = "${fechaAMostrar.day.toString().padLeft(2, '0')}/${fechaAMostrar.month.toString().padLeft(2, '0')}/${fechaAMostrar.year} - ${fechaAMostrar.hour.toString().padLeft(2, '0')}:${fechaAMostrar.minute.toString().padLeft(2, '0')}";

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.presupuesto == null ? 'Nuevo Presupuesto' : 'Editar Presupuesto'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text('Fecha de Registro: $fechaFormateada', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Observer(
                      builder: (_) {
                        final state = store.clientesState;
                        if (state is SuccessState<List<ClienteModel>>) {
                          final clientes = state.data;
                          final clienteActual = clientes.cast<ClienteModel?>().firstWhere((c) => c?.id == _clienteId, orElse: () => null);

                          return DropdownSearch<ClienteModel>(
                            selectedItem: clienteActual,
                            items: (filter, loadProps) => clientes,
                            itemAsString: (ClienteModel c) => '${c.nombre} (${c.ruc})',
                            decoratorProps: const DropDownDecoratorProps(
                              decoration: InputDecoration(
                                labelText: 'Cliente *',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            popupProps: const PopupProps.menu(
                              showSearchBox: true,
                              searchFieldProps: TextFieldProps(
                                decoration: InputDecoration(
                                  hintText: 'Buscar por nombre o RUC...',
                                  prefixIcon: Icon(Icons.search),
                                ),
                              ),
                            ),
                            onChanged: (ClienteModel? v) => setState(() => _clienteId = v?.id),
                            validator: (v) => v == null ? 'Obligatorio' : null,
                          );
                        }
                        return const SizedBox(height: 55, child: Center(child: CircularProgressIndicator()));
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: IconButton.filled(
                      onPressed: _quickRegisterCliente,
                      icon: const Icon(Icons.person_add),
                      tooltip: 'Registro Rápido de Cliente',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              
              DropdownButtonFormField<String>(
                value: _estado,
                decoration: const InputDecoration(labelText: 'Estado General', border: OutlineInputBorder()),
                items: ['PENDIENTE', 'CONFIRMADO', 'CANCELADO'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _estado = v!),
              ),
              const SizedBox(height: 20),

              ExpansionTile(
                initiallyExpanded: false,
                title: const Text('Trabajos / Mano de Obra', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Subtotal: Gs. ${_precioTotalTrabajos.toStringAsFixed(0)}'),
                children: [
                  _detalles.isEmpty 
                    ? const Padding(padding: EdgeInsets.all(10.0), child: Text('No hay trabajos registrados'))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _detalles.length,
                        itemBuilder: (context, index) {
                          final item = _detalles[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            child: ListTile(
                              dense: true,
                              title: Text(item.descripcion),
                              subtitle: Text('Gs. ${item.precio.toStringAsFixed(0)}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                onPressed: () => setState(() => _detalles.removeAt(index)),
                              ),
                            ),
                          );
                        },
                      ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: OutlinedButton.icon(
                      onPressed: _showAddDetalleModal,
                      icon: const Icon(Icons.handyman),
                      label: const Text('Añadir Trabajo'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              ExpansionTile(
                initiallyExpanded: false,
                title: const Text('Repuestos Sugeridos', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Subtotal: Gs. ${_precioTotalRepuestos.toStringAsFixed(0)}'),
                children: [
                  _repuestos.isEmpty 
                    ? const Padding(padding: EdgeInsets.all(10.0), child: Text('No se sugirieron repuestos'))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _repuestos.length,
                        itemBuilder: (context, index) {
                          final item = _repuestos[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            child: ListTile(
                              dense: true,
                              title: Text(item.nombreProducto),
                              subtitle: Text('${item.cantidad.toStringAsFixed(0)} x Gs. ${item.precioUnitario.toStringAsFixed(0)} = Gs. ${item.subtotal.toStringAsFixed(0)}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                onPressed: () => setState(() => _repuestos.removeAt(index)),
                              ),
                            ),
                          );
                        },
                      ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: OutlinedButton.icon(
                      onPressed: _showAddRepuestoModal,
                      icon: const Icon(Icons.inventory_2),
                      label: const Text('Añadir Repuesto del Inventario'),
                    ),
                  ),
                ],
              ),

              const Divider(thickness: 2, height: 30),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Presupuesto:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Gs. ${_precioTotal.toStringAsFixed(0)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              SizedBox(
                width: double.infinity,
                child: Observer(
                  builder: (_) => ElevatedButton(
                    onPressed: store.formState is LoadingState ? null : _save,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: store.formState is LoadingState
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Guardar Presupuesto', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
