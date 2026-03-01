class RepuestoDetalleModel {
  int? id;
  int? servicioId;
  final int productoId;
  final String nombreProducto;
  final double cantidad;
  final double precioUnitario;
  final double subtotal;

  RepuestoDetalleModel({
    this.id,
    this.servicioId,
    required this.productoId,
    required this.nombreProducto,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  factory RepuestoDetalleModel.fromDbMap(Map<String, dynamic> map) {
    return RepuestoDetalleModel(
      id: map['id'] as int?,
      servicioId: map['servicioId'] as int?,
      productoId: map['productoId'] as int,
      nombreProducto: map['nombreProducto'] as String? ?? '',
      cantidad: (map['cantidad'] as num).toDouble(),
      precioUnitario: (map['precioUnitario'] as num).toDouble(),
      subtotal: (map['subtotal'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toDbMap(int parentId) {
    return {
      'servicioId': parentId,
      'productoId': productoId,
      'cantidad': cantidad,
      'precioUnitario': precioUnitario,
      'subtotal': subtotal,
    };
  }
}
