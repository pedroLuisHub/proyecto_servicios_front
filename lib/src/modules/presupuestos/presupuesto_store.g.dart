// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presupuesto_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$PresupuestoStore on _PresupuestoStoreBase, Store {
  late final _$stateAtom =
      Atom(name: '_PresupuestoStoreBase.state', context: context);

  @override
  UIState<List<PresupuestoModel>> get state {
    _$stateAtom.reportRead();
    return super.state;
  }

  @override
  set state(UIState<List<PresupuestoModel>> value) {
    _$stateAtom.reportWrite(value, super.state, () {
      super.state = value;
    });
  }

  late final _$clientesStateAtom =
      Atom(name: '_PresupuestoStoreBase.clientesState', context: context);

  @override
  UIState<List<ClienteModel>> get clientesState {
    _$clientesStateAtom.reportRead();
    return super.clientesState;
  }

  @override
  set clientesState(UIState<List<ClienteModel>> value) {
    _$clientesStateAtom.reportWrite(value, super.clientesState, () {
      super.clientesState = value;
    });
  }

  late final _$productosStateAtom =
      Atom(name: '_PresupuestoStoreBase.productosState', context: context);

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

  late final _$tecnicosStateAtom =
      Atom(name: '_PresupuestoStoreBase.tecnicosState', context: context);

  @override
  UIState<List<TecnicoModel>> get tecnicosState {
    _$tecnicosStateAtom.reportRead();
    return super.tecnicosState;
  }

  @override
  set tecnicosState(UIState<List<TecnicoModel>> value) {
    _$tecnicosStateAtom.reportWrite(value, super.tecnicosState, () {
      super.tecnicosState = value;
    });
  }

  late final _$formStateAtom =
      Atom(name: '_PresupuestoStoreBase.formState', context: context);

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

  late final _$loadTecnicosAsyncAction =
      AsyncAction('_PresupuestoStoreBase.loadTecnicos', context: context);

  @override
  Future<void> loadTecnicos() {
    return _$loadTecnicosAsyncAction.run(() => super.loadTecnicos());
  }

  late final _$loadPresupuestosAsyncAction =
      AsyncAction('_PresupuestoStoreBase.loadPresupuestos', context: context);

  @override
  Future<void> loadPresupuestos() {
    return _$loadPresupuestosAsyncAction.run(() => super.loadPresupuestos());
  }

  late final _$loadClientesAsyncAction =
      AsyncAction('_PresupuestoStoreBase.loadClientes', context: context);

  @override
  Future<void> loadClientes() {
    return _$loadClientesAsyncAction.run(() => super.loadClientes());
  }

  late final _$loadProductosAsyncAction =
      AsyncAction('_PresupuestoStoreBase.loadProductos', context: context);

  @override
  Future<void> loadProductos() {
    return _$loadProductosAsyncAction.run(() => super.loadProductos());
  }

  late final _$savePresupuestoAsyncAction =
      AsyncAction('_PresupuestoStoreBase.savePresupuesto', context: context);

  @override
  Future<void> savePresupuesto(PresupuestoModel presupuesto) {
    return _$savePresupuestoAsyncAction
        .run(() => super.savePresupuesto(presupuesto));
  }

  late final _$deletePresupuestoAsyncAction =
      AsyncAction('_PresupuestoStoreBase.deletePresupuesto', context: context);

  @override
  Future<void> deletePresupuesto(int id) {
    return _$deletePresupuestoAsyncAction
        .run(() => super.deletePresupuesto(id));
  }

  @override
  String toString() {
    return '''
state: ${state},
clientesState: ${clientesState},
productosState: ${productosState},
tecnicosState: ${tecnicosState},
formState: ${formState}
    ''';
  }
}
