import 'package:flutter_modular/flutter_modular.dart';
import '../clientes/repositories/cliente_repository.dart';
import '../productos/repositories/producto_repository.dart';
import '../tecnicos/repositories/tecnico_repository.dart';
import 'repositories/presupuesto_repository.dart';
import 'presupuesto_store.dart';
import 'pages/presupuesto_list_page.dart';
import 'pages/presupuesto_form_page.dart';
import 'models/presupuesto_model.dart';

class PresupuestoModule extends Module {
  @override
  void binds(i) {
    i.addLazySingleton<PresupuestoRepository>(() => PresupuestoRepository());
    i.addLazySingleton<ClienteRepository>(() => ClienteRepository());
    i.addLazySingleton<ProductoRepository>(() => ProductoRepository());
    i.addLazySingleton<TecnicoRepository>(() => TecnicoRepository());
    
    i.addLazySingleton<PresupuestoStore>(() => PresupuestoStore(
      i.get<PresupuestoRepository>(),
      i.get<ClienteRepository>(),
      i.get<ProductoRepository>(),
      i.get<TecnicoRepository>(),
    ));
  }

  @override
  void routes(r) {
    r.child('/', child: (context) => const PresupuestoListPage());
    r.child('/form', child: (context) => PresupuestoFormPage(
      presupuesto: r.args.data as PresupuestoModel?,
    ));
  }
}
