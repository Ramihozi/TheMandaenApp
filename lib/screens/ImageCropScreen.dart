import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';


class ImageCropScreen {
  ImageCropScreen({
    ImagePicker? imagePicker,
    ImageCropper? imageCropper,
  })  : _imagePicker = imagePicker ?? ImagePicker(),
        _imageCropper = imageCropper ?? ImageCropper();

  final ImagePicker _imagePicker;
  final ImageCropper _imageCropper;

  Future<XFile?>pickImage({
    ImageSource source = ImageSource.gallery,
    int imageQuality = 95,
  }) async {
    return await _imagePicker.pickImage(
      source: source,
      imageQuality: imageQuality,
    );
  }

  Future<CroppedFile?> crop({
    required XFile file,
    CropStyle cropStyle = CropStyle.circle,
}) async =>
      await _imageCropper.cropImage(
        sourcePath: file.path,
        compressQuality: 100,
        uiSettings: [
          IOSUiSettings(),
          AndroidUiSettings(),
        ],
      );
}