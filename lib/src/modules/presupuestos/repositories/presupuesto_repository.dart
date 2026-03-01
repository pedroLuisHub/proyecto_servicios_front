import '../../../core/database/database_helper.dart';
import '../../../core/models/item_detalle_model.dart';
import '../../../core/models/repuesto_detalle_model.dart';
import '../models/presupuesto_model.dart';

class PresupuestoRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<List<ItemDetalleModel>> _getDetalles(int presupuestoId) async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
      SELECT d.*, 
             ts.descripcion as nombreServicio,
             td.descripcion as nombreDispositivo,
             m.descripcion as nombreMarca,
             mo.descripcion as nombreModelo
      FROM presupuesto_detalles d
      LEFT JOIN tipos_servicio ts ON d.tipoServicioId = ts.id
      LEFT JOIN tipos_dispositivo td ON d.tipoDispositivoId = td.id
      LEFT JOIN marcas m ON d.marcaId = m.id
      LEFT JOIN modelos mo ON d.modeloId = mo.id
      WHERE d.presupuestoId = ?
    ''', [presupuestoId]);

    return result.map((json) => ItemDetalleModel.fromDbMap(json, 'presupuestoId')).toList();
  }

  Future<List<RepuestoDetalleModel>> _getRepuestos(int presupuestoId) async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
      SELECT r.*, p.descripcion as nombreProducto
      FROM presupuesto_repuestos r
      JOIN productos p ON r.productoId = p.id
      WHERE r.presupuestoId = ?
    ''', [presupuestoId]);

    return result.map((json) => RepuestoDetalleModel.fromDbMap(json)).toList();
  }

  Future<List<PresupuestoModel>> getAll() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
      SELECT p.*, c.nombre as nombreCliente 
      FROM presupuestos p 
      LEFT JOIN clientes c ON p.clienteId = c.id
      ORDER BY p.fecha DESC
    ''');
    
    List<PresupuestoModel> presupuestos = [];
    for (var json in result) {
      final p = PresupuestoModel.fromDbMap(json);
      p.nombreCliente = json['nombreCliente'] as String?;
      final detalles = await _getDetalles(p.id!);
      final repuestos = await _getRepuestos(p.id!);
      presupuestos.add(PresupuestoModel(
        id: p.id,
        clienteId: p.clienteId,
        precioTotal: p.precioTotal,
        fecha: p.fecha,
        estado: p.estado,
        nombreCliente: p.nombreCliente,
        detalles: detalles,
        repuestos: repuestos,
      ));
    }
    return presupuestos;
  }

  Future<PresupuestoModel> getById(int id) async {
    final db = await dbHelper.database;
    final maps = await db.query('presupuestos', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      final p = PresupuestoModel.fromDbMap(maps.first);
      final detalles = await _getDetalles(id);
      final repuestos = await _getRepuestos(id);
      return PresupuestoModel(
        id: p.id,
        clienteId: p.clienteId,
        precioTotal: p.precioTotal,
        fecha: p.fecha,
        estado: p.estado,
        detalles: detalles,
        repuestos: repuestos,
      );
    } else {
      throw Exception('ID $id no encontrado');
    }
  }

  Future<PresupuestoModel> save(PresupuestoModel presupuesto) async {
    final db = await dbHelper.database;
    
    int id = 0;
    await db.transaction((txn) async {
      id = await txn.insert('presupuestos', presupuesto.toDbMap());
      
      for (var detalle in presupuesto.detalles) {
        detalle.parentId = id;
        await txn.insert('presupuesto_detalles', detalle.toDbMap('presupuestoId'));
      }

      for (var repuesto in presupuesto.repuestos) {
        // Asignamos el ID del padre (presupuesto)
        Map<String, dynamic> repMap = repuesto.toDbMap(id);
        // Sin embargo, toDbMap(id) mapea a 'servicioId' por defecto en el modelo.
        // Lo corregimos manualmente aquí para la tabla de presupuestos
        repMap['presupuestoId'] = id;
        repMap.remove('servicioId');
        await txn.insert('presupuesto_repuestos', repMap);
      }
    });

    return await getById(id);
  }

  Future<PresupuestoModel> update(int id, PresupuestoModel presupuesto) async {
    final db = await dbHelper.database;
    
    await db.transaction((txn) async {
      await txn.update('presupuestos', presupuesto.toDbMap(), where: 'id = ?', whereArgs: [id]);
      
      await txn.delete('presupuesto_detalles', where: 'presupuestoId = ?', whereArgs: [id]);
      for (var detalle in presupuesto.detalles) {
        detalle.parentId = id;
        await txn.insert('presupuesto_detalles', detalle.toDbMap('presupuestoId'));
      }

      await txn.delete('presupuesto_repuestos', where: 'presupuestoId = ?', whereArgs: [id]);
      for (var repuesto in presupuesto.repuestos) {
        Map<String, dynamic> repMap = repuesto.toDbMap(id);
        repMap['presupuestoId'] = id;
        repMap.remove('servicioId');
        await txn.insert('presupuesto_repuestos', repMap);
      }
    });
    
    return await getById(id);
  }

  Future<void> delete(int id) async {
    final db = await dbHelper.database;
    await db.transaction((txn) async {
      await txn.delete('presupuesto_repuestos', where: 'presupuestoId = ?', whereArgs: [id]);
      await txn.delete('presupuesto_detalles', where: 'presupuestoId = ?', whereArgs: [id]);
      await txn.delete('presupuestos', where: 'id = ?', whereArgs: [id]);
    });
  }
}
