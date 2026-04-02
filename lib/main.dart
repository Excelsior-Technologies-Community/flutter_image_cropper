import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_cropper/flutter_image_cropper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? selectedImage;
  Uint8List? croppedImage;

  ImageCropperController controller = ImageCropperController();

  Future<void> pickImage() async {
    XFile? file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (file != null) {
      setState(() {
        selectedImage = File(file.path);
        croppedImage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Image Cropper Example'),
      ),
      body: selectedImage == null
          ? Center(
        child: ElevatedButton(
          onPressed: pickImage,
          child: const Text('Pick Image'),
        ),
      )
          : Column(
        children: [
          Expanded(
            child: ImageCropperWidget(
              imageFile: selectedImage!,
              controller: controller,
              cropShape: CropShape.rectangle,
              onCropped: (value) {
                setState(() {
                  croppedImage = value;
                });
              },
            ),
          ),
          if (croppedImage != null)
            Container(
              height: 200,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
              ),
              child: Image.memory(croppedImage!),
            ),
        ],
      ),
    );
  }
}
