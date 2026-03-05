// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$HomeController on _HomeControllerBase, Store {
  late final _$logoPathAtom =
      Atom(name: '_HomeControllerBase.logoPath', context: context);

  @override
  String? get logoPath {
    _$logoPathAtom.reportRead();
    return super.logoPath;
  }

  @override
  set logoPath(String? value) {
    _$logoPathAtom.reportWrite(value, super.logoPath, () {
      super.logoPath = value;
    });
  }

  late final _$empresaNombreAtom =
      Atom(name: '_HomeControllerBase.empresaNombre', context: context);

  @override
  String get empresaNombre {
    _$empresaNombreAtom.reportRead();
    return super.empresaNombre;
  }

  @override
  set empresaNombre(String value) {
    _$empresaNombreAtom.reportWrite(value, super.empresaNombre, () {
      super.empresaNombre = value;
    });
  }

  late final _$setEmpresaNombreAsyncAction =
      AsyncAction('_HomeControllerBase.setEmpresaNombre', context: context);

  @override
  Future<void> setEmpresaNombre(String nombre) {
    return _$setEmpresaNombreAsyncAction
        .run(() => super.setEmpresaNombre(nombre));
  }

  late final _$selectLogoAsyncAction =
      AsyncAction('_HomeControllerBase.selectLogo', context: context);

  @override
  Future<void> selectLogo() {
    return _$selectLogoAsyncAction.run(() => super.selectLogo());
  }

  @override
  String toString() {
    return '''
logoPath: ${logoPath},
empresaNombre: ${empresaNombre}
    ''';
  }
}
