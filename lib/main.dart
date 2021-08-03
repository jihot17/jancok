import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sweetalert/sweetalert.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Absen v1',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'ADW Absensi System'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Dio dio = new Dio();
  String latitudedata = '';
  String longtitudedata = '';
  TextEditingController nik = new TextEditingController();
  File _image;

  @override
  void initState() {
    super.initState();
    getCurlocation();
  }

  Future getImage() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 480, maxWidth: 640);
    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  Future absen(File file, var id) async {
    try {
      String url = '';
      String path1 = _image.path;
      String fileName = path1.split('/').last;
      if (id == 1) {
        url = 'http://asi.adyawinsa.com:805/main/api_masuk'; // absen Masuk
      } else {
        url = 'http://asi.adyawinsa.com:805/main/api_keluar'; // absen Keluar
      }

      FormData data = FormData.fromMap({
        "image": await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
        "nik": nik.text,
        "lokasi": latitudedata + "," + longtitudedata
      });
      var res = await dio.post(
        url,
        data: data,
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      Map<String, dynamic> rs = jsonDecode(res.data);
      if (rs['success'] == true) {
        SweetAlert.show(context,
            title: 'Success',
            subtitle: rs['msg'],
            style: SweetAlertStyle.success);
        setState(() {
          _image = null;
        });
      } else {
        SweetAlert.show(context,
            title: 'Error', subtitle: rs['msg'], style: SweetAlertStyle.error);
      }
      return res.data;
    } catch (e) {
      SweetAlert.show(context,
          title: 'Error', subtitle: "Ambil Gambar Dulu!", style: SweetAlertStyle.error);
    }
  }

  getCurlocation() async {
    final lock = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    setState(() {
      latitudedata = '${lock.latitude}';
      longtitudedata = '${lock.longitude}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 10, bottom: 10),
                width: 300,
                height: 450,
                color: Colors.grey[200],
                child: (_image == null)
                    ? IconButton(
                        onPressed: getImage,
                        icon: Icon(
                          Icons.camera_alt_rounded,
                          size: 80,
                          color: Colors.grey,
                        ))
                    : Image.file(_image),
              ),
              Container(
                padding: const EdgeInsets.only(
                    bottom: 10, top: 10, left: 30, right: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      controller: nik,
                      decoration: InputDecoration(
                          labelText: 'NIK',
                          border: OutlineInputBorder(),
                          hintText: '1234-5678',
                          prefixIcon: Icon(Icons.person)),
                    )
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 50, left: 15, right: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: Icon(Icons.arrow_right_rounded),
                      label: Text("Absen Masuk"),
                      onPressed: () async =>
                          await absen(_image, 1).then((value) => print(value)),
                      style: ElevatedButton.styleFrom(
                        textStyle: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                        padding: EdgeInsets.symmetric(
                            horizontal: 18.0, vertical: 10.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(21.0),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: Icon(Icons.arrow_left_rounded),
                      label: Text("Absen Pulang"),
                      onPressed: () async =>
                          await absen(_image, 2).then((value) => print(value)),
                      style: ElevatedButton.styleFrom(
                        textStyle: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(21.0),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
