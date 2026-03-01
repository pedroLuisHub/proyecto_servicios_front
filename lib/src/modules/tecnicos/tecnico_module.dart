import 'package:flutter_modular/flutter_modular.dart';
import 'repositories/tecnico_repository.dart';
import 'tecnico_store.dart';
import 'pages/tecnico_list_page.dart';
import 'pages/tecnico_form_page.dart';
import 'models/tecnico_model.dart';

class TecnicoModule extends Module {
  @override
  void binds(i) {
    i.addLazySingleton<TecnicoRepository>(() => TecnicoRepository());
    i.addLazySingleton<TecnicoStore>(() => TecnicoStore(i.get<TecnicoRepository>()));
  }

  @override
  void routes(r) {
    r.child('/', child: (context) => const TecnicoListPage());
    r.child('/form', child: (context) => TecnicoFormPage(
      tecnico: r.args.data as TecnicoModel?,
    ));
  }
}
