// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'servicio_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ServicioStore on _ServicioStoreBase, Store {
  late final _$stateAtom =
      Atom(name: '_ServicioStoreBase.state', context: context);

  @override
  UIState<List<ServicioModel>> get state {
    _$stateAtom.reportRead();
    return super.state;
  }

  @override
  set state(UIState<List<ServicioModel>> value) {
    _$stateAtom.reportWrite(value, super.state, () {
      super.state = value;
    });
  }

  late final _$tecnicosStateAtom =
      Atom(name: '_ServicioStoreBase.tecnicosState', context: context);

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

  late final _$clientesStateAtom =
      Atom(name: '_ServicioStoreBase.clientesState', context: context);

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

  late final _$presupuestosStateAtom =
      Atom(name: '_ServicioStoreBase.presupuestosState', context: context);

  @override
  UIState<List<PresupuestoModel>> get presupuestosState {
    _$presupuestosStateAtom.reportRead();
    return super.presupuestosState;
  }

  @override
  set presupuestosState(UIState<List<PresupuestoModel>> value) {
    _$presupuestosStateAtom.reportWrite(value, super.presupuestosState, () {
      super.presupuestosState = value;
    });
  }

  late final _$productosStateAtom =
      Atom(name: '_ServicioStoreBase.productosState', context: context);

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
      Atom(name: '_ServicioStoreBase.formState', context: context);

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

  late final _$loadServiciosAsyncAction =
      AsyncAction('_ServicioStoreBase.loadServicios', context: context);

  @override
  Future<void> loadServicios() {
    return _$loadServiciosAsyncAction.run(() => super.loadServicios());
  }

  late final _$loadTecnicosAsyncAction =
      AsyncAction('_ServicioStoreBase.loadTecnicos', context: context);

  @override
  Future<void> loadTecnicos() {
    return _$loadTecnicosAsyncAction.run(() => super.loadTecnicos());
  }

  late final _$loadClientesAsyncAction =
      AsyncAction('_ServicioStoreBase.loadClientes', context: context);

  @override
  Future<void> loadClientes() {
    return _$loadClientesAsyncAction.run(() => super.loadClientes());
  }

  late final _$loadPresupuestosAsyncAction =
      AsyncAction('_ServicioStoreBase.loadPresupuestos', context: context);

  @override
  Future<void> loadPresupuestos() {
    return _$loadPresupuestosAsyncAction.run(() => super.loadPresupuestos());
  }

  late final _$loadProductosAsyncAction =
      AsyncAction('_ServicioStoreBase.loadProductos', context: context);

  @override
  Future<void> loadProductos() {
    return _$loadProductosAsyncAction.run(() => super.loadProductos());
  }

  late final _$saveServicioAsyncAction =
      AsyncAction('_ServicioStoreBase.saveServicio', context: context);

  @override
  Future<void> saveServicio(ServicioModel servicio) {
    return _$saveServicioAsyncAction.run(() => super.saveServicio(servicio));
  }

  late final _$deleteServicioAsyncAction =
      AsyncAction('_ServicioStoreBase.deleteServicio', context: context);

  @override
  Future<void> deleteServicio(int id) {
    return _$deleteServicioAsyncAction.run(() => super.deleteServicio(id));
  }

  @override
  String toString() {
    return '''
state: ${state},
tecnicosState: ${tecnicosState},
clientesState: ${clientesState},
presupuestosState: ${presupuestosState},
productosState: ${productosState},
formState: ${formState}
    ''';
  }
}
