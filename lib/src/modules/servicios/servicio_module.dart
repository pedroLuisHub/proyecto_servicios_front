import 'package:flutter_modular/flutter_modular.dart';
import 'package:servicio_app/src/modules/tecnicos/repositories/tecnico_repository.dart';
import 'package:servicio_app/src/modules/clientes/repositories/cliente_repository.dart';
import 'package:servicio_app/src/modules/presupuestos/repositories/presupuesto_repository.dart';
import 'package:servicio_app/src/modules/productos/repositories/producto_repository.dart';
import 'repositories/servicio_repository.dart';
import 'servicio_store.dart';
import 'pages/servicio_list_page.dart';
import 'pages/servicio_form_page.dart';
import 'models/servicio_model.dart';

class ServicioModule extends Module {
  @override
  void binds(i) {
    i.addLazySingleton<ServicioRepository>(() => ServicioRepository());
    i.addLazySingleton<TecnicoRepository>(() => TecnicoRepository());
    i.addLazySingleton<ClienteRepository>(() => ClienteRepository());
    i.addLazySingleton<PresupuestoRepository>(() => PresupuestoRepository());
    i.addLazySingleton<ProductoRepository>(() => ProductoRepository());

    i.addLazySingleton<ServicioStore>(() => ServicioStore(
          i.get<ServicioRepository>(),
          i.get<TecnicoRepository>(),
          i.get<ClienteRepository>(),
          i.get<PresupuestoRepository>(),
          i.get<ProductoRepository>(),
        ));
  }

  @override
  void routes(r) {
    r.child('/', child: (context) => const ServicioListPage());
    r.child('/form', child: (context) => ServicioFormPage(
      servicio: r.args.data as ServicioModel?,
    ));
  }
}
