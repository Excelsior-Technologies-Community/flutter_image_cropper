# 🖼️ flutter_image_cropper

```
flutter_image_cropper is a powerful and customizable image cropping library for Flutter.

It allows developers to build modern image cropping experiences similar to mobile gallery and wallpaper crop tools.

The package supports drag, pinch zoom, movable crop areas, resizable crop frames, square and circular crop modes, and accurate cropping based on the selected region.

Developers can create profile picture croppers, wallpaper editors, image editors, social media upload screens and custom gallery style crop experiences for Android, iOS, Web and Desktop.
```

---

## ✨ Features

```
- 🖐️ Drag image freely inside crop area
- 🔍 Smooth pinch zoom support
- 📐 Resize crop frame using corner handles
- 🖼️ Move crop frame anywhere on screen
- ⬜ Rectangle crop mode
- ⚪ Circle crop mode
- 🎯 Accurate crop result from selected area
- 🌑 Dark overlay outside crop region
- 📱 Gallery / wallpaper style crop experience
- ⚡ Lightweight and easy to customize
- 🌐 Supports Android, iOS, Web & Desktop
```

---

## 📦 Installation

Add dependency in your `pubspec.yaml`

```
dependencies:
  flutter_image_cropper:
    path: 
```

Then run:

```
flutter pub get
```

---

## 🎬 Preview

https://github.com/user-attachments/assets/6cd42718-7ad7-4520-ab4a-64368eb4a0c9

---

## 🗂 File Structure

```
flutter_image_cropper/
│
├─ lib/
│   ├─ flutter_image_cropper.dart
│   │   // Main export file
│   │
│   ├─  main.dart
│   │       // Example app showing cropper usage
│   │
│   └─ src/
│       ├─ crop_shape.dart
│       │   // Rectangle & circle crop types
│       │
│       ├─ image_cropper_controller.dart
│       │   // Handles crop logic and image processing
│       │
│       └─ image_cropper_widget.dart
│           // Main cropper UI widget
│
│
├─ README.md
│   // Package documentation
│
└─ pubspec.yaml
│   // Package configuration
```

---

## 🚀 How To Use

### 1️⃣ Import Package

```
import 'package:flutter_image_cropper/flutter_image_cropper.dart';
```

### 2️⃣ Create Controller

```
ImageCropperController controller = ImageCropperController();
```

### 3️⃣ Add Cropper Widget

```
ImageCropperWidget(
  imageFile: selectedImage,
  controller: controller,
  cropShape: CropShape.rectangle,
  onCropped: (value) {
    setState(() {
      croppedImage = value;
    });
  },
)
```

### 4️⃣ Circle Crop Example

```
ImageCropperWidget(
  imageFile: selectedImage,
  controller: controller,
  cropShape: CropShape.circle,
  onCropped: (value) {
    setState(() {
      croppedImage = value;
    });
  },
)
```

### 5️⃣ Show Cropped Image

```
if (croppedImage != null)
  Image.memory(croppedImage!)
```

---

## 🎨 Cropper Properties

| Property   | Type                    | Description                   |
| ---------- | ----------------------- | ----------------------------- |
| imageFile  | File                    | Image to crop                 |
| controller | ImageCropperController  | Cropper controller            |
| cropShape  | CropShape               | Rectangle or circle crop mode |
| onCropped  | ValueChanged<Uint8List> | Returns cropped image bytes   |

---

## 🧩 Example Full Usage

```
File? selectedImage;
Uint8List? croppedImage;

ImageCropperController controller = ImageCropperController();

ImageCropperWidget(
  imageFile: selectedImage!,
  controller: controller,
  cropShape: CropShape.rectangle,
  onCropped: (value) {
    setState(() {
      croppedImage = value;
    });
  },
)
```

---

## ⚙️ Supported Crop Modes

```
⬜ CropShape.rectangle
⚪ CropShape.circle
```

---

## 📄 MIT License

```
Copyright (c) 2026

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files to deal in the Software without restriction.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
```
