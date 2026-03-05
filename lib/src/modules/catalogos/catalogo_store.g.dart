// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalogo_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$CatalogoStore on _CatalogoStoreBase, Store {
  late final _$listStateAtom =
      Atom(name: '_CatalogoStoreBase.listState', context: context);

  @override
  UIState<dynamic> get listState {
    _$listStateAtom.reportRead();
    return super.listState;
  }

  @override
  set listState(UIState<dynamic> value) {
    _$listStateAtom.reportWrite(value, super.listState, () {
      super.listState = value;
    });
  }

  late final _$formStateAtom =
      Atom(name: '_CatalogoStoreBase.formState', context: context);

  @override
  UIState<dynamic> get formState {
    _$formStateAtom.reportRead();
    return super.formState;
  }

  @override
  set formState(UIState<dynamic> value) {
    _$formStateAtom.reportWrite(value, super.formState, () {
      super.formState = value;
    });
  }

  late final _$searchQueryAtom =
      Atom(name: '_CatalogoStoreBase.searchQuery', context: context);

  @override
  String get searchQuery {
    _$searchQueryAtom.reportRead();
    return super.searchQuery;
  }

  @override
  set searchQuery(String value) {
    _$searchQueryAtom.reportWrite(value, super.searchQuery, () {
      super.searchQuery = value;
    });
  }

  late final _$loadCatalogosAsyncAction =
      AsyncAction('_CatalogoStoreBase.loadCatalogos', context: context);

  @override
  Future<void> loadCatalogos() {
    return _$loadCatalogosAsyncAction.run(() => super.loadCatalogos());
  }

  late final _$saveCatalogoAsyncAction =
      AsyncAction('_CatalogoStoreBase.saveCatalogo', context: context);

  @override
  Future<void> saveCatalogo(CatalogoModel catalogo) {
    return _$saveCatalogoAsyncAction.run(() => super.saveCatalogo(catalogo));
  }

  late final _$deleteCatalogoAsyncAction =
      AsyncAction('_CatalogoStoreBase.deleteCatalogo', context: context);

  @override
  Future<void> deleteCatalogo(int id) {
    return _$deleteCatalogoAsyncAction.run(() => super.deleteCatalogo(id));
  }

  late final _$_CatalogoStoreBaseActionController =
      ActionController(name: '_CatalogoStoreBase', context: context);

  @override
  void setSearchQuery(String query) {
    final _$actionInfo = _$_CatalogoStoreBaseActionController.startAction(
        name: '_CatalogoStoreBase.setSearchQuery');
    try {
      return super.setSearchQuery(query);
    } finally {
      _$_CatalogoStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
listState: ${listState},
formState: ${formState},
searchQuery: ${searchQuery}
    ''';
  }
}
