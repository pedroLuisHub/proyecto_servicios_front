import '../../../core/models/item_detalle_model.dart';
import '../../../core/models/repuesto_detalle_model.dart';

class PresupuestoModel {
  final int? id;
  final int clienteId;
  final double precioTotal;
  final DateTime fecha;
  final String estado;
  final int? tecnicoId;
  final String? nombreTecnico;
  final List<String> imagenes;

  // Detalles / Items
  final List<ItemDetalleModel> detalles;
  final List<RepuestoDetalleModel> repuestos;

  // Campo opcional para UI
  String? nombreCliente;

  PresupuestoModel({
    this.id,
    required this.clienteId,
    required this.precioTotal,
    required this.fecha,
    required this.estado,
    this.tecnicoId,
    this.nombreTecnico,
    this.imagenes = const [],
    this.detalles = const [],
    this.repuestos = const [],
    this.nombreCliente,
  });

  factory PresupuestoModel.fromDbMap(Map<String, dynamic> map, {List<ItemDetalleModel>? detalles, List<RepuestoDetalleModel>? repuestos}) {
    return PresupuestoModel(
      id: map['id'] as int?,
      clienteId: map['clienteId'] as int,
      precioTotal: (map['precioTotal'] as num).toDouble(),
      fecha: DateTime.parse(map['fecha'] as String),
      estado: map['estado'] as String,
      tecnicoId: map['tecnicoId'] as int?,
      nombreTecnico: map['nombreTecnico'] as String?,
      imagenes: map['imagenes'] != null && (map['imagenes'] as String).isNotEmpty
          ? (map['imagenes'] as String).split(',')
          : [],
      detalles: detalles ?? [],
      repuestos: repuestos ?? [],
    );
  }

  Map<String, dynamic> toDbMap() {
    return {
      'clienteId': clienteId,
      'precioTotal': precioTotal,
      'fecha': fecha.toIso8601String(),
      'estado': estado,
      'tecnicoId': tecnicoId,
      'nombreTecnico': nombreTecnico,
      'imagenes': imagenes.join(','),
    };
  }
}
