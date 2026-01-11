import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class MediaService {
  final ImagePicker _picker = ImagePicker();

  Future<String?> pickImage({required ImageSource source}) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image == null) return null;
    return image.path;
  }

  Future<String?> cropImage({required String path}) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: path,
      aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: AppTheme.terracotta,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.ratio16x9,
            lockAspectRatio: true),
        IOSUiSettings(
          title: 'Crop Image',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
        ),
      ],
    );
    return croppedFile?.path;
  }
}
