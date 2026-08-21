import 'package:get/get.dart';

class MainController extends GetxController {
  final currentIndex = 0.obs;

  void changePage(int index) {
    if (index >= 0 && index < 6) {
      currentIndex.value = index;
    }
  }
}
