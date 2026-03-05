// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cuenta_cobrar_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$CuentaCobrarStore on _CuentaCobrarStoreBase, Store {
  late final _$stateAtom =
      Atom(name: '_CuentaCobrarStoreBase.state', context: context);

  @override
  UIState<dynamic> get state {
    _$stateAtom.reportRead();
    return super.state;
  }

  @override
  set state(UIState<dynamic> value) {
    _$stateAtom.reportWrite(value, super.state, () {
      super.state = value;
    });
  }

  late final _$cobroStateAtom =
      Atom(name: '_CuentaCobrarStoreBase.cobroState', context: context);

  @override
  UIState<dynamic> get cobroState {
    _$cobroStateAtom.reportRead();
    return super.cobroState;
  }

  @override
  set cobroState(UIState<dynamic> value) {
    _$cobroStateAtom.reportWrite(value, super.cobroState, () {
      super.cobroState = value;
    });
  }

  late final _$loadCuentasAsyncAction =
      AsyncAction('_CuentaCobrarStoreBase.loadCuentas', context: context);

  @override
  Future<void> loadCuentas() {
    return _$loadCuentasAsyncAction.run(() => super.loadCuentas());
  }

  late final _$saveCuentaAsyncAction =
      AsyncAction('_CuentaCobrarStoreBase.saveCuenta', context: context);

  @override
  Future<void> saveCuenta(CuentaCobrarModel cuenta,
      {List<CobroModel>? cobrosIniciales}) {
    return _$saveCuentaAsyncAction
        .run(() => super.saveCuenta(cuenta, cobrosIniciales: cobrosIniciales));
  }

  late final _$addCobroAsyncAction =
      AsyncAction('_CuentaCobrarStoreBase.addCobro', context: context);

  @override
  Future<void> addCobro(CobroModel cobro, CuentaCobrarModel cuenta) {
    return _$addCobroAsyncAction.run(() => super.addCobro(cobro, cuenta));
  }

  @override
  String toString() {
    return '''
state: ${state},
cobroState: ${cobroState}
    ''';
  }
}
