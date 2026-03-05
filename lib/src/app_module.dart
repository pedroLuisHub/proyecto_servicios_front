import 'package:flutter_modular/flutter_modular.dart';
import 'package:servicio_app/src/modules/home/home_module.dart';
import 'package:servicio_app/src/modules/tecnicos/tecnico_module.dart';
import 'package:servicio_app/src/modules/servicios/servicio_module.dart';
import 'package:servicio_app/src/modules/clientes/cliente_module.dart';
import 'package:servicio_app/src/modules/presupuestos/presupuesto_module.dart';
import 'package:servicio_app/src/modules/productos/producto_module.dart';
import 'package:servicio_app/src/modules/catalogos/catalogo_module.dart';
import 'package:servicio_app/src/modules/cuentas_cobrar/cuenta_cobrar_module.dart';
import 'package:servicio_app/src/modules/financiero/financiero_module.dart';

import 'package:servicio_app/src/modules/cuentas_cobrar/cuenta_cobrar_store.dart';

class AppModule extends Module {
  @override
  void binds(i) {
    i.addSingleton(CuentaCobrarStore.new);
  }

  @override
  void routes(r) {
    r.module('/', module: HomeModule());
    r.module('/tecnicos', module: TecnicoModule());
    r.module('/servicios', module: ServicioModule());
    r.module('/clientes', module: ClienteModule());
    r.module('/presupuestos', module: PresupuestoModule());
    r.module('/productos', module: ProductoModule());
    r.module('/catalogos', module: CatalogoModule());
    r.module('/cuentas', module: CuentaCobrarModule());
    r.module('/financiero', module: FinancieroModule());
  }
}
