import 'package:mobx/mobx.dart';
import '../../core/states/ui_state.dart';
import 'models/cliente_model.dart';
import 'repositories/cliente_repository.dart';

part 'cliente_store.g.dart';

class ClienteStore = _ClienteStoreBase with _$ClienteStore;

abstract class _ClienteStoreBase with Store {
  final ClienteRepository _repository;

  _ClienteStoreBase(this._repository);

  @observable
  UIState<List<ClienteModel>> state = const InitialState();

  @observable
  UIState<ClienteModel?> formState = const InitialState();

  @action
  Future<void> loadClientes() async {
    state = const LoadingState();
    try {
      final list = await _repository.getAll();
      state = SuccessState(list);
    } catch (e) {
      state = ErrorState(e.toString());
    }
  }

  @action
  Future<void> saveCliente(ClienteModel cliente) async {
    formState = const LoadingState();
    try {
      ClienteModel result;
      if (cliente.id != null) {
        result = await _repository.update(cliente.id!, cliente);
      } else {
        result = await _repository.save(cliente);
      }
      formState = SuccessState(result);
      loadClientes(); 
    } catch (e) {
      formState = ErrorState('Error al guardar: $e');
    }
  }

  @action
  Future<void> deleteCliente(int id) async {
    try {
      await _repository.delete(id);
      loadClientes(); 
    } catch (e) {
      state = ErrorState('Error al eliminar cliente: $e');
    }
  }
}
