import '../../../core/database/database_helper.dart';
import '../models/tecnico_model.dart';

class TecnicoRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<List<TecnicoModel>> getAll() async {
    final db = await dbHelper.database;
    final result = await db.query('tecnicos');
    return result.map((json) => _fromDbMap(json)).toList();
  }

  Future<TecnicoModel> getById(int id) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'tecnicos',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return _fromDbMap(maps.first);
    } else {
      throw Exception('ID $id no encontrado');
    }
  }

  Future<TecnicoModel> save(TecnicoModel tecnico) async {
    final db = await dbHelper.database;
    final id = await db.insert('tecnicos', _toDbMap(tecnico));
    
    return TecnicoModel(
      id: id,
      nombre: tecnico.nombre,
      apellido: tecnico.apellido,
      documento: tecnico.documento,
      telefono: tecnico.telefono,
      especialidad: tecnico.especialidad,
      estado: tecnico.estado,
    );
  }

  Future<TecnicoModel> update(int id, TecnicoModel tecnico) async {
    final db = await dbHelper.database;
    await db.update(
      'tecnicos',
      _toDbMap(tecnico),
      where: 'id = ?',
      whereArgs: [id],
    );
    return tecnico;
  }

  Future<void> delete(int id) async {
    final db = await dbHelper.database;
    await db.delete(
      'tecnicos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Map<String, dynamic> _toDbMap(TecnicoModel tecnico) {
    return {
      'nombre': tecnico.nombre,
      'apellido': tecnico.apellido,
      'documento': tecnico.documento,
      'telefono': tecnico.telefono,
      'especialidad': tecnico.especialidad,
      'estado': tecnico.estado ? 1 : 0,
    };
  }

  TecnicoModel _fromDbMap(Map<String, Object?> map) {
    return TecnicoModel(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      apellido: map['apellido'] as String,
      documento: map['documento'] as String,
      telefono: map['telefono'] as String?,
      especialidad: map['especialidad'] as String?,
      estado: map['estado'] == 1,
    );
  }
}
