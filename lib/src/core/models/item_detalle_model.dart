class ItemDetalleModel {
  int? id;
  int? parentId; // Puede ser presupuestoId o servicioId
  
  int? tipoDispositivoId;
  int? marcaId;
  int? modeloId;
  int? tipoServicioId;
  
  String descripcion;
  double precio;

  // Nombres de los catálogos (Opcionales, para mostrarlos en la UI fácilmente)
  String? nombreDispositivo;
  String? nombreMarca;
  String? nombreModelo;
  String? nombreServicio;

  ItemDetalleModel({
    this.id,
    this.parentId,
    this.tipoDispositivoId,
    this.marcaId,
    this.modeloId,
    this.tipoServicioId,
    required this.descripcion,
    required this.precio,
    this.nombreDispositivo,
    this.nombreMarca,
    this.nombreModelo,
    this.nombreServicio,
  });

  factory ItemDetalleModel.fromDbMap(Map<String, dynamic> map, String parentKey) {
    return ItemDetalleModel(
      id: map['id'] as int?,
      parentId: map[parentKey] as int?,
      tipoDispositivoId: map['tipoDispositivoId'] as int?,
      marcaId: map['marcaId'] as int?,
      modeloId: map['modeloId'] as int?,
      tipoServicioId: map['tipoServicioId'] as int?,
      descripcion: map['descripcion'] as String,
      precio: (map['precio'] as num).toDouble(),
      nombreDispositivo: map['nombreDispositivo'] as String?,
      nombreMarca: map['nombreMarca'] as String?,
      nombreModelo: map['nombreModelo'] as String?,
      nombreServicio: map['nombreServicio'] as String?,
    );
  }

  Map<String, dynamic> toDbMap(String parentKey) {
    return {
      parentKey: parentId,
      'tipoDispositivoId': tipoDispositivoId,
      'marcaId': marcaId,
      'modeloId': modeloId,
      'tipoServicioId': tipoServicioId,
      'descripcion': descripcion,
      'precio': precio,
    };
  }
}
