import 'package:flutter_modular/flutter_modular.dart';
import 'catalogo_store.dart';
import 'pages/catalogo_page.dart';

class CatalogoModule extends Module {
  @override
  void binds(i) {
    i.add(CatalogoStore.new);
  }

  @override
  void routes(r) {
    // Definimos rutas para cada tipo de catálogo
    r.child('/tipos_dispositivo', child: (context) => const CatalogoPage(title: 'Tipos de Dispositivo', tableName: 'tipos_dispositivo'));
    r.child('/marcas', child: (context) => const CatalogoPage(title: 'Marcas', tableName: 'marcas'));
    r.child('/modelos', child: (context) => const CatalogoPage(title: 'Modelos', tableName: 'modelos'));
    r.child('/tipos_servicio', child: (context) => const CatalogoPage(title: 'Tipos de Servicio', tableName: 'tipos_servicio'));
  }
}
