import '../../../core/models/item_detalle_model.dart';
import '../../../core/models/repuesto_detalle_model.dart';

class ServicioModel {
  final int? id;
  final int? presupuestoId;
  final DateTime fechaProgramada;
  final double precioTotal;
  final String estado;
  final int clienteId;
  final String? nombreCliente;
  final int tecnicoId;
  final String? nombreTecnico;
  
  final List<ItemDetalleModel> detalles;
  final List<RepuestoDetalleModel> repuestos;
  final List<String> imagenes; 

  ServicioModel({
    this.id,
    this.presupuestoId,
    required this.fechaProgramada,
    required this.precioTotal,
    required this.estado,
    required this.clienteId,
    this.nombreCliente,
    required this.tecnicoId,
    this.nombreTecnico,
    this.detalles = const [],
    this.repuestos = const [],
    this.imagenes = const [],
  });

  factory ServicioModel.fromDbMap(Map<String, dynamic> map, {List<ItemDetalleModel>? detalles, List<RepuestoDetalleModel>? repuestos}) {
    return ServicioModel(
      id: map['id'] as int?,
      presupuestoId: map['presupuestoId'] as int?,
      fechaProgramada: DateTime.parse(map['fechaProgramada'] as String),
      precioTotal: (map['precioTotal'] as num).toDouble(),
      estado: map['estado'] as String,
      clienteId: map['clienteId'] as int,
      nombreCliente: map['nombreCliente'] as String?,
      tecnicoId: map['tecnicoId'] as int,
      nombreTecnico: map['nombreTecnico'] as String?,
      detalles: detalles ?? [],
      repuestos: repuestos ?? [],
      imagenes: map['imagenes'] != null && (map['imagenes'] as String).isNotEmpty
          ? (map['imagenes'] as String).split(',')
          : [],
    );
  }

  Map<String, dynamic> toDbMap() {
    return {
      'presupuestoId': presupuestoId,
      'fechaProgramada': fechaProgramada.toIso8601String(),
      'precioTotal': precioTotal,
      'estado': estado,
      'clienteId': clienteId,
      'nombreCliente': nombreCliente,
      'tecnicoId': tecnicoId,
      'nombreTecnico': nombreTecnico,
      'imagenes': imagenes.join(','), 
    };
  }
}
