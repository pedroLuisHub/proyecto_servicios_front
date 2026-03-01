class AjusteDetalleModel {
  final int? id;
  int? ajusteId;
  final int productoId;
  final String nombreProducto;
  final double cantidad;

  AjusteDetalleModel({
    this.id,
    this.ajusteId,
    required this.productoId,
    required this.nombreProducto,
    required this.cantidad,
  });

  factory AjusteDetalleModel.fromDbMap(Map<String, dynamic> map) {
    return AjusteDetalleModel(
      id: map['id'] as int?,
      ajusteId: map['ajusteId'] as int?,
      productoId: map['productoId'] as int,
      nombreProducto: map['nombreProducto'] as String? ?? '',
      cantidad: (map['cantidad'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toDbMap() {
    return {
      'ajusteId': ajusteId,
      'productoId': productoId,
      'cantidad': cantidad,
    };
  }
}

class AjusteInventarioModel {
  final int? id;
  final String tipo; // 'ENTRADA' o 'SALIDA'
  final String observacion;
  final DateTime fecha;
  final List<AjusteDetalleModel> detalles;

  AjusteInventarioModel({
    this.id,
    required this.tipo,
    required this.observacion,
    required this.fecha,
    this.detalles = const [],
  });

  factory AjusteInventarioModel.fromDbMap(Map<String, dynamic> map, {List<AjusteDetalleModel>? detalles}) {
    return AjusteInventarioModel(
      id: map['id'] as int?,
      tipo: map['tipo'] as String,
      observacion: map['observacion'] as String,
      fecha: DateTime.parse(map['fecha'] as String),
      detalles: detalles ?? [],
    );
  }

  Map<String, dynamic> toDbMap() {
    return {
      'tipo': tipo,
      'observacion': observacion,
      'fecha': fecha.toIso8601String(),
    };
  }
}
