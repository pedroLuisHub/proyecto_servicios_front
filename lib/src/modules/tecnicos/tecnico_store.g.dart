// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tecnico_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$TecnicoStore on _TecnicoStoreBase, Store {
  late final _$stateAtom =
      Atom(name: '_TecnicoStoreBase.state', context: context);

  @override
  UIState<List<TecnicoModel>> get state {
    _$stateAtom.reportRead();
    return super.state;
  }

  @override
  set state(UIState<List<TecnicoModel>> value) {
    _$stateAtom.reportWrite(value, super.state, () {
      super.state = value;
    });
  }

  late final _$formStateAtom =
      Atom(name: '_TecnicoStoreBase.formState', context: context);

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
      AsyncAction('_TecnicoStoreBase.loadTecnicos', context: context);

  @override
  Future<void> loadTecnicos() {
    return _$loadTecnicosAsyncAction.run(() => super.loadTecnicos());
  }

  late final _$saveTecnicoAsyncAction =
      AsyncAction('_TecnicoStoreBase.saveTecnico', context: context);

  @override
  Future<void> saveTecnico(TecnicoModel tecnico) {
    return _$saveTecnicoAsyncAction.run(() => super.saveTecnico(tecnico));
  }

  late final _$deleteTecnicoAsyncAction =
      AsyncAction('_TecnicoStoreBase.deleteTecnico', context: context);

  @override
  Future<void> deleteTecnico(int id) {
    return _$deleteTecnicoAsyncAction.run(() => super.deleteTecnico(id));
  }

  @override
  String toString() {
    return '''
state: ${state},
formState: ${formState}
    ''';
  }
}
