import 'package:mobx/mobx.dart';
import '../../core/states/ui_state.dart';
import 'models/presupuesto_model.dart';
import 'repositories/presupuesto_repository.dart';
import '../clientes/models/cliente_model.dart';
import '../clientes/repositories/cliente_repository.dart';
import '../productos/models/producto_model.dart';
import '../productos/repositories/producto_repository.dart';

part 'presupuesto_store.g.dart';

class PresupuestoStore = _PresupuestoStoreBase with _$PresupuestoStore;

abstract class _PresupuestoStoreBase with Store {
  final PresupuestoRepository _presupuestoRepository;
  final ClienteRepository _clienteRepository;
  final ProductoRepository _productoRepository;

  _PresupuestoStoreBase(this._presupuestoRepository, this._clienteRepository, this._productoRepository);

  @observable
  UIState<List<PresupuestoModel>> state = const InitialState();

  @observable
  UIState<List<ClienteModel>> clientesState = const InitialState();

  @observable
  UIState<List<ProductoModel>> productosState = const InitialState();

  @observable
  UIState<void> formState = const InitialState();

  @action
  Future<void> loadPresupuestos() async {
    state = const LoadingState();
    try {
      final list = await _presupuestoRepository.getAll();
      state = SuccessState(list);
    } catch (e) {
      state = ErrorState(e.toString());
    }
  }

  @action
  Future<void> loadClientes() async {
    clientesState = const LoadingState();
    try {
      final list = await _clienteRepository.getAll();
      clientesState = SuccessState(list);
    } catch (e) {
      clientesState = ErrorState(e.toString());
    }
  }

  @action
  Future<void> loadProductos() async {
    productosState = const LoadingState();
    try {
      final list = await _productoRepository.getAll();
      productosState = SuccessState(list);
    } catch (e) {
      productosState = ErrorState(e.toString());
    }
  }

  @action
  Future<void> savePresupuesto(PresupuestoModel presupuesto) async {
    formState = const LoadingState();
    try {
      if (presupuesto.id != null) {
        await _presupuestoRepository.update(presupuesto.id!, presupuesto);
      } else {
        await _presupuestoRepository.save(presupuesto);
      }
      formState = const SuccessState(null);
      loadPresupuestos();
    } catch (e) {
      formState = ErrorState('Error al guardar: $e');
    }
  }

  @action
  Future<void> deletePresupuesto(int id) async {
    try {
      await _presupuestoRepository.delete(id);
      loadPresupuestos();
    } catch (e) {
      state = ErrorState('Error al eliminar presupuesto: $e');
    }
  }
}

