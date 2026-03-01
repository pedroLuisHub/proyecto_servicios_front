import 'package:mobx/mobx.dart';
import '../../core/states/ui_state.dart';
import 'models/tecnico_model.dart';
import 'repositories/tecnico_repository.dart';

part 'tecnico_store.g.dart';

class TecnicoStore = _TecnicoStoreBase with _$TecnicoStore;

abstract class _TecnicoStoreBase with Store {
  final TecnicoRepository _repository;

  _TecnicoStoreBase(this._repository);

  @observable
  UIState<List<TecnicoModel>> state = const InitialState();

  @observable
  UIState<void> formState = const InitialState();

  @action
  Future<void> loadTecnicos() async {
    state = const LoadingState();
    try {
      final list = await _repository.getAll();
      state = SuccessState(list);
    } catch (e) {
      state = ErrorState(e.toString());
    }
  }

  @action
  Future<void> saveTecnico(TecnicoModel tecnico) async {
    formState = const LoadingState();
    try {
      if (tecnico.id != null) {
        await _repository.update(tecnico.id!, tecnico);
      } else {
        await _repository.save(tecnico);
      }
      formState = const SuccessState(null);
      loadTecnicos(); // Recargar lista
    } catch (e) {
      formState = ErrorState('Error al guardar: $e');
    }
  }

  @action
  Future<void> deleteTecnico(int id) async {
    try {
      await _repository.delete(id);
      loadTecnicos(); 
    } catch (e) {
      state = ErrorState('Error al eliminar técnico: $e');
    }
  }
}
