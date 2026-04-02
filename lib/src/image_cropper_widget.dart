import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'crop_shape.dart';
import 'image_cropper_controller.dart';

class ImageCropperWidget extends StatefulWidget {
  final File imageFile;
  final ImageCropperController controller;
  final CropShape cropShape;
  final double cropSize;
  final ValueChanged<Uint8List>? onCropped;

  const ImageCropperWidget({
    super.key,
    required this.imageFile,
    required this.controller,
    this.cropShape = CropShape.rectangle,
    this.cropSize = 300,
    this.onCropped,
  });

  @override
  State<ImageCropperWidget> createState() => _ImageCropperWidgetState();
}

class _ImageCropperWidgetState extends State<ImageCropperWidget> {
  Offset imageOffset = Offset.zero;
  double imageScale = 1.0;

  Offset startImageOffset = Offset.zero;
  double startImageScale = 1.0;

  Rect cropRect = const Rect.fromLTWH(60, 150, 280, 400);
  Rect startCropRect = Rect.zero;

  String activeHandle = '';

  Future<void> crop() async {
    final image = await decodeImageFromList(
      await widget.imageFile.readAsBytes(),
    );

    final screenWidth = context.size!.width;
    final screenHeight = context.size!.height - 120;

    final fittedScale = math.min(
      screenWidth / image.width,
      screenHeight / image.height,
    );

    final displayedWidth = image.width * fittedScale * imageScale;
    final displayedHeight = image.height * fittedScale * imageScale;

    final imageLeft = (screenWidth - displayedWidth) / 2 + imageOffset.dx;
    final imageTop = (screenHeight - displayedHeight) / 2 + imageOffset.dy;

    final cropLeft = ((cropRect.left - imageLeft) /
        (fittedScale * imageScale))
        .clamp(0.0, image.width.toDouble());

    final cropTop = ((cropRect.top - imageTop) /
        (fittedScale * imageScale))
        .clamp(0.0, image.height.toDouble());

    final cropWidth = (cropRect.width /
        (fittedScale * imageScale))
        .clamp(1.0, image.width.toDouble() - cropLeft);

    final cropHeight = (cropRect.height /
        (fittedScale * imageScale))
        .clamp(1.0, image.height.toDouble() - cropTop);

    final result = await widget.controller.cropImage(
      imageFile: widget.imageFile,
      cropRect: Rect.fromLTWH(
        cropLeft,
        cropTop,
        cropWidth,
        cropHeight,
      ),
    );

    if (result != null) {
      widget.onCropped?.call(result);
    }
  }

  bool isInsideHandle(Offset position, Offset handle) {
    return (position - handle).distance < 25;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Expanded(
              child: GestureDetector(
                onScaleStart: (details) {
                  startImageOffset = imageOffset;
                  startImageScale = imageScale;

                  Offset p = details.localFocalPoint;

                  if (isInsideHandle(p, cropRect.topLeft)) {
                    activeHandle = 'topLeft';
                  } else if (isInsideHandle(p, cropRect.topRight)) {
                    activeHandle = 'topRight';
                  } else if (isInsideHandle(p, cropRect.bottomLeft)) {
                    activeHandle = 'bottomLeft';
                  } else if (isInsideHandle(p, cropRect.bottomRight)) {
                    activeHandle = 'bottomRight';
                  } else if (cropRect.contains(p)) {
                    activeHandle = 'moveCrop';
                    startCropRect = cropRect;
                  } else {
                    activeHandle = 'moveImage';
                  }
                },
                onScaleUpdate: (details) {
                  setState(() {
                    Offset p = details.localFocalPoint;

                    if (activeHandle == 'moveImage') {
                      imageScale =
                          (startImageScale * details.scale).clamp(1.0, 5.0);

                      imageOffset = Offset(
                        startImageOffset.dx + details.focalPointDelta.dx,
                        startImageOffset.dy + details.focalPointDelta.dy,
                      );
                    } else if (activeHandle == 'moveCrop') {
                      cropRect = startCropRect.shift(details.focalPointDelta);
                    } else if (activeHandle == 'topLeft') {
                      cropRect = Rect.fromLTRB(
                        p.dx,
                        p.dy,
                        cropRect.right,
                        cropRect.bottom,
                      );
                    } else if (activeHandle == 'topRight') {
                      cropRect = Rect.fromLTRB(
                        cropRect.left,
                        p.dy,
                        p.dx,
                        cropRect.bottom,
                      );
                    } else if (activeHandle == 'bottomLeft') {
                      cropRect = Rect.fromLTRB(
                        p.dx,
                        cropRect.top,
                        cropRect.right,
                        p.dy,
                      );
                    } else if (activeHandle == 'bottomRight') {
                      cropRect = Rect.fromLTRB(
                        cropRect.left,
                        cropRect.top,
                        p.dx,
                        p.dy,
                      );
                    }

                    if (cropRect.width < 80 || cropRect.height < 80) {
                      cropRect = Rect.fromLTWH(
                        cropRect.left,
                        cropRect.top,
                        cropRect.width < 80 ? 80 : cropRect.width,
                        cropRect.height < 80 ? 80 : cropRect.height,
                      );
                    }
                  });
                },
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(color: Colors.black),
                    ),
                    Positioned.fill(
                      child: Transform.translate(
                        offset: imageOffset,
                        child: Transform.scale(
                          scale: imageScale,
                          child: Image.file(
                            widget.imageFile,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: _CropOverlayPainter(
                            cropRect: cropRect,
                            cropShape: widget.cropShape,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              color: Colors.black,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          imageOffset = Offset.zero;
                          imageScale = 1.0;
                          cropRect = const Rect.fromLTWH(60, 150, 280, 400);
                        });
                      },
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: crop,
                      child: const Text('Crop'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CropOverlayPainter extends CustomPainter {
  final Rect cropRect;
  final CropShape cropShape;

  _CropOverlayPainter({
    required this.cropRect,
    required this.cropShape,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.55);

    final background = Path()..addRect(Offset.zero & size);

    final hole = Path();

    if (cropShape == CropShape.circle) {
      hole.addOval(cropRect);
    } else {
      hole.addRRect(
        RRect.fromRectAndRadius(cropRect, const Radius.circular(12)),
      );
    }

    final overlay = Path.combine(
      PathOperation.difference,
      background,
      hole,
    );

    canvas.drawPath(overlay, overlayPaint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    if (cropShape == CropShape.circle) {
      canvas.drawOval(cropRect, borderPaint);
    } else {
      canvas.drawRRect(
        RRect.fromRectAndRadius(cropRect, const Radius.circular(12)),
        borderPaint,
      );
    }

    final handlePaint = Paint()..color = Colors.white;

    final handles = [
      cropRect.topLeft,
      cropRect.topRight,
      cropRect.bottomLeft,
      cropRect.bottomRight,
    ];

    for (final point in handles) {
      canvas.drawCircle(point, 10, handlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CropOverlayPainter oldDelegate) {
    return oldDelegate.cropRect != cropRect ||
        oldDelegate.cropShape != cropShape;
  }
}
