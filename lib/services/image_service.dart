import 'dart:io';
import 'package:path/path.dart' as p;

class ImageService {

  static String getExecutableDirectory() {
    final exePath = Platform.resolvedExecutable;
    return File(exePath).parent.path;
  }

  static Future<Directory> getImagesDirectory() async {
    final exeDir = getExecutableDirectory();

    final imagesDir = Directory('$exeDir/images');

    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    print('Executable dir: $exeDir');
    return imagesDir;
  }

  static Future<String> copyImage(File imageFile) async {

    final imagesDir = await getImagesDirectory();
    final extension = p.extension(imageFile.path);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}$extension';


    final newPath = "${imagesDir.path}/$fileName";

    final newImage = await imageFile.copy(newPath);
    print('Image copied to: $newPath');

    return newImage.path;
  }
}