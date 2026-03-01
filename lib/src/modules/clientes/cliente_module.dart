import 'package:flutter_modular/flutter_modular.dart';
import 'repositories/cliente_repository.dart';
import 'cliente_store.dart';
import 'pages/cliente_list_page.dart';
import 'pages/cliente_form_page.dart';
import 'models/cliente_model.dart';

class ClienteModule extends Module {
  @override
  void binds(i) {
    i.addLazySingleton<ClienteRepository>(() => ClienteRepository());
    i.addLazySingleton<ClienteStore>(() => ClienteStore(i.get<ClienteRepository>()));
  }

  @override
  void routes(r) {
    r.child('/', child: (context) => const ClienteListPage());
    r.child('/form', child: (context) => ClienteFormPage(
      cliente: r.args.data as ClienteModel?,
    ));
  }
}
