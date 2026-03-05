import '../../../core/database/database_helper.dart';
import '../models/catalogo_model.dart';

class CatalogoRepository {
  final dbHelper = DatabaseHelper.instance;
  final String tableName;

  CatalogoRepository(this.tableName);

  Future<List<CatalogoModel>> getAll({Map<String, dynamic>? filters}) async {
    final db = await dbHelper.database;
    String? where;
    List<dynamic>? whereArgs;

    if (filters != null && filters.isNotEmpty) {
      where = filters.keys.map((k) => '$k = ?').join(' AND ');
      whereArgs = filters.values.toList();
    }

    final result = await db.query(
      tableName, 
      where: where, 
      whereArgs: whereArgs, 
      orderBy: 'descripcion ASC'
    );
    return result.map((json) => CatalogoModel.fromDbMap(json)).toList();
  }

  Future<CatalogoModel> save(CatalogoModel catalogo) async {
    final db = await dbHelper.database;
    final id = await db.insert(tableName, catalogo.toDbMap());
    return CatalogoModel(
      id: id,
      descripcion: catalogo.descripcion,
      estado: catalogo.estado,
    );
  }

  Future<void> update(CatalogoModel catalogo) async {
    final db = await dbHelper.database;
    await db.update(
      tableName,
      catalogo.toDbMap(),
      where: 'id = ?',
      whereArgs: [catalogo.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await dbHelper.database;
    await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
