import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';
import '../../../core/states/ui_state.dart';
import '../models/tecnico_model.dart';
import '../tecnico_store.dart';

class TecnicoFormPage extends StatefulWidget {
  final TecnicoModel? tecnico;
  const TecnicoFormPage({super.key, this.tecnico});

  @override
  State<TecnicoFormPage> createState() => _TecnicoFormPageState();
}

class _TecnicoFormPageState extends State<TecnicoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final store = Modular.get<TecnicoStore>();
  late ReactionDisposer _disposer;

  // Controllers
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _documentoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _especialidadController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.tecnico != null) {
      _nombreController.text = widget.tecnico!.nombre;
      _apellidoController.text = widget.tecnico!.apellido;
      _documentoController.text = widget.tecnico!.documento;
      _telefonoController.text = widget.tecnico!.telefono ?? '';
      _especialidadController.text = widget.tecnico!.especialidad ?? '';
    }

    // Reaccionar al éxito del formulario para cerrar la pantalla
    _disposer = reaction(
      (_) => store.formState,
      (state) {
        if (state is SuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Técnico guardado con éxito')),
          );
          Modular.to.pop();
        } else if (state is ErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text((state as ErrorState).message)),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _disposer();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final tecnico = TecnicoModel(
        id: widget.tecnico?.id,
        nombre: _nombreController.text,
        apellido: _apellidoController.text,
        documento: _documentoController.text,
        telefono: _telefonoController.text,
        especialidad: _especialidadController.text,
        estado: widget.tecnico?.estado ?? true,
      );
      store.saveTecnico(tecnico);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tecnico == null ? 'Registrar Técnico' : 'Editar Técnico'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre *', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _apellidoController,
                decoration: const InputDecoration(labelText: 'Apellido *', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _documentoController,
                decoration: const InputDecoration(labelText: 'Documento (CI) *', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(labelText: 'Teléfono', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _especialidadController,
                decoration: const InputDecoration(labelText: 'Especialidad', border: OutlineInputBorder()),
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
                      : const Text('Guardar Técnico', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
