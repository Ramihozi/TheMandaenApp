import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class ImageCropScreen extends StatefulWidget {
  final String imagePath;

  ImageCropScreen({required this.imagePath});

  @override
  _ImageCropScreenState createState() => _ImageCropScreenState();
}

class _ImageCropScreenState extends State<ImageCropScreen> {
  late PhotoViewController _controller;
  final GlobalKey _globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = PhotoViewController();
  }

  Future<void> _cropAndSave() async {
    try {
      RenderRepaintBoundary boundary =
      _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage();
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);

      if (byteData != null) {
        Uint8List pngBytes = byteData.buffer.asUint8List();

        // Compress the image
        Directory appDocDir = await getApplicationDocumentsDirectory();
        String filePath = '${appDocDir.path}/cropped_profile_image.png';
        File file = File(filePath);

        var compressedImage = await FlutterImageCompress.compressWithList(
          pngBytes,
          quality: 100, // Max quality
        );

        file.writeAsBytesSync(compressedImage);

        // Return the cropped image path to the previous screen
        Get.back(result: filePath);
      }
    } catch (e) {
      // Handle errors here
      print("Error while cropping image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adjust Image'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _cropAndSave,
          ),
        ],
      ),
      body: Stack(
        children: [
          RepaintBoundary(
            key: _globalKey,
            child: PhotoViewGallery.builder(
              itemCount: 1,
              builder: (context, index) => PhotoViewGalleryPageOptions(
                imageProvider: FileImage(File(widget.imagePath)),
                controller: _controller,
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 3.0,
              ),
              scrollPhysics: const BouncingScrollPhysics(),
              backgroundDecoration: const BoxDecoration(
                color: Colors.black,
              ),
              pageController: PageController(),
            ),
          ),
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
