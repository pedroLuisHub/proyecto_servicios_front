import '../../../core/database/database_helper.dart';
import '../../../core/models/item_detalle_model.dart';
import '../../../core/models/repuesto_detalle_model.dart';
import '../models/servicio_model.dart';

class ServicioRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<List<ItemDetalleModel>> _getDetalles(int servicioId) async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
      SELECT d.*, 
             ts.descripcion as nombreServicio,
             td.descripcion as nombreDispositivo,
             m.descripcion as nombreMarca,
             mo.descripcion as nombreModelo
      FROM servicio_detalles d
      LEFT JOIN tipos_servicio ts ON d.tipoServicioId = ts.id
      LEFT JOIN tipos_dispositivo td ON d.tipoDispositivoId = td.id
      LEFT JOIN marcas m ON d.marcaId = m.id
      LEFT JOIN modelos mo ON d.modeloId = mo.id
      WHERE d.servicioId = ?
    ''', [servicioId]);

    return result.map((json) => ItemDetalleModel.fromDbMap(json, 'servicioId')).toList();
  }

  Future<List<RepuestoDetalleModel>> _getRepuestos(int servicioId) async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
      SELECT r.*, p.descripcion as nombreProducto
      FROM servicio_repuestos r
      JOIN productos p ON r.productoId = p.id
      WHERE r.servicioId = ?
    ''', [servicioId]);

    return result.map((json) => RepuestoDetalleModel.fromDbMap(json)).toList();
  }

  Future<List<ServicioModel>> getAll() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
      SELECT s.*, c.nombre as nombreCliente, t.nombre || ' ' || t.apellido as nombreTecnico
      FROM servicios s 
      LEFT JOIN clientes c ON s.clienteId = c.id
      LEFT JOIN tecnicos t ON s.tecnicoId = t.id
      ORDER BY s.fechaProgramada DESC
    ''');
    
    List<ServicioModel> servicios = [];
    for (var json in result) {
      final s = ServicioModel.fromDbMap(json);
      final detalles = await _getDetalles(s.id!);
      final repuestos = await _getRepuestos(s.id!);
      
      servicios.add(ServicioModel(
        id: s.id,
        presupuestoId: s.presupuestoId,
        fechaProgramada: s.fechaProgramada,
        precioTotal: s.precioTotal,
        estado: s.estado,
        clienteId: s.clienteId,
        nombreCliente: s.nombreCliente,
        tecnicoId: s.tecnicoId,
        nombreTecnico: s.nombreTecnico,
        imagenes: s.imagenes,
        detalles: detalles,
        repuestos: repuestos,
      ));
    }
    return servicios;
  }

  Future<ServicioModel> getById(int id) async {
    final db = await dbHelper.database;
    final maps = await db.query('servicios', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      final s = ServicioModel.fromDbMap(maps.first);
      final detalles = await _getDetalles(id);
      final repuestos = await _getRepuestos(id);
      
      return ServicioModel(
        id: s.id,
        presupuestoId: s.presupuestoId,
        fechaProgramada: s.fechaProgramada,
        precioTotal: s.precioTotal,
        estado: s.estado,
        clienteId: s.clienteId,
        nombreCliente: s.nombreCliente,
        tecnicoId: s.tecnicoId,
        nombreTecnico: s.nombreTecnico,
        imagenes: s.imagenes,
        detalles: detalles,
        repuestos: repuestos,
      );
    } else {
      throw Exception('ID $id no encontrado');
    }
  }

  Future<ServicioModel> save(ServicioModel servicio) async {
    final db = await dbHelper.database;
    int id = 0;
    
    await db.transaction((txn) async {
      id = await txn.insert('servicios', servicio.toDbMap());
      
      // Guardar trabajos
      for (var detalle in servicio.detalles) {
        detalle.parentId = id;
        await txn.insert('servicio_detalles', detalle.toDbMap('servicioId'));
      }
      
      // Guardar repuestos
      for (var repuesto in servicio.repuestos) {
        await txn.insert('servicio_repuestos', repuesto.toDbMap(id));
        
        // Descontamos stock si se crea como FINALIZADO
        if (servicio.estado == 'FINALIZADO') {
          await txn.rawUpdate(
            'UPDATE productos SET cantidad = cantidad - ? WHERE id = ?',
            [repuesto.cantidad, repuesto.productoId],
          );
        }
      }
    });

    return await getById(id);
  }

  Future<ServicioModel> update(int id, ServicioModel servicio) async {
    final db = await dbHelper.database;
    
    bool eraFinalizado = false;
    List<RepuestoDetalleModel> repuestosAntiguos = [];
    try {
      final old = await getById(id);
      eraFinalizado = old.estado == 'FINALIZADO';
      repuestosAntiguos = old.repuestos;
    } catch (_) {}

    await db.transaction((txn) async {
      await txn.update('servicios', servicio.toDbMap(), where: 'id = ?', whereArgs: [id]);
      
      // Actualizar trabajos
      await txn.delete('servicio_detalles', where: 'servicioId = ?', whereArgs: [id]);
      for (var detalle in servicio.detalles) {
        detalle.parentId = id;
        await txn.insert('servicio_detalles', detalle.toDbMap('servicioId'));
      }

      // LÓGICA DE INVENTARIO
      // 1. Si estaba finalizado, primero RESTAURAMOS el stock antiguo
      if (eraFinalizado) {
        for (var oldR in repuestosAntiguos) {
          await txn.rawUpdate(
            'UPDATE productos SET cantidad = cantidad + ? WHERE id = ?',
            [oldR.cantidad, oldR.productoId],
          );
        }
      }

      // Actualizar repuestos
      await txn.delete('servicio_repuestos', where: 'servicioId = ?', whereArgs: [id]);
      for (var repuesto in servicio.repuestos) {
        await txn.insert('servicio_repuestos', repuesto.toDbMap(id));

        // 2. Si AHORA está finalizado, descontamos el stock actual de la lista
        if (servicio.estado == 'FINALIZADO') {
          await txn.rawUpdate(
            'UPDATE productos SET cantidad = cantidad - ? WHERE id = ?',
            [repuesto.cantidad, repuesto.productoId],
          );
        }
      }
    });
    
    return await getById(id);
  }

  Future<void> delete(int id) async {
    final db = await dbHelper.database;
    
    bool eraFinalizado = false;
    List<RepuestoDetalleModel> repuestosAntiguos = [];
    try {
      final old = await getById(id);
      eraFinalizado = old.estado == 'FINALIZADO';
      repuestosAntiguos = old.repuestos;
    } catch (_) {}

    await db.transaction((txn) async {
      // Si eliminamos un servicio finalizado, restauramos el stock
      if (eraFinalizado) {
        for (var oldR in repuestosAntiguos) {
          await txn.rawUpdate(
            'UPDATE productos SET cantidad = cantidad + ? WHERE id = ?',
            [oldR.cantidad, oldR.productoId],
          );
        }
      }
      
      await txn.delete('servicio_repuestos', where: 'servicioId = ?', whereArgs: [id]);
      await txn.delete('servicio_detalles', where: 'servicioId = ?', whereArgs: [id]);
      await txn.delete('servicios', where: 'id = ?', whereArgs: [id]);
    });
  }
}
