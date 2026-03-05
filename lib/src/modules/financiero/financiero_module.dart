import 'package:flutter_modular/flutter_modular.dart';
import 'pages/financiero_page.dart';

class FinancieroModule extends Module {
  @override
  void binds(i) {}

  @override
  void routes(r) {
    r.child('/', child: (context) => const FinancieroPage());
  }
}
