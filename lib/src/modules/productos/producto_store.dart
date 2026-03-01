import 'package:mobx/mobx.dart';
import '../../core/states/ui_state.dart';
import 'models/producto_model.dart';
import 'repositories/producto_repository.dart';

part 'producto_store.g.dart';

class ProductoStore = _ProductoStoreBase with _$ProductoStore;

abstract class _ProductoStoreBase with Store {
  final ProductoRepository _repository;

  _ProductoStoreBase(this._repository);

  @observable
  UIState<List<ProductoModel>> state = const InitialState();

  @observable
  UIState<void> formState = const InitialState();

  @action
  Future<void> loadProductos() async {
    state = const LoadingState();
    try {
      final list = await _repository.getAll();
      state = SuccessState(list);
    } catch (e) {
      state = ErrorState(e.toString());
    }
  }

  @action
  Future<void> saveProducto(ProductoModel producto) async {
    formState = const LoadingState();
    try {
      if (producto.id != null) {
        await _repository.update(producto.id!, producto);
      } else {
        await _repository.save(producto);
      }
      formState = const SuccessState(null);
      loadProductos(); 
    } catch (e) {
      formState = ErrorState('Error al guardar producto: $e');
    }
  }

  @action
  Future<void> deleteProducto(int id) async {
    try {
      await _repository.delete(id);
      loadProductos(); 
    } catch (e) {
      state = ErrorState('Error al eliminar producto: $e');
    }
  }
}
