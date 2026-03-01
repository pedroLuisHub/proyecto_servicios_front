import 'package:mobx/mobx.dart';
import '../../core/states/ui_state.dart';
import 'models/ajuste_model.dart';
import 'repositories/ajuste_repository.dart';
import 'models/producto_model.dart';
import 'repositories/producto_repository.dart';

part 'ajuste_store.g.dart';

class AjusteStore = _AjusteStoreBase with _$AjusteStore;

abstract class _AjusteStoreBase with Store {
  final AjusteRepository _ajusteRepository;
  final ProductoRepository _productoRepository;

  _AjusteStoreBase(this._ajusteRepository, this._productoRepository);

  @observable
  UIState<List<ProductoModel>> productosState = const InitialState();

  @observable
  UIState<void> formState = const InitialState();

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
  Future<void> saveAjuste(AjusteInventarioModel ajuste) async {
    formState = const LoadingState();
    try {
      await _ajusteRepository.save(ajuste);
      formState = const SuccessState(null);
    } catch (e) {
      formState = ErrorState('Error al guardar ajuste: $e');
    }
  }
}
