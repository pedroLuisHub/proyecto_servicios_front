import 'package:mobx/mobx.dart';
import '../../core/database/database_helper.dart';
import '../../core/states/ui_state.dart';
import 'models/cuenta_cobrar_model.dart';
import 'models/cobro_model.dart';

part 'cuenta_cobrar_store.g.dart';

class CuentaCobrarStore = _CuentaCobrarStoreBase with _$CuentaCobrarStore;

abstract class _CuentaCobrarStoreBase with Store {
  final dbHelper = DatabaseHelper.instance;

  @observable
  UIState state = const InitialState();

  @observable
  UIState cobroState = const InitialState();

  @action
  Future<void> loadCuentas() async {
    try {
      state = const LoadingState();
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'cuentas_cobrar',
        orderBy: 'id DESC',
      );
      final cuentas =
          maps.map((map) => CuentaCobrarModel.fromMap(map)).toList();
      state = SuccessState(cuentas);
    } catch (e) {
      state = ErrorState(e.toString());
    }
  }

  @action
  Future<void> saveCuenta(CuentaCobrarModel cuenta,
      {List<CobroModel>? cobrosIniciales}) async {
    try {
      state = LoadingState();
      final db = await dbHelper.database;

      await db.transaction((txn) async {
        int cuentaId;
        if (cuenta.id == null) {
          cuentaId = await txn.insert('cuentas_cobrar', cuenta.toMap());
        } else {
          cuentaId = cuenta.id!;
          await txn.update(
            'cuentas_cobrar',
            cuenta.toMap(),
            where: 'id = ?',
            whereArgs: [cuentaId],
          );
        }

        if (cobrosIniciales != null && cobrosIniciales.isNotEmpty) {
          for (var cobro in cobrosIniciales) {
            final nuevoCobro = CobroModel(
              cuentaCobrarId: cuentaId,
              fecha: cobro.fecha,
              monto: cobro.monto,
              metodoPago: cobro.metodoPago,
            );
            await txn.insert('cobros', nuevoCobro.toMap());
          }
        }
      });
      await loadCuentas();
    } catch (e) {
      state = ErrorState(e.toString());
    }
  }

  @action
  Future<void> addCobro(CobroModel cobro, CuentaCobrarModel cuenta) async {
    try {
      cobroState = const LoadingState();
      final db = await dbHelper.database;

      await db.transaction((txn) async {
        // 1. Insertar el cobro
        await txn.insert('cobros', cobro.toMap());

        // 2. Actualizar el saldo de la cuenta
        final nuevoSaldo = cuenta.saldo - cobro.monto;
        final nuevoEstado = nuevoSaldo <= 0 ? 'PAGADO' : 'PENDIENTE';

        await txn.update(
          'cuentas_cobrar',
          {
            'saldo': nuevoSaldo,
            'estado': nuevoEstado,
          },
          where: 'id = ?',
          whereArgs: [cuenta.id],
        );
      });

      cobroState = const SuccessState(true);
      await loadCuentas(); // reload list
    } catch (e) {
      cobroState = ErrorState(e.toString());
    }
  }

  Future<List<CobroModel>> loadCobrosPorCuenta(int cuentaId) async {
    try {
      final db = await dbHelper.database;
      final maps = await db.query(
        'cobros',
        where: 'cuentaCobrarId = ?',
        whereArgs: [cuentaId],
        orderBy: 'id ASC',
      );
      return maps.map((map) => CobroModel.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }
}
