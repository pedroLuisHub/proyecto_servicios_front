import 'package:image_picker/image_picker.dart';
import 'package:mobx/mobx.dart';

part 'home_controller.g.dart';

class HomeController = _HomeControllerBase with _$HomeController;

abstract class _HomeControllerBase with Store {
  final ImagePicker _picker = ImagePicker();

  @observable
  String? logoPath;

  @action
  Future<void> selectLogo() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      logoPath = image.path;
    }
  }
}
