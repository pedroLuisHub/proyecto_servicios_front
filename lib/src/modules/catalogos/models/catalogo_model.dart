class CatalogoModel {
  final int? id;
  final String descripcion;
  final bool estado;

  CatalogoModel({
    this.id,
    required this.descripcion,
    this.estado = true,
  });

  factory CatalogoModel.fromDbMap(Map<String, dynamic> map) {
    return CatalogoModel(
      id: map['id'] as int?,
      descripcion: map['descripcion'] as String,
      estado: map['estado'] == 1,
    );
  }

  Map<String, dynamic> toDbMap() {
    return {
      'descripcion': descripcion,
      'estado': estado ? 1 : 0,
    };
  }
}
