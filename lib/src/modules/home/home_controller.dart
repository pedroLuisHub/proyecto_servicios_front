import 'package:image_picker/image_picker.dart';
import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'home_controller.g.dart';

class HomeController = _HomeControllerBase with _$HomeController;

abstract class _HomeControllerBase with Store {
  final ImagePicker _picker = ImagePicker();

  _HomeControllerBase() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmpresa = prefs.getString('empresaNombre');
    final savedLogo = prefs.getString('logoPath');
    if (savedEmpresa != null) empresaNombre = savedEmpresa;
    if (savedLogo != null) logoPath = savedLogo;
  }

  @observable
  String? logoPath;

  @observable
  String empresaNombre = 'Nombre de la Empresa';

  @action
  Future<void> setEmpresaNombre(String nombre) async {
    empresaNombre = nombre;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('empresaNombre', nombre);
  }

  @action
  Future<void> selectLogo() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      logoPath = image.path;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('logoPath', image.path);
    }
  }
}
