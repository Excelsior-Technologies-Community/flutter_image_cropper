import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class ImageCropperController extends ChangeNotifier {
  double scale = 1.0;
  Offset offset = Offset.zero;

  void setScale(double value) {
    scale = value;
    notifyListeners();
  }

  void setOffset(Offset value) {
    offset = value;
    notifyListeners();
  }

  void reset() {
    scale = 1.0;
    offset = Offset.zero;
    notifyListeners();
  }

  Future<Uint8List?> cropImage({
    required File imageFile,
    required Rect cropRect,
  }) async {
    try {
      Uint8List bytes = await imageFile.readAsBytes();
      img.Image? original = img.decodeImage(bytes);

      if (original == null) {
        return null;
      }

      int x = cropRect.left.toInt();
      int y = cropRect.top.toInt();
      int width = cropRect.width.toInt();
      int height = cropRect.height.toInt();

      if (x < 0) x = 0;
      if (y < 0) y = 0;

      if (x + width > original.width) {
        width = original.width - x;
      }

      if (y + height > original.height) {
        height = original.height - y;
      }

      img.Image cropped = img.copyCrop(
        original,
        x: x,
        y: y,
        width: width,
        height: height,
      );

      return Uint8List.fromList(img.encodePng(cropped));
    } catch (e) {
      return null;
    }
  }
}
