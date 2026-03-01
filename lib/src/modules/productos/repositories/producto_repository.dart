import '../../../core/database/database_helper.dart';
import '../models/producto_model.dart';

class ProductoRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<List<ProductoModel>> getAll() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
      SELECT p.*, c.descripcion as nombreCategoria 
      FROM productos p 
      LEFT JOIN categorias c ON p.categoriaId = c.id
      ORDER BY p.descripcion ASC
    ''');
    
    return result.map((json) {
      final p = ProductoModel.fromDbMap(json);
      p.nombreCategoria = json['nombreCategoria'] as String?;
      return p;
    }).toList();
  }

  Future<ProductoModel?> getByCodigoBarras(String codigo) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'productos',
      where: 'codigo_barras = ?',
      whereArgs: [codigo],
    );

    if (maps.isNotEmpty) {
      return ProductoModel.fromDbMap(maps.first);
    }
    return null;
  }

  Future<ProductoModel> getById(int id) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'productos',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return ProductoModel.fromDbMap(maps.first);
    } else {
      throw Exception('Producto con ID $id no encontrado');
    }
  }

  Future<ProductoModel> save(ProductoModel producto) async {
    final db = await dbHelper.database;
    final id = await db.insert('productos', producto.toDbMap());
    return await getById(id);
  }

  Future<ProductoModel> update(int id, ProductoModel producto) async {
    final db = await dbHelper.database;
    await db.update(
      'productos',
      producto.toDbMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
    return producto;
  }

  Future<void> delete(int id) async {
    final db = await dbHelper.database;
    await db.delete(
      'productos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Método especial para descontar/aumentar stock
  Future<void> actualizarStock(int id, double variacion) async {
    final db = await dbHelper.database;
    // Esto ejecuta: UPDATE productos SET cantidad = cantidad + (-5) WHERE id = 1
    await db.rawUpdate(
      'UPDATE productos SET cantidad = cantidad + ? WHERE id = ?',
      [variacion, id]
    );
  }
}
