import '../../../core/database/database_helper.dart';
import '../models/cliente_model.dart';

class ClienteRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<List<ClienteModel>> getAll() async {
    final db = await dbHelper.database;
    final result = await db.query('clientes');
    return result.map((json) => _fromDbMap(json)).toList();
  }

  Future<ClienteModel> getById(int id) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'clientes',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return _fromDbMap(maps.first);
    } else {
      throw Exception('ID $id no encontrado');
    }
  }

  Future<ClienteModel> save(ClienteModel cliente) async {
    final db = await dbHelper.database;
    final id = await db.insert('clientes', _toDbMap(cliente));
    
    // Devolvemos una copia del cliente pero con el ID que asignó la BD
    return ClienteModel(
      id: id,
      ruc: cliente.ruc,
      nombre: cliente.nombre,
      telefono: cliente.telefono,
      email: cliente.email,
      direccion: cliente.direccion,
      latitud: cliente.latitud,
      longitud: cliente.longitud,
      estado: cliente.estado,
    );
  }

  Future<ClienteModel> update(int id, ClienteModel cliente) async {
    final db = await dbHelper.database;
    await db.update(
      'clientes',
      _toDbMap(cliente),
      where: 'id = ?',
      whereArgs: [id],
    );
    return cliente;
  }

  Future<void> delete(int id) async {
    final db = await dbHelper.database;
    await db.delete(
      'clientes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Helpers para convertir entre SQLite y ClienteModel ---
  // SQLite guarda los booleanos como 0 y 1, JSON lo hace como true/false

  Map<String, dynamic> _toDbMap(ClienteModel cliente) {
    return {
      'ruc': cliente.ruc,
      'nombre': cliente.nombre,
      'telefono': cliente.telefono,
      'email': cliente.email,
      'direccion': cliente.direccion,
      'latitud': cliente.latitud,
      'longitud': cliente.longitud,
      'estado': cliente.estado ? 1 : 0,
    };
  }

  ClienteModel _fromDbMap(Map<String, Object?> map) {
    return ClienteModel(
      id: map['id'] as int?,
      ruc: map['ruc'] as String,
      nombre: map['nombre'] as String,
      telefono: map['telefono'] as String?,
      email: map['email'] as String?,
      direccion: map['direccion'] as String?,
      latitud: (map['latitud'] as num?)?.toDouble(),
      longitud: (map['longitud'] as num?)?.toDouble(),
      estado: map['estado'] == 1,
    );
  }
}
