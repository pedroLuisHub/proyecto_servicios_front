// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cliente_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ClienteStore on _ClienteStoreBase, Store {
  late final _$stateAtom =
      Atom(name: '_ClienteStoreBase.state', context: context);

  @override
  UIState<List<ClienteModel>> get state {
    _$stateAtom.reportRead();
    return super.state;
  }

  @override
  set state(UIState<List<ClienteModel>> value) {
    _$stateAtom.reportWrite(value, super.state, () {
      super.state = value;
    });
  }

  late final _$formStateAtom =
      Atom(name: '_ClienteStoreBase.formState', context: context);

  @override
  UIState<ClienteModel?> get formState {
    _$formStateAtom.reportRead();
    return super.formState;
  }

  @override
  set formState(UIState<ClienteModel?> value) {
    _$formStateAtom.reportWrite(value, super.formState, () {
      super.formState = value;
    });
  }

  late final _$loadClientesAsyncAction =
      AsyncAction('_ClienteStoreBase.loadClientes', context: context);

  @override
  Future<void> loadClientes() {
    return _$loadClientesAsyncAction.run(() => super.loadClientes());
  }

  late final _$saveClienteAsyncAction =
      AsyncAction('_ClienteStoreBase.saveCliente', context: context);

  @override
  Future<void> saveCliente(ClienteModel cliente) {
    return _$saveClienteAsyncAction.run(() => super.saveCliente(cliente));
  }

  late final _$deleteClienteAsyncAction =
      AsyncAction('_ClienteStoreBase.deleteCliente', context: context);

  @override
  Future<void> deleteCliente(int id) {
    return _$deleteClienteAsyncAction.run(() => super.deleteCliente(id));
  }

  @override
  String toString() {
    return '''
state: ${state},
formState: ${formState}
    ''';
  }
}
