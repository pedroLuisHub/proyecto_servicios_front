import 'package:flutter_modular/flutter_modular.dart';
import 'cuenta_cobrar_store.dart';
import 'pages/cuenta_cobrar_list_page.dart';
import 'pages/cuenta_cobrar_detail_page.dart';

class CuentaCobrarModule extends Module {
  @override
  void binds(i) {
    i.addSingleton(CuentaCobrarStore.new);
  }

  @override
  void routes(r) {
    r.child('/', child: (context) => const CuentaCobrarListPage());
    r.child('/detail',
        child: (context) => CuentaCobrarDetailPage(cuenta: r.args.data));
  }
}
