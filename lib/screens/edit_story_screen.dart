import 'dart:convert'; // For JSON encoding
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as image_pkg;
import 'package:image_picker/image_picker.dart'; // For image picker

class ChooseImageScreen extends StatelessWidget {
  final ImagePicker _picker = ImagePicker();

  Future<void> _selectImage(BuildContext context) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditStoryScreen(selectedImagePath: pickedFile.path),
        ),
      );
    }
  }

  Future<void> _takePhoto(BuildContext context) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditStoryScreen(selectedImagePath: pickedFile.path),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose or Take Photo'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return Wrap(
                  children: [
                    ListTile(
                      leading: Icon(Icons.photo_library),
                      title: Text('Choose from Gallery'),
                      onTap: () {
                        _selectImage(context);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.camera_alt),
                      title: Text('Take a Photo'),
                      onTap: () {
                        _takePhoto(context);
                      },
                    ),
                  ],
                );
              },
            );
          },
          child: Text('Select Image'),
        ),
      ),
    );
  }
}

class EditStoryScreen extends StatefulWidget {
  final String selectedImagePath;

  EditStoryScreen({Key? key, required this.selectedImagePath}) : super(key: key);

  @override
  _EditStoryScreenState createState() => _EditStoryScreenState();
}

class _EditStoryScreenState extends State<EditStoryScreen> {
  late String _imagePath;
  late image_pkg.Image _originalImage;

  @override
  void initState() {
    super.initState();
    _imagePath = widget.selectedImagePath;
    _loadImage();
  }

  Future<void> _loadImage() async {
    final file = File(_imagePath);
    final data = await file.readAsBytes();
    _originalImage = image_pkg.decodeImage(Uint8List.fromList(data))!;
    setState(() {});
  }

  void _saveImage() async {
    final editedFile = File(_imagePath);
    final imageBytes = image_pkg.encodeJpg(_originalImage)!;
    editedFile.writeAsBytesSync(imageBytes);

    Navigator.pop(context, editedFile.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Story'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveImage,
          ),
        ],
      ),
      body: Center(
        child: Image.file(
          File(_imagePath),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
