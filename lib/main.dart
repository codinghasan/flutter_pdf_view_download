import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_pdf/pdf_viewer_page.dart';
import 'package:flutter_pdf/splash_screen.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const Splash(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController urlController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Center(
          child: Text('Pdf Viewer & Downloader'),
        ),
      ),
      backgroundColor: Colors.teal,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.teal.shade800),
            ),
            onPressed: () async {
              String url = '';
              final file = await pickFile();
              if (file == null) return;
              // ignore: use_build_context_synchronously
              openPdf(context, file, url);
            },
            child: const Text(
              'Press to Pick File from Local',
              style: TextStyle(color: Colors.white, fontSize: 18.0),
            ),
          ).toPadding(20.0).toExpanded(),
          TextField(
            controller: urlController,
            obscureText: false,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Enter The URL',
              hintStyle: TextStyle(color: Colors.white),
            ),
            textAlign: TextAlign.start,
          ).toExpanded().toMargin(30.0),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.teal.shade800),
            ),
            onPressed: () async {
              var inputUser = urlController.text.toString();
              var url = inputUser;
              var file = await loadPdfFromNetwork(url);
              // ignore: use_build_context_synchronously
              openPdf(context, file, url);
            },
            child: const Text(
              'Press to Load File from Network',
              style: TextStyle(color: Colors.white, fontSize: 18.0),
            ),
          ).toPadding(20.0).toExpanded(),
        ],
      ),
    );
  }

  Future<File?> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null) return null;
    return File(result.paths.first ?? '');
  }

  Future<File> loadPdfFromNetwork(String url) async {
    final response = await http.get(Uri.parse(url));
    final bytes = response.bodyBytes;
    return _storeFile(url, bytes);
  }

  Future<File> _storeFile(String url, List<int> bytes) async {
    final filename = basename(url);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);
    if (kDebugMode) {
      print('$file');
    }
    return file;
  }

  //final file = File('example.pdf');
  //await file.writeAsBytes(await pdf.save());

  void openPdf(BuildContext context, File file, String url) =>
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PdfViewerPage(
            file: file,
            url: url,
          ),
        ),
      );
}

extension WidgetExtensions on Widget {
  Widget toCenter() => Center(child: this);
  Widget toExpanded() => Expanded(child: this);
  Widget toMargin(double margin) => Container(
        margin: EdgeInsets.all(margin),
        child: this,
      );
  Widget toPadding(double padding) => Container(
        padding: EdgeInsets.all(padding),
        child: this,
      );
}
