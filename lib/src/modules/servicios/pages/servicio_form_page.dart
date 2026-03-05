import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../../../core/states/ui_state.dart';
import '../../../core/widgets/catalogo_dropdown.dart';
import '../../../core/models/item_detalle_model.dart';
import '../../../core/models/repuesto_detalle_model.dart';
import '../../tecnicos/models/tecnico_model.dart';
import '../../clientes/models/cliente_model.dart';
import '../../presupuestos/models/presupuesto_model.dart';
import '../../productos/models/producto_model.dart';
import '../models/servicio_model.dart';
import '../servicio_store.dart';

class ServicioFormPage extends StatefulWidget {
  final ServicioModel? servicio;
  const ServicioFormPage({super.key, this.servicio});

  @override
  State<ServicioFormPage> createState() => _ServicioFormPageState();
}

class _ServicioFormPageState extends State<ServicioFormPage> {
  final _formKey = GlobalKey<FormState>();
  final store = Modular.get<ServicioStore>();
  late ReactionDisposer _disposer;

  String _estado = 'PENDIENTE';
  bool _esCredito = false; // toggle Contado/Crédito
  int? _tecnicoId;
  String? _nombreTecnico;
  int? _clienteId;
  int? _presupuestoId;

  // Datos del equipo/dispositivo (globales al servicio)
  int? _tipoDispositivoId;
  int? _marcaId;
  int? _modeloId;

  final _observacionCtrl = TextEditingController();

  List<ItemDetalleModel> _detalles = [];
  List<RepuestoDetalleModel> _repuestos = [];

  // Imágenes
  final List<String> _imagenesPaths = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    store.loadTecnicos();
    store.loadClientes();
    store.loadPresupuestos();
    store.loadProductos(); // Para la lista de repuestos

    if (widget.servicio != null) {
      _estado = widget.servicio!.estado;
      _tecnicoId = widget.servicio!.tecnicoId;
      _nombreTecnico = widget.servicio!.nombreTecnico;
      _clienteId = widget.servicio!.clienteId;
      _presupuestoId = widget.servicio!.presupuestoId;
      _detalles = List.from(widget.servicio!.detalles);
      _repuestos = List.from(widget.servicio!.repuestos);
      _imagenesPaths.addAll(widget.servicio!.imagenes);
      _observacionCtrl.text = widget.servicio!.observacion ?? '';

      if (_detalles.isNotEmpty) {
        _tipoDispositivoId = _detalles.first.tipoDispositivoId;
        _marcaId = _detalles.first.marcaId;
        _modeloId = _detalles.first.modeloId;
      }
    }

    _disposer = reaction(
      (_) => store.formState,
      (state) {
        if (state is SuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Servicio guardado con éxito')));
          Modular.to.pop();
        } else if (state is ErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text((state as ErrorState).message)));
        }
      },
    );
  }

  @override
  void dispose() {
    _disposer();
    super.dispose();
  }

  double get _precioTotalTrabajos =>
      _detalles.fold(0, (sum, item) => sum + item.precio);
  double get _precioTotalRepuestos =>
      _repuestos.fold(0, (sum, item) => sum + item.subtotal);
  double get _precioTotalGeneral =>
      _precioTotalTrabajos + _precioTotalRepuestos;

  void _cargarPresupuesto(PresupuestoModel p) {
    setState(() {
      _presupuestoId = p.id;
      _clienteId = p.clienteId;

      if (p.detalles.isNotEmpty) {
        _tipoDispositivoId = p.detalles.first.tipoDispositivoId;
        _marcaId = p.detalles.first.marcaId;
        _modeloId = p.detalles.first.modeloId;
      }

      // Copiamos los trabajos a realizar
      _detalles = p.detalles
          .map((detalle) => ItemDetalleModel(
                tipoDispositivoId: detalle.tipoDispositivoId,
                marcaId: detalle.marcaId,
                modeloId: detalle.modeloId,
                tipoServicioId: detalle.tipoServicioId,
                descripcion: detalle.descripcion,
                precio: detalle.precio,
                nombreDispositivo: detalle.nombreDispositivo,
                nombreMarca: detalle.nombreMarca,
                nombreModelo: detalle.nombreModelo,
                nombreServicio: detalle.nombreServicio,
              ))
          .toList();

      // Copiamos los repuestos
      _repuestos = p.repuestos
          .map((repuesto) => RepuestoDetalleModel(
                productoId: repuesto.productoId,
                nombreProducto: repuesto.nombreProducto,
                cantidad: repuesto.cantidad,
                precioUnitario: repuesto.precioUnitario,
                subtotal: repuesto.subtotal,
              ))
          .toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ítems del presupuesto importados')));
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

  Future<void> _pickImage(ImageSource source) async {
    if (_imagenesPaths.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Máximo 5 imágenes permitidas')));
      return;
    }

    final XFile? image =
        await _picker.pickImage(source: source, imageQuality: 70);
    if (image != null) {
      setState(() {
        _imagenesPaths.add(image.path);
      });
    }
  }

  void _save() {
    if (_formKey.currentState!.validate() && _clienteId != null) {
      if (_detalles.isEmpty && _repuestos.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Debe registrar al menos un Trabajo o un Repuesto')));
        return;
      }

      final servicio = ServicioModel(
        id: widget.servicio?.id,
        presupuestoId: _presupuestoId,
        fechaProgramada: widget.servicio?.fechaProgramada ?? DateTime.now(),
        precioTotal: _precioTotalGeneral,
        estado: _estado,
        observacion:
            _observacionCtrl.text.isNotEmpty ? _observacionCtrl.text : null,
        clienteId: _clienteId!,
        tecnicoId: _tecnicoId,
        nombreTecnico: _nombreTecnico,
        detalles: _detalles,
        repuestos: _repuestos,
        imagenes: _imagenesPaths,
      );

      // Si es crédito y es nuevo servicio, abrir flujo de cuenta por cobrar
      if (_esCredito && widget.servicio == null) {
        Modular.to.pushNamed('/servicios/finalizar', arguments: servicio);
      } else {
        store.saveServicio(servicio);
      }
    } else {
      if (_clienteId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Por favor, seleccione un cliente')));
      }
    }
  }

  // ---- MODAL PARA AÑADIR TRABAJO ----
  Future<void> _showAddTrabajoModal() async {
    int? tipoServicioId;
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
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Form(
            key: modalFormKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                      child: Text('Nuevo Trabajo a Realizar',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold))),
                  const SizedBox(height: 15),

                  // Campos del trabajo
                  CatalogoDropdown(
                    label: 'Tipo de Servicio',
                    tableName: 'tipos_servicio',
                    value: tipoServicioId,
                    onChanged: (v) => tipoServicioId = v,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: descripcionCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Descripción / Falla',
                        border: OutlineInputBorder()),
                    maxLines: 2,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: precioCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Mano de Obra (Gs.) *',
                        border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (modalFormKey.currentState!.validate()) {
                          setState(() {
                            _detalles.add(ItemDetalleModel(
                              tipoServicioId: tipoServicioId,
                              tipoDispositivoId: _tipoDispositivoId,
                              marcaId: _marcaId,
                              modeloId: _modeloId,
                              descripcion: descripcionCtrl.text,
                              precio: double.parse(precioCtrl.text),
                            ));
                          });
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Agregar Trabajo'),
                    ),
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

  // ---- MODAL PARA AÑADIR REPUESTO ----
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
              top: 20,
              left: 20,
              right: 20,
            ),
            child: Form(
              key: modalFormKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Añadir Repuesto / Producto',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    Observer(
                      builder: (_) {
                        final state = store.productosState;
                        if (state is SuccessState<List<ProductoModel>>) {
                          return DropdownSearch<ProductoModel>(
                            items: (filter, loadProps) =>
                                state.data.where((p) => p.estado).toList(),
                            itemAsString: (ProductoModel p) =>
                                '${p.descripcion} (Stock: ${p.cantidad.toStringAsFixed(0)})',
                            compareFn: (item1, item2) => item1.id == item2.id,
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
                          Text(
                              'Precio Unitario: Gs. ${prodSeleccionado!.precioVenta.toStringAsFixed(0)}'),
                          Text(
                              'En Stock: ${prodSeleccionado!.cantidad.toStringAsFixed(0)}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: cantidadCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Cantidad Utilizada *',
                            border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Requerido';
                          final qty = double.tryParse(v);
                          if (qty == null || qty <= 0)
                            return 'Cantidad inválida';
                          if (prodSeleccionado!.cantidad < qty)
                            return 'Supera el stock actual';
                          return null;
                        },
                      ),
                    ],
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (modalFormKey.currentState!.validate() &&
                            prodSeleccionado != null) {
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
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Definir la fecha actual o la guardada
    final DateTime fechaAMostrar =
        widget.servicio?.fechaProgramada ?? DateTime.now();
    final String fechaFormateada =
        "${fechaAMostrar.day.toString().padLeft(2, '0')}/${fechaAMostrar.month.toString().padLeft(2, '0')}/${fechaAMostrar.year} - ${fechaAMostrar.hour.toString().padLeft(2, '0')}:${fechaAMostrar.minute.toString().padLeft(2, '0')}";

    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.servicio == null ? 'Registrar Servicio' : 'Editar Servicio'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Observer(
            builder: (_) => TextButton.icon(
              onPressed: store.formState is LoadingState ? null : _save,
              icon: store.formState is LoadingState
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.save, color: Colors.white),
              label: const Text('Guardar',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Fecha de Creación
              Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text('Fecha de Registro: $fechaFormateada',
                        style: const TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              // Importar Presupuesto Integrado en el Body
              if (widget.servicio == null)
                Observer(
                  builder: (_) {
                    final state = store.presupuestosState;
                    if (state is SuccessState<List<PresupuestoModel>>) {
                      final pendientes = state.data
                          .where((p) => p.estado == 'PENDIENTE')
                          .toList();
                      if (pendientes.isEmpty) return const SizedBox.shrink();

                      return Card(
                        color: Colors.purple.shade50,
                        margin: const EdgeInsets.only(bottom: 15),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              const Icon(Icons.receipt_long,
                                  color: Colors.purple),
                              const SizedBox(width: 10),
                              Expanded(
                                child: DropdownSearch<PresupuestoModel>(
                                  items: (filter, loadProps) => pendientes,
                                  itemAsString: (PresupuestoModel p) =>
                                      'Presupuesto #${p.id} - ${p.nombreCliente ?? "Sin cliente"}',
                                  compareFn: (item1, item2) =>
                                      item1.id == item2.id,
                                  decoratorProps: const DropDownDecoratorProps(
                                    decoration: InputDecoration(
                                      hintText:
                                          'Importar desde Presupuesto Pendiente',
                                      border: InputBorder.none,
                                    ),
                                  ),
                                  popupProps: const PopupProps.menu(
                                    showSearchBox: true,
                                    searchFieldProps: TextFieldProps(
                                      decoration: InputDecoration(
                                        hintText: 'Buscar presupuesto...',
                                        prefixIcon: Icon(Icons.search),
                                      ),
                                    ),
                                  ),
                                  onChanged: (PresupuestoModel? v) {
                                    if (v != null) {
                                      _cargarPresupuesto(v);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

              // Cliente
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Observer(
                      builder: (_) {
                        final state = store.clientesState;
                        if (state is SuccessState<List<ClienteModel>>) {
                          final clientes = state.data;
                          final clienteActual = clientes
                              .cast<ClienteModel?>()
                              .firstWhere((c) => c?.id == _clienteId,
                                  orElse: () => null);

                          return DropdownSearch<ClienteModel>(
                            selectedItem: clienteActual,
                            items: (filter, loadProps) => clientes,
                            itemAsString: (ClienteModel c) =>
                                '${c.nombre} (${c.ruc})',
                            compareFn: (item1, item2) => item1.id == item2.id,
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
                            onChanged: (ClienteModel? v) =>
                                setState(() => _clienteId = v?.id),
                            validator: (v) => v == null ? 'Obligatorio' : null,
                          );
                        }
                        return const SizedBox(
                            height: 55,
                            child: Center(child: CircularProgressIndicator()));
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

              // Técnico
              Observer(
                builder: (_) {
                  final state = store.tecnicosState;
                  if (state is SuccessState<List<TecnicoModel>>) {
                    final tecnicos = state.data;
                    final tecnicoActual = tecnicos
                        .cast<TecnicoModel?>()
                        .firstWhere((t) => t?.id == _tecnicoId,
                            orElse: () => null);

                    return DropdownSearch<TecnicoModel>(
                      selectedItem: tecnicoActual,
                      items: (filter, loadProps) => tecnicos,
                      itemAsString: (TecnicoModel t) => t.nombreCompleto,
                      compareFn: (item1, item2) => item1.id == item2.id,
                      decoratorProps: const DropDownDecoratorProps(
                        decoration: InputDecoration(
                          labelText: 'Técnico Asignado',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      popupProps: const PopupProps.menu(
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                            hintText: 'Buscar por nombre...',
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                      ),
                      onChanged: (TecnicoModel? v) => setState(() {
                        _tecnicoId = v?.id;
                        _nombreTecnico = v?.nombreCompleto;
                      }),
                    );
                  }
                  return const SizedBox(
                      height: 55,
                      child: Center(child: CircularProgressIndicator()));
                },
              ),
              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                value: _estado,
                decoration: const InputDecoration(
                    labelText: 'Estado General', border: OutlineInputBorder()),
                items: ['PENDIENTE', 'PROCESO', 'FINALIZADO', 'CANCELADO']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _estado = v!),
              ),

              // Si está finalizado, dar una pequeña advertencia sobre el stock
              if (_estado == 'FINALIZADO')
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    '⚠️ Al guardar como FINALIZADO, los repuestos se descontarán del stock.',
                    style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              const SizedBox(height: 20),

              // ---- SECCIÓN DATOS DEL EQUIPO/DISPOSITIVO ----
              ExpansionTile(
                initiallyExpanded: false,
                title: const Text('Datos del Equipo/Dispositivo',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.blueAccent),
                  borderRadius: BorderRadius.circular(8),
                ),
                collapsedShape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.blueAccent),
                  borderRadius: BorderRadius.circular(8),
                ),
                childrenPadding: const EdgeInsets.all(12),
                children: [
                  CatalogoDropdown(
                    label: 'Tipo de Dispositivo',
                    tableName: 'tipos_dispositivo',
                    value: _tipoDispositivoId,
                    isRequired: false,
                    onChanged: (v) {
                      setState(() {
                        _tipoDispositivoId = v;
                        for (var d in _detalles) d.tipoDispositivoId = v;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  CatalogoDropdown(
                    label: 'Marca',
                    tableName: 'marcas',
                    value: _marcaId,
                    isRequired: false,
                    onChanged: (v) {
                      setState(() {
                        _marcaId = v;
                        for (var d in _detalles) d.marcaId = v;
                        _modeloId = null;
                        for (var d in _detalles) d.modeloId = null;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  CatalogoDropdown(
                    label: 'Modelo',
                    tableName: 'modelos',
                    value: _modeloId,
                    isRequired: false,
                    filters: _marcaId != null
                        ? {'marcaId': _marcaId}
                        : {'marcaId': -1},
                    extraData: _marcaId != null ? {'marcaId': _marcaId} : null,
                    onChanged: (v) {
                      setState(() {
                        _modeloId = v;
                        for (var d in _detalles) d.modeloId = v;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _observacionCtrl,
                    decoration: const InputDecoration(
                        labelText:
                            'Observación del Dispositivo / Falla Reportada...',
                        border: OutlineInputBorder()),
                    maxLines: 2,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ---- SECCIÓN TRABAJOS A REALIZAR ----
              ExpansionTile(
                initiallyExpanded: false,
                title: const Text('Trabajos / Mano de Obra',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                    'Subtotal: Gs. ${_precioTotalTrabajos.toStringAsFixed(0)}'),
                children: [
                  _detalles.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text('No hay trabajos registrados'))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _detalles.length,
                          itemBuilder: (context, index) {
                            final item = _detalles[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              child: ListTile(
                                dense: true,
                                title: Text(item.descripcion),
                                subtitle: Text(
                                    'Gs. ${item.precio.toStringAsFixed(0)}'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red, size: 20),
                                  onPressed: () =>
                                      setState(() => _detalles.removeAt(index)),
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                child: OutlinedButton.icon(
                  onPressed: _showAddTrabajoModal,
                  icon: const Icon(Icons.handyman),
                  label: const Text('Añadir Trabajo'),
                  style: OutlinedButton.styleFrom(alignment: Alignment.center),
                ),
              ),
              const SizedBox(height: 10),

              // ---- SECCIÓN REPUESTOS UTILIZADOS ----
              ExpansionTile(
                initiallyExpanded: false,
                title: const Text('Repuestos Utilizados',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                    'Subtotal: Gs. ${_precioTotalRepuestos.toStringAsFixed(0)}'),
                children: [
                  _repuestos.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text('No se utilizaron repuestos'))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _repuestos.length,
                          itemBuilder: (context, index) {
                            final item = _repuestos[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              child: ListTile(
                                dense: true,
                                title: Text(item.nombreProducto),
                                subtitle: Text(
                                    '${item.cantidad.toStringAsFixed(0)} x Gs. ${item.precioUnitario.toStringAsFixed(0)} = Gs. ${item.subtotal.toStringAsFixed(0)}'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red, size: 20),
                                  onPressed: () => setState(
                                      () => _repuestos.removeAt(index)),
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                child: OutlinedButton.icon(
                  onPressed: _showAddRepuestoModal,
                  icon: const Icon(Icons.inventory_2),
                  label: const Text('Añadir Repuesto del Inventario'),
                  style: OutlinedButton.styleFrom(alignment: Alignment.center),
                ),
              ),
              const Divider(thickness: 2, height: 30),

              // TOTAL GENERAL
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('TOTAL A COBRAR:',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('Gs. ${_precioTotalGeneral.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.green)),
                ],
              ),
              const SizedBox(height: 16),

              // TOGGLE CONTADO / CRÉDITO
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _esCredito ? Colors.deepPurple : Colors.green,
                    width: 2,
                  ),
                  color: (_esCredito ? Colors.deepPurple : Colors.green)
                      .withOpacity(0.05),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _esCredito ? 'Venta a Crédito' : 'Venta al Contado',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color:
                                _esCredito ? Colors.deepPurple : Colors.green,
                          ),
                        ),
                        Text(
                          _esCredito
                              ? 'Se generará una cuenta por cobrar'
                              : 'Se finalizará y cobrará directamente',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    Switch(
                      value: _esCredito,
                      activeColor: Colors.deepPurple,
                      inactiveThumbColor: Colors.green,
                      inactiveTrackColor: Colors.green.withOpacity(0.3),
                      onChanged: widget.servicio != null
                          ? null // No se puede cambiar al editar
                          : (val) => setState(() => _esCredito = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Imágenes
              Text('Fotografías del Servicio (${_imagenesPaths.length}/5)',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ..._imagenesPaths.asMap().entries.map((e) {
                    final index = e.key;
                    final path = e.value;
                    return Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(File(path), fit: BoxFit.cover),
                          ),
                        ),
                        Positioned(
                          right: -10,
                          top: -10,
                          child: IconButton(
                            icon: const Icon(Icons.remove_circle,
                                color: Colors.red),
                            onPressed: () =>
                                setState(() => _imagenesPaths.removeAt(index)),
                          ),
                        ),
                      ],
                    );
                  }),
                  if (_imagenesPaths.length < 5)
                    InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (_) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.camera_alt),
                                title: const Text('Tomar Foto'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _pickImage(ImageSource.camera);
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.photo_library),
                                title: const Text('Elegir de Galería'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _pickImage(ImageSource.gallery);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          border: Border.all(
                              color: Colors.grey, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child:
                            const Icon(Icons.add_a_photo, color: Colors.grey),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
