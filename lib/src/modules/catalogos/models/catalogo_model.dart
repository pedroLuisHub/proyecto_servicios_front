class CatalogoModel {
  final int? id;
  final String descripcion;
  final bool estado;
  final int? parentId;

  CatalogoModel({
    this.id,
    required this.descripcion,
    this.estado = true,
    this.parentId,
  });

  factory CatalogoModel.fromDbMap(Map<String, dynamic> map) {
    return CatalogoModel(
      id: map['id'] as int?,
      descripcion: map['descripcion'] as String,
      estado: map['estado'] == 1,
      parentId: map.containsKey('marcaId') ? map['marcaId'] as int? : null,
    );
  }

  Map<String, dynamic> toDbMap() {
    final Map<String, dynamic> map = {
      'descripcion': descripcion,
      'estado': estado ? 1 : 0,
    };
    if (parentId != null) {
      map['marcaId'] = parentId;
    }
    return map;
  }
}
