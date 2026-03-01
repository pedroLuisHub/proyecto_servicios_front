import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import '../../../core/states/ui_state.dart';
import '../../../core/widgets/catalogo_dropdown.dart';
import '../models/producto_model.dart';
import '../producto_store.dart';

class ProductoFormPage extends StatefulWidget {
  final ProductoModel? producto;
  const ProductoFormPage({super.key, this.producto});

  @override
  State<ProductoFormPage> createState() => _ProductoFormPageState();
}

class _ProductoFormPageState extends State<ProductoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final store = Modular.get<ProductoStore>();
  late ReactionDisposer _disposer;

  final _codigoController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _costoController = TextEditingController();
  final _precioVentaController = TextEditingController();
  final _cantidadController = TextEditingController();

  int? _categoriaId;
  int _iva = 10;
  bool _estado = true;
  String? _fotoPath;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    if (widget.producto != null) {
      _codigoController.text = widget.producto!.codigoBarras ?? '';
      _descripcionController.text = widget.producto!.descripcion;
      _costoController.text = widget.producto!.costo.toString();
      _precioVentaController.text = widget.producto!.precioVenta.toString();
      _cantidadController.text = widget.producto!.cantidad.toString();
      _categoriaId = widget.producto!.categoriaId;
      _iva = widget.producto!.iva;
      _estado = widget.producto!.estado;
      _fotoPath = widget.producto!.foto;
    } else {
      _cantidadController.text = "0";
    }

    _disposer = reaction(
      (_) => store.formState,
      (state) {
        if (state is SuccessState) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Producto guardado')));
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
    _codigoController.dispose();
    _descripcionController.dispose();
    _costoController.dispose();
    _precioVentaController.dispose();
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
      setState(() {
        _codigoController.text = res;
      });
    }
  }

  Future<void> _tomarFoto() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (image != null) {
      setState(() {
        _fotoPath = image.path;
      });
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final p = ProductoModel(
        id: widget.producto?.id,
        codigoBarras: _codigoController.text.trim().isEmpty
            ? null
            : _codigoController.text.trim(),
        descripcion: _descripcionController.text,
        categoriaId: _categoriaId,
        costo: double.tryParse(_costoController.text) ?? 0,
        precioVenta: double.tryParse(_precioVentaController.text) ?? 0,
        iva: _iva,
        cantidad: double.tryParse(_cantidadController.text) ?? 0,
        foto: _fotoPath,
        estado: _estado,
      );
      store.saveProducto(p);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.producto == null ? 'Registrar Producto' : 'Editar Producto'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Foto del producto
              Center(
                child: GestureDetector(
                  onTap: _tomarFoto,
                  child: Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: _fotoPath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child:
                                Image.file(File(_fotoPath!), fit: BoxFit.cover),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo,
                                  size: 40, color: Colors.blueGrey),
                              Text('Añadir Foto',
                                  style: TextStyle(fontSize: 12)),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Código de Barras
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _codigoController,
                      decoration: const InputDecoration(
                        labelText: 'Código de Barras',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.qr_code_scanner),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: IconButton.filled(
                      onPressed: _escanearCodigo,
                      icon: const Icon(Icons.camera_alt),
                      tooltip: 'Escanear con cámara',
                      style: IconButton.styleFrom(
                        padding: const EdgeInsets.all(15),
                        backgroundColor: Colors.blueAccent,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                    labelText: 'Descripción del Producto *',
                    border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 15),

              CatalogoDropdown(
                label: 'Categoría',
                tableName: 'categorias',
                value: _categoriaId,
                onChanged: (v) => setState(() => _categoriaId = v),
              ),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _costoController,
                      decoration: const InputDecoration(
                          labelText: 'Costo *', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _precioVentaController,
                      decoration: const InputDecoration(
                          labelText: 'Precio Venta *',
                          border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _iva,
                      decoration: const InputDecoration(
                          labelText: 'Impuesto (IVA)',
                          border: OutlineInputBorder()),
                      items: [0, 5, 10]
                          .map((e) =>
                              DropdownMenuItem(value: e, child: Text('$e%')))
                          .toList(),
                      onChanged: (v) => setState(() => _iva = v!),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _cantidadController,
                      decoration: const InputDecoration(
                          labelText: 'Stock', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              SwitchListTile(
                title: const Text('Producto Activo'),
                subtitle: const Text('Desactívelo si ya no lo venderá'),
                value: _estado,
                onChanged: (bool value) {
                  setState(() {
                    _estado = value;
                  });
                },
              ),

              const SizedBox(height: 30),
              Observer(
                builder: (_) => ElevatedButton(
                  onPressed: store.formState is LoadingState ? null : _save,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: store.formState is LoadingState
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Guardar Producto',
                          style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
