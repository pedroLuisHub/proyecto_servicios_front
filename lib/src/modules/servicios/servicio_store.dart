import 'package:mobx/mobx.dart';
import 'package:servicio_app/src/core/states/ui_state.dart';
import 'package:servicio_app/src/modules/servicios/models/servicio_model.dart';
import 'package:servicio_app/src/modules/servicios/repositories/servicio_repository.dart';
import 'package:servicio_app/src/modules/tecnicos/models/tecnico_model.dart';
import 'package:servicio_app/src/modules/tecnicos/repositories/tecnico_repository.dart';
import 'package:servicio_app/src/modules/clientes/models/cliente_model.dart';
import 'package:servicio_app/src/modules/clientes/repositories/cliente_repository.dart';
import 'package:servicio_app/src/modules/presupuestos/models/presupuesto_model.dart';
import 'package:servicio_app/src/modules/presupuestos/repositories/presupuesto_repository.dart';
import 'package:servicio_app/src/modules/productos/models/producto_model.dart';
import 'package:servicio_app/src/modules/productos/repositories/producto_repository.dart';

part 'servicio_store.g.dart';

class ServicioStore = _ServicioStoreBase with _$ServicioStore;

abstract class _ServicioStoreBase with Store {
  final ServicioRepository _servicioRepository;
  final TecnicoRepository _tecnicoRepository;
  final ClienteRepository _clienteRepository;
  final PresupuestoRepository _presupuestoRepository;
  final ProductoRepository _productoRepository;

  _ServicioStoreBase(
    this._servicioRepository, 
    this._tecnicoRepository, 
    this._clienteRepository,
    this._presupuestoRepository,
    this._productoRepository,
  );

  @observable
  UIState<List<ServicioModel>> state = const InitialState();

  @observable
  UIState<List<TecnicoModel>> tecnicosState = const InitialState();

  @observable
  UIState<List<ClienteModel>> clientesState = const InitialState();

  @observable
  UIState<List<PresupuestoModel>> presupuestosState = const InitialState();

  @observable
  UIState<List<ProductoModel>> productosState = const InitialState();

  @observable
  UIState<void> formState = const InitialState();

  @action
  Future<void> loadServicios() async {
    state = const LoadingState();
    try {
      final list = await _servicioRepository.getAll();
      state = SuccessState(list);
    } catch (e) {
      state = ErrorState(e.toString());
    }
  }

  @action
  Future<void> loadTecnicos() async {
    tecnicosState = const LoadingState();
    try {
      final list = await _tecnicoRepository.getAll();
      tecnicosState = SuccessState(list);
    } catch (e) {
      tecnicosState = ErrorState(e.toString());
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
  Future<void> loadPresupuestos() async {
    presupuestosState = const LoadingState();
    try {
      final list = await _presupuestoRepository.getAll();
      presupuestosState = SuccessState(list);
    } catch (e) {
      presupuestosState = ErrorState(e.toString());
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
  Future<void> saveServicio(ServicioModel servicio) async {
    formState = const LoadingState();
    try {
      if (servicio.id != null) {
        await _servicioRepository.update(servicio.id!, servicio);
      } else {
        await _servicioRepository.save(servicio);
        
        if (servicio.presupuestoId != null) {
          final presupuesto = await _presupuestoRepository.getById(servicio.presupuestoId!);
          final pConfirmado = PresupuestoModel(
            id: presupuesto.id,
            clienteId: presupuesto.clienteId,
            precioTotal: presupuesto.precioTotal,
            fecha: presupuesto.fecha,
            estado: 'CONFIRMADO', 
            detalles: presupuesto.detalles,
          );
          await _presupuestoRepository.update(pConfirmado.id!, pConfirmado);
        }
      }
      formState = const SuccessState(null);
      loadServicios();
    } catch (e) {
      formState = ErrorState('Error al guardar: $e');
    }
  }

  @action
  Future<void> deleteServicio(int id) async {
    try {
      await _servicioRepository.delete(id);
      loadServicios();
    } catch (e) {
      state = ErrorState('Error al eliminar servicio: $e');
    }
  }
}
