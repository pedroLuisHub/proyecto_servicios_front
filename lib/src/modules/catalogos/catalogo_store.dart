import 'package:mobx/mobx.dart';
import '../../core/states/ui_state.dart';
import 'models/catalogo_model.dart';
import 'repositories/catalogo_repository.dart';

part 'catalogo_store.g.dart';

class CatalogoStore = _CatalogoStoreBase with _$CatalogoStore;

abstract class _CatalogoStoreBase with Store {
  late CatalogoRepository _repository;

  @observable
  UIState listState = const InitialState();

  @observable
  UIState formState = const InitialState();

  @observable
  String searchQuery = '';

  List<CatalogoModel> _allCatalogos = [];

  Map<String, dynamic>? _filters;

  void init(String tableName, {Map<String, dynamic>? filters}) {
    _repository = CatalogoRepository(tableName);
    _filters = filters;
    loadCatalogos();
  }

  @action
  void setSearchQuery(String query) {
    searchQuery = query;
    _filter();
  }

  @action
  Future<void> loadCatalogos() async {
    listState = const LoadingState();
    try {
      _allCatalogos = await _repository.getAll(filters: _filters);
      _filter();
    } catch (e) {
      listState = ErrorState(e.toString());
    }
  }

  void _filter() {
    if (searchQuery.isEmpty) {
      listState = SuccessState<List<CatalogoModel>>(_allCatalogos);
    } else {
      final filtered = _allCatalogos
          .where((c) =>
              c.descripcion.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
      listState = SuccessState<List<CatalogoModel>>(filtered);
    }
  }

  @action
  Future<void> saveCatalogo(CatalogoModel catalogo) async {
    formState = const LoadingState();
    try {
      if (catalogo.id == null) {
        await _repository.save(catalogo);
      } else {
        await _repository.update(catalogo);
      }
      formState = const SuccessState(null);
      loadCatalogos();
    } catch (e) {
      formState = ErrorState(e.toString());
    }
  }

  @action
  Future<void> deleteCatalogo(int id) async {
    listState = const LoadingState();
    try {
      await _repository.delete(id);
      loadCatalogos();
    } catch (e) {
      listState = const ErrorState('Error al eliminar. Posiblemente esté en uso.');
      loadCatalogos();
    }
  }
}
