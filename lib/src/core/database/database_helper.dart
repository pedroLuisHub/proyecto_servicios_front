import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('servicios_local.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, filePath);

    return await openDatabase(
      path,
      version: 11,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    await db.execute('DROP TABLE IF EXISTS cobros');
    await db.execute('DROP TABLE IF EXISTS cuentas_cobrar');
    await db.execute('DROP TABLE IF EXISTS servicio_repuestos');
    await db.execute('DROP TABLE IF EXISTS presupuesto_repuestos');
    await db.execute('DROP TABLE IF EXISTS ajuste_detalles');
    await db.execute('DROP TABLE IF EXISTS ajustes_inventario');
    await db.execute('DROP TABLE IF EXISTS servicio_detalles');
    await db.execute('DROP TABLE IF EXISTS presupuesto_detalles');
    await db.execute('DROP TABLE IF EXISTS servicios');
    await db.execute('DROP TABLE IF EXISTS presupuestos');
    await db.execute('DROP TABLE IF EXISTS productos');
    await db.execute('DROP TABLE IF EXISTS clientes');
    await db.execute('DROP TABLE IF EXISTS tecnicos');
    await db.execute('DROP TABLE IF EXISTS tipos_servicio');
    await db.execute('DROP TABLE IF EXISTS tipos_dispositivo');
    await db.execute('DROP TABLE IF EXISTS marcas');
    await db.execute('DROP TABLE IF EXISTS modelos');
    await db.execute('DROP TABLE IF EXISTS categorias');
    await _createDB(db, newVersion);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT';
    const textTypeNotNull = 'TEXT NOT NULL';
    const boolType = 'INTEGER NOT NULL DEFAULT 1';
    const doubleType = 'REAL';

    // ---- TABLAS CATÁLOGO ----
    await db.execute(
        'CREATE TABLE tipos_servicio (id $idType, descripcion $textTypeNotNull, estado $boolType)');
    await db.execute(
        'CREATE TABLE tipos_dispositivo (id $idType, descripcion $textTypeNotNull, estado $boolType)');
    await db.execute(
        'CREATE TABLE marcas (id $idType, descripcion $textTypeNotNull, estado $boolType)');
    await db.execute(
        'CREATE TABLE modelos (id $idType, marcaId INTEGER, descripcion $textTypeNotNull, estado $boolType)');
    await db.execute(
        'CREATE TABLE categorias (id $idType, descripcion $textTypeNotNull, estado $boolType)');

    // ---- TABLA PRODUCTOS (INVENTARIO) ----
    await db.execute('''
      CREATE TABLE productos (
        id $idType,
        codigo_barras $textType,
        descripcion $textTypeNotNull,
        categoriaId INTEGER,
        costo $doubleType NOT NULL,
        precio_venta $doubleType NOT NULL,
        iva INTEGER NOT NULL DEFAULT 10,
        cantidad $doubleType NOT NULL DEFAULT 0,
        foto $textType,
        estado $boolType,
        FOREIGN KEY (categoriaId) REFERENCES categorias (id)
      )
    ''');

    // ---- TABLAS MAESTRAS ----
    await db.execute('''
      CREATE TABLE tecnicos (
        id $idType,
        nombre $textTypeNotNull,
        apellido $textType,
        documento $textType UNIQUE,
        telefono $textType,
        especialidad $textType,
        estado $boolType
      )
    ''');

    await db.execute('''
      CREATE TABLE clientes (
        id $idType,
        ruc $textType UNIQUE,
        nombre $textTypeNotNull,
        telefono $textType,
        email $textType,
        direccion $textType,
        latitud $doubleType,
        longitud $doubleType,
        estado $boolType
      )
    ''');

    // ---- TABLA AJUSTES DE INVENTARIO ----
    await db.execute('''
      CREATE TABLE ajustes_inventario (
        id $idType,
        tipo $textTypeNotNull,
        observacion $textType,
        fecha $textTypeNotNull
      )
    ''');

    await db.execute('''
      CREATE TABLE ajuste_detalles (
        id $idType,
        ajusteId INTEGER NOT NULL,
        productoId INTEGER NOT NULL,
        cantidad $doubleType NOT NULL,
        FOREIGN KEY (ajusteId) REFERENCES ajustes_inventario (id) ON DELETE CASCADE,
        FOREIGN KEY (productoId) REFERENCES productos (id)
      )
    ''');

    // ---- TABLA PRESUPUESTOS (CABECERA) ----
    await db.execute('''
      CREATE TABLE presupuestos (
        id $idType,
        clienteId INTEGER NOT NULL,
        precioTotal $doubleType NOT NULL,
        fecha $textTypeNotNull,
        estado $textTypeNotNull,
        tecnicoId INTEGER,
        nombreTecnico $textType,
        imagenes $textType,
        FOREIGN KEY (clienteId) REFERENCES clientes (id),
        FOREIGN KEY (tecnicoId) REFERENCES tecnicos (id)
      )
    ''');

    // ---- TABLA PRESUPUESTOS (DETALLES / ITEMS) ----
    await db.execute('''
      CREATE TABLE presupuesto_detalles (
        id $idType,
        presupuestoId INTEGER NOT NULL,
        tipoDispositivoId INTEGER,
        marcaId INTEGER,
        modeloId INTEGER,
        tipoServicioId INTEGER,
        descripcion $textTypeNotNull,
        precio $doubleType NOT NULL,
        FOREIGN KEY (presupuestoId) REFERENCES presupuestos (id) ON DELETE CASCADE
      )
    ''');

    // ---- TABLA PRESUPUESTOS (REPUESTOS) ----
    await db.execute('''
      CREATE TABLE presupuesto_repuestos (
        id $idType,
        presupuestoId INTEGER NOT NULL,
        productoId INTEGER NOT NULL,
        cantidad $doubleType NOT NULL,
        precioUnitario $doubleType NOT NULL,
        subtotal $doubleType NOT NULL,
        FOREIGN KEY (presupuestoId) REFERENCES presupuestos (id) ON DELETE CASCADE,
        FOREIGN KEY (productoId) REFERENCES productos (id)
      )
    ''');

    // ---- TABLA SERVICIOS (CABECERA) ----
    await db.execute('''
      CREATE TABLE servicios (
        id $idType,
        presupuestoId INTEGER,
        fechaProgramada $textTypeNotNull,
        precioTotal $doubleType NOT NULL,
        estado $textTypeNotNull,
        observacion $textType,
        clienteId INTEGER NOT NULL,
        nombreCliente $textType,
        tecnicoId INTEGER,
        nombreTecnico $textType,
        imagenes $textType,
        FOREIGN KEY (clienteId) REFERENCES clientes (id),
        FOREIGN KEY (tecnicoId) REFERENCES tecnicos (id),
        FOREIGN KEY (presupuestoId) REFERENCES presupuestos (id)
      )
    ''');

    // ---- TABLA SERVICIOS (TRABAJOS A REALIZAR) ----
    await db.execute('''
      CREATE TABLE servicio_detalles (
        id $idType,
        servicioId INTEGER NOT NULL,
        tipoDispositivoId INTEGER,
        marcaId INTEGER,
        modeloId INTEGER,
        tipoServicioId INTEGER,
        descripcion $textTypeNotNull,
        precio $doubleType NOT NULL,
        FOREIGN KEY (servicioId) REFERENCES servicios (id) ON DELETE CASCADE
      )
    ''');

    // ---- TABLA SERVICIOS (REPUESTOS UTILIZADOS) ----
    await db.execute('''
      CREATE TABLE servicio_repuestos (
        id $idType,
        servicioId INTEGER NOT NULL,
        productoId INTEGER NOT NULL,
        cantidad $doubleType NOT NULL,
        precioUnitario $doubleType NOT NULL,
        subtotal $doubleType NOT NULL,
        FOREIGN KEY (servicioId) REFERENCES servicios (id) ON DELETE CASCADE,
        FOREIGN KEY (productoId) REFERENCES productos (id)
      )
    ''');

    // ---- TABLA CUENTAS POR COBRAR ----
    await db.execute('''
      CREATE TABLE cuentas_cobrar (
        id $idType,
        servicioId INTEGER,
        clienteId INTEGER NOT NULL,
        nombreCliente $textTypeNotNull,
        rucCliente $textType,
        fechaEmision $textTypeNotNull,
        fechaVencimiento $textTypeNotNull,
        total $doubleType NOT NULL,
        saldo $doubleType NOT NULL,
        estado $textTypeNotNull,
        FOREIGN KEY (servicioId) REFERENCES servicios (id),
        FOREIGN KEY (clienteId) REFERENCES clientes (id)
      )
    ''');

    // ---- TABLA COBROS ----
    await db.execute('''
      CREATE TABLE cobros (
        id $idType,
        cuentaCobrarId INTEGER NOT NULL,
        fecha $textTypeNotNull,
        monto $doubleType NOT NULL,
        metodoPago $textTypeNotNull,
        FOREIGN KEY (cuentaCobrarId) REFERENCES cuentas_cobrar (id) ON DELETE CASCADE
      )
    ''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
