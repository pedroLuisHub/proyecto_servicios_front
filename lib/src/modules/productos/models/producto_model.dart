class ProductoModel {
  final int? id;
  final String? codigoBarras;
  final String descripcion;
  final int? categoriaId;
  final double costo;
  final double precioVenta;
  final int iva;
  final double cantidad;
  final String? foto;
  final bool estado;

  // Campo opcional para UI
  String? nombreCategoria;

  ProductoModel({
    this.id,
    this.codigoBarras,
    required this.descripcion,
    this.categoriaId,
    required this.costo,
    required this.precioVenta,
    this.iva = 10,
    this.cantidad = 0,
    this.foto,
    this.estado = true,
    this.nombreCategoria,
  });

  factory ProductoModel.fromDbMap(Map<String, dynamic> map) {
    return ProductoModel(
      id: map['id'] as int?,
      codigoBarras: map['codigo_barras'] as String?,
      descripcion: map['descripcion'] as String,
      categoriaId: map['categoriaId'] as int?,
      costo: (map['costo'] as num).toDouble(),
      precioVenta: (map['precio_venta'] as num).toDouble(),
      iva: map['iva'] as int? ?? 10,
      cantidad: (map['cantidad'] as num).toDouble(),
      foto: map['foto'] as String?,
      estado: map['estado'] == 1,
    );
  }

  Map<String, dynamic> toDbMap() {
    return {
      'codigo_barras': codigoBarras,
      'descripcion': descripcion,
      'categoriaId': categoriaId,
      'costo': costo,
      'precio_venta': precioVenta,
      'iva': iva,
      'cantidad': cantidad,
      'foto': foto,
      'estado': estado ? 1 : 0,
    };
  }
}
