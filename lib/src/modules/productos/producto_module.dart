import 'package:flutter_modular/flutter_modular.dart';
import 'repositories/producto_repository.dart';
import 'repositories/ajuste_repository.dart';
import 'producto_store.dart';
import 'ajuste_store.dart';
import 'pages/producto_list_page.dart';
import 'pages/producto_form_page.dart';
import 'pages/ajuste_form_page.dart';
import 'models/producto_model.dart';

class ProductoModule extends Module {
  @override
  void binds(i) {
    i.addLazySingleton<ProductoRepository>(() => ProductoRepository());
    i.addLazySingleton<ProductoStore>(() => ProductoStore(i.get<ProductoRepository>()));
    
    i.addLazySingleton<AjusteRepository>(() => AjusteRepository());
    i.addLazySingleton<AjusteStore>(() => AjusteStore(i.get<AjusteRepository>(), i.get<ProductoRepository>()));
  }

  @override
  void routes(r) {
    r.child('/', child: (context) => const ProductoListPage());
    r.child('/form', child: (context) => ProductoFormPage(
      producto: r.args.data as ProductoModel?,
    ));
    r.child('/ajuste', child: (context) => const AjusteFormPage());
  }
}
