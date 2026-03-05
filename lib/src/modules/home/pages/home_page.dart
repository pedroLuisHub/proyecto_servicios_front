import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../home_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controller = Modular.get<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Servicios'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Observer(
              builder: (_) => DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                child: GestureDetector(
                  onTap: () async {
                    final nombreCtrl =
                        TextEditingController(text: controller.empresaNombre);
                    final result = await showDialog<String>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Editar Empresa'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: nombreCtrl,
                              decoration: const InputDecoration(
                                  labelText: 'Nombre de la empresa'),
                            ),
                            const SizedBox(height: 15),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context, nombreCtrl.text);
                                controller.selectLogo();
                              },
                              icon: const Icon(Icons.image),
                              label: const Text('Cambiar Logo'),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, nombreCtrl.text),
                            child: const Text('Guardar'),
                          ),
                        ],
                      ),
                    );
                    if (result != null) {
                      controller.setEmpresaNombre(result);
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (controller.logoPath != null)
                        CircleAvatar(
                          radius: 45,
                          backgroundImage:
                              FileImage(File(controller.logoPath!)),
                        )
                      else
                        const Icon(Icons.home_repair_service,
                            size: 60, color: Colors.white),
                      const SizedBox(height: 10),
                      Text(
                        controller.empresaNombre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ExpansionTile(
              leading: const Icon(Icons.handyman),
              title: const Text('Módulo de Servicios'),
              children: [
                ListTile(
                  leading: const Icon(Icons.list_alt),
                  title: const Text('Listado de Servicios'),
                  onTap: () {
                    Navigator.pop(context); // Cerrar Drawer
                    Modular.to.pushNamed('/servicios/');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.request_quote),
                  title: const Text('Presupuestos'),
                  onTap: () {
                    Navigator.pop(context);
                    Modular.to.pushNamed('/presupuestos/');
                  },
                ),
              ],
            ),
            ExpansionTile(
              leading: const Icon(Icons.people),
              title: const Text('Módulo de Clientes'),
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Listado de Clientes'),
                  onTap: () {
                    Navigator.pop(context);
                    Modular.to.pushNamed('/clientes/');
                  },
                ),
              ],
            ),
            ExpansionTile(
              leading: const Icon(Icons.engineering),
              title: const Text('Módulo de Técnicos'),
              children: [
                ListTile(
                  leading: const Icon(Icons.person_pin),
                  title: const Text('Listado de Técnicos'),
                  onTap: () {
                    Navigator.pop(context);
                    Modular.to.pushNamed('/tecnicos/');
                  },
                ),
              ],
            ),
            ExpansionTile(
              leading: const Icon(Icons.inventory_2),
              title: const Text('Módulo de Productos'),
              children: [
                ListTile(
                  leading: const Icon(Icons.list),
                  title: const Text('Inventario de Productos'),
                  onTap: () {
                    Navigator.pop(context);
                    Modular.to.pushNamed('/productos/');
                  },
                ),
              ],
            ),
            ExpansionTile(
              leading: const Icon(Icons.settings_applications),
              title: const Text('Registros Generales'),
              children: [
                ListTile(
                  leading: const Icon(Icons.devices),
                  title: const Text('Tipos de Dispositivo'),
                  onTap: () {
                    Navigator.pop(context);
                    Modular.to.pushNamed('/catalogos/tipos_dispositivo');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.branding_watermark),
                  title: const Text('Marcas'),
                  onTap: () {
                    Navigator.pop(context);
                    Modular.to.pushNamed('/catalogos/marcas');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.model_training),
                  title: const Text('Modelos'),
                  onTap: () {
                    Navigator.pop(context);
                    Modular.to.pushNamed('/catalogos/modelos');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.build),
                  title: const Text('Tipos de Servicio'),
                  onTap: () {
                    Navigator.pop(context);
                    Modular.to.pushNamed('/catalogos/tipos_servicio');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Área del Logo
            Observer(
              builder: (_) => GestureDetector(
                onTap: controller.selectLogo,
                child: Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(75),
                    border: Border.all(color: Colors.blueGrey),
                  ),
                  child: controller.logoPath == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo,
                                size: 40, color: Colors.blueGrey),
                            Text('Seleccionar Logo',
                                style: TextStyle(fontSize: 12)),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(75),
                          child: Image.file(
                            File(controller.logoPath!),
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Cuadrícula de Menú (opcional si ya está en el drawer, pero lo mantenemos para acceso rápido)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                  _MenuCard(
                    title: 'Técnicos',
                    icon: Icons.engineering,
                    color: Colors.blue,
                    onTap: () => Modular.to.pushNamed('/tecnicos/'),
                  ),
                  _MenuCard(
                    title: 'Servicios',
                    icon: Icons.handyman,
                    color: Colors.orange,
                    onTap: () => Modular.to.pushNamed('/servicios/'),
                  ),
                  _MenuCard(
                    title: 'Clientes',
                    icon: Icons.people,
                    color: Colors.green,
                    onTap: () => Modular.to.pushNamed('/clientes/'),
                  ),
                  _MenuCard(
                    title: 'Presupuestos',
                    icon: Icons.request_quote,
                    color: Colors.purple,
                    onTap: () => Modular.to.pushNamed('/presupuestos/'),
                  ),
                  _MenuCard(
                    title: 'Inventario',
                    icon: Icons.inventory_2,
                    color: Colors.teal,
                    onTap: () => Modular.to.pushNamed('/productos/'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
