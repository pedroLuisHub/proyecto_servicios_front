import '../../../core/database/database_helper.dart';
import '../models/catalogo_model.dart';

class CatalogoRepository {
  final dbHelper = DatabaseHelper.instance;
  final String tableName;

  CatalogoRepository(this.tableName);

  Future<List<CatalogoModel>> getAll() async {
    final db = await dbHelper.database;
    final result = await db.query(tableName, orderBy: 'descripcion ASC');
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
}
