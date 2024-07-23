import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Autism Detection',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _image;
  final picker = ImagePicker();
  String _prediction = '';

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future uploadImage(File imageFile) async {
    var request = http.MultipartRequest('POST', Uri.parse('http://10.0.2.2:8000/api/predict/'));

    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    var res = await request.send();
    final respStr = await res.stream.bytesToString();

    if (res.statusCode == 200) {
      final jsonResponse = json.decode(respStr);
      setState(() {
        _prediction = 'Prediction: ${jsonResponse['prediction']} \nConfidence: ${jsonResponse['confidence']}';
      });
    } else {
      setState(() {
        _prediction = 'Failed to get prediction';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Autism Detection'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image == null
                ? const Text('No image selected.')
                : SizedBox(height: 100,
                  child: Image.file(_image!)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: getImage,
              child: const Text('Select Image'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_image != null) {
                  uploadImage(_image!);
                }
              },
              child: const Text('Upload Image'),
            ),
            const SizedBox(height: 20),
            Text(_prediction),
          ],
        ),
      ),
    );
  }
}
