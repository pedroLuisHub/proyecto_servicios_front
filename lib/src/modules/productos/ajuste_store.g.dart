// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ajuste_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AjusteStore on _AjusteStoreBase, Store {
  late final _$productosStateAtom =
      Atom(name: '_AjusteStoreBase.productosState', context: context);

  @override
  UIState<List<ProductoModel>> get productosState {
    _$productosStateAtom.reportRead();
    return super.productosState;
  }

  @override
  set productosState(UIState<List<ProductoModel>> value) {
    _$productosStateAtom.reportWrite(value, super.productosState, () {
      super.productosState = value;
    });
  }

  late final _$formStateAtom =
      Atom(name: '_AjusteStoreBase.formState', context: context);

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
      AsyncAction('_AjusteStoreBase.loadProductos', context: context);

  @override
  Future<void> loadProductos() {
    return _$loadProductosAsyncAction.run(() => super.loadProductos());
  }

  late final _$saveAjusteAsyncAction =
      AsyncAction('_AjusteStoreBase.saveAjuste', context: context);

  @override
  Future<void> saveAjuste(AjusteInventarioModel ajuste) {
    return _$saveAjusteAsyncAction.run(() => super.saveAjuste(ajuste));
  }

  @override
  String toString() {
    return '''
productosState: ${productosState},
formState: ${formState}
    ''';
  }
}
