import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../modules/presupuestos/models/presupuesto_model.dart';
import '../../modules/servicios/models/servicio_model.dart';

class PdfService {
  static Future<void> generateAndSharePresupuesto(PresupuestoModel presupuesto) async {
    final pdf = pw.Document();

    // Diseño del PDF
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Cabecera
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Sistema de Servicios', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Presupuesto de Reparación', style: const pw.TextStyle(fontSize: 16, color: PdfColors.grey)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Nro: #${presupuesto.id ?? "-"}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Fecha: ${presupuesto.fecha.day}/${presupuesto.fecha.month}/${presupuesto.fecha.year}'),
                      pw.Text('Estado: ${presupuesto.estado}', style: pw.TextStyle(color: _getColor(presupuesto.estado))),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),

              // Cliente
              pw.Text('Datos del Cliente:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.Divider(),
              pw.Text('Nombre/Razón Social: ${presupuesto.nombreCliente ?? "Desconocido"}'),
              pw.SizedBox(height: 20),

              // Detalles
              pw.Text('Detalles del Trabajo:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              _buildTable(presupuesto),
              
              pw.SizedBox(height: 30),
              
              // Total
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text(
                    'TOTAL ESTIMADO: Gs. ${presupuesto.precioTotal.toStringAsFixed(0)}',
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),

              pw.Spacer(),
              pw.Divider(),
              pw.Center(
                child: pw.Text(
                  'Este documento es un presupuesto estimado y está sujeto a cambios tras la revisión final del dispositivo.',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );

    // Guardar archivo temporalmente
    final bytes = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/Presupuesto_${presupuesto.id}.pdf');
    await file.writeAsBytes(bytes);

    // Compartir usando el archivo generado
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Adjunto el presupuesto #${presupuesto.id} para su revisión.',
    );
  }

  static pw.Widget _buildTable(PresupuestoModel presupuesto) {
    return pw.TableHelper.fromTextArray(
      headers: ['Descripción', 'Disp/Marca/Modelo', 'Precio'],
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerRight,
      },
      data: presupuesto.detalles.map((item) {
        final specs = [item.nombreDispositivo, item.nombreMarca, item.nombreModelo]
            .where((e) => e != null)
            .join(' / ');
            
        return [
          item.descripcion,
          specs.isEmpty ? '-' : specs,
          'Gs. ${item.precio.toStringAsFixed(0)}',
        ];
      }).toList(),
    );
  }

  static Future<void> generateAndShareServicio(ServicioModel servicio) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Cabecera
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Sistema de Servicios', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Orden de Servicio', style: const pw.TextStyle(fontSize: 16, color: PdfColors.grey)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Nro: #${servicio.id ?? "-"}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Fecha: ${servicio.fechaProgramada.day}/${servicio.fechaProgramada.month}/${servicio.fechaProgramada.year}'),
                      pw.Text('Estado: ${servicio.estado}', style: pw.TextStyle(color: _getColor(servicio.estado))),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),

              // Cliente y Técnico
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Datos del Cliente:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 5),
                      pw.Text('${servicio.nombreCliente ?? "Desconocido"}'),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Técnico Asignado:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 5),
                      pw.Text('${servicio.nombreTecnico ?? "Desconocido"}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Divider(),

              // Trabajos
              if (servicio.detalles.isNotEmpty) ...[
                pw.Text('Trabajos / Mano de Obra:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.TableHelper.fromTextArray(
                  headers: ['Descripción', 'Equipo', 'Precio'],
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
                  cellAlignments: {0: pw.Alignment.centerLeft, 1: pw.Alignment.centerLeft, 2: pw.Alignment.centerRight},
                  data: servicio.detalles.map((item) {
                    final specs = [item.nombreDispositivo, item.nombreMarca, item.nombreModelo].where((e) => e != null).join(' / ');
                    return [item.descripcion, specs.isEmpty ? '-' : specs, 'Gs. ${item.precio.toStringAsFixed(0)}'];
                  }).toList(),
                ),
                pw.SizedBox(height: 20),
              ],

              // Repuestos
              if (servicio.repuestos.isNotEmpty) ...[
                pw.Text('Repuestos Utilizados:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.TableHelper.fromTextArray(
                  headers: ['Repuesto', 'Cant. x Precio', 'Subtotal'],
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
                  cellAlignments: {0: pw.Alignment.centerLeft, 1: pw.Alignment.centerRight, 2: pw.Alignment.centerRight},
                  data: servicio.repuestos.map((item) {
                    return [item.nombreProducto, '${item.cantidad.toStringAsFixed(0)} x Gs. ${item.precioUnitario.toStringAsFixed(0)}', 'Gs. ${item.subtotal.toStringAsFixed(0)}'];
                  }).toList(),
                ),
                pw.SizedBox(height: 20),
              ],
              
              // Total
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text(
                    'TOTAL A COBRAR: Gs. ${servicio.precioTotal.toStringAsFixed(0)}',
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),

              pw.Spacer(),
              pw.Divider(),
              pw.Center(
                child: pw.Text(
                  'Gracias por confiar en nuestro servicio técnico.',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/Servicio_${servicio.id}.pdf');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Adjunto la orden de servicio #${servicio.id}.',
    );
  }

  static PdfColor _getColor(String estado) {
    if (estado == 'CONFIRMADO' || estado == 'FINALIZADO') return PdfColors.green;
    if (estado == 'RECHAZADO' || estado == 'CANCELADO') return PdfColors.red;
    return PdfColors.orange;
  }
}
