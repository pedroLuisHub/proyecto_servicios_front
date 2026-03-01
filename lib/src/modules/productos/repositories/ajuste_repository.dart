import '../../../core/database/database_helper.dart';
import '../models/ajuste_model.dart';

class AjusteRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<AjusteInventarioModel> save(AjusteInventarioModel ajuste) async {
    final db = await dbHelper.database;
    int id = 0;

    await db.transaction((txn) async {
      // 1. Guardar cabecera
      id = await txn.insert('ajustes_inventario', ajuste.toDbMap());

      // 2. Guardar detalles y actualizar stock
      for (var detalle in ajuste.detalles) {
        detalle.ajusteId = id;
        await txn.insert('ajuste_detalles', detalle.toDbMap());

        // 3. Actualizar cantidad en la tabla productos
        final double multiplicador = ajuste.tipo == 'ENTRADA' ? 1.0 : -1.0;
        final double variacion = detalle.cantidad * multiplicador;

        await txn.rawUpdate(
          'UPDATE productos SET cantidad = cantidad + ? WHERE id = ?',
          [variacion, detalle.productoId],
        );
      }
    });

    return AjusteInventarioModel(
      id: id,
      tipo: ajuste.tipo,
      observacion: ajuste.observacion,
      fecha: ajuste.fecha,
      detalles: ajuste.detalles,
    );
  }
}
