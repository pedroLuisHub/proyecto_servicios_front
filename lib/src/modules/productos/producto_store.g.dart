// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'producto_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ProductoStore on _ProductoStoreBase, Store {
  late final _$stateAtom =
      Atom(name: '_ProductoStoreBase.state', context: context);

  @override
  UIState<List<ProductoModel>> get state {
    _$stateAtom.reportRead();
    return super.state;
  }

  @override
  set state(UIState<List<ProductoModel>> value) {
    _$stateAtom.reportWrite(value, super.state, () {
      super.state = value;
    });
  }

  late final _$formStateAtom =
      Atom(name: '_ProductoStoreBase.formState', context: context);

  @override
  UIState<void> get formState {
    _$formStateAtom.reportRead();
    return super.formState;
  }

  @override
  set formState(UIState<void> value) {
    _$formStateAtom.reportWrite(value, super.formState, () {
      super.formState = value;
    });
  }

  late final _$loadProductosAsyncAction =
      AsyncAction('_ProductoStoreBase.loadProductos', context: context);

  @override
  Future<void> loadProductos() {
    return _$loadProductosAsyncAction.run(() => super.loadProductos());
  }

  late final _$saveProductoAsyncAction =
      AsyncAction('_ProductoStoreBase.saveProducto', context: context);

  @override
  Future<void> saveProducto(ProductoModel producto) {
    return _$saveProductoAsyncAction.run(() => super.saveProducto(producto));
  }

  late final _$deleteProductoAsyncAction =
      AsyncAction('_ProductoStoreBase.deleteProducto', context: context);

  @override
  Future<void> deleteProducto(int id) {
    return _$deleteProductoAsyncAction.run(() => super.deleteProducto(id));
  }

  @override
  String toString() {
    return '''
state: ${state},
formState: ${formState}
    ''';
  }
}
