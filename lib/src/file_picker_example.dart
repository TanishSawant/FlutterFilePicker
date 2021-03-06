//import 'dart:html';
import 'dart:io';
//import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_plugin_pdf_viewer/flutter_plugin_pdf_viewer.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';

class FileStorageConnector extends StatefulWidget {
  @override
  _FilePickerDemoState createState() => new _FilePickerDemoState();
}

class _FilePickerDemoState extends State<FileStorageConnector> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _fileName;
  String _path;
  Map<String, String> _paths;
  String _extension;
  bool _loadingPath = false;
  //bool _multiPick = false;
  FileType _pickingType = FileType.any;
  TextEditingController _controller = new TextEditingController();

  static File pdfFile;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => _extension = _controller.text);
    //initPDF();
  }

  void _openFileExplorer() async {
    setState(() => _loadingPath = true);
    try { 
        _paths = null;
        _path = await FilePicker.getFilePath(
            type: _pickingType,
            allowedExtensions: (_extension?.isNotEmpty ?? false)
                ? _extension?.replaceAll(' ', '')?.split(',')
                : null);
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    }
    if (!mounted) return;
    setState(() {
      _loadingPath = false;
      _fileName = _path != null
          ? _path.split('/').last
          : _paths != null ? _paths.keys.toString() : '...';
    });
    
  }

  void _selectFolder() {
    FilePicker.getDirectoryPath().then((value) {
      setState(() => _path = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          title: const Text('File Picker'),
        ),
        body: new Center(
            child: new Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: new SingleChildScrollView(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new ConstrainedBox(
                  constraints: BoxConstraints.tightFor(width: 100.0),
                  child: _pickingType == FileType.custom
                      ? new TextFormField(
                          maxLength: 15,
                          autovalidate: true,
                          controller: _controller,
                          decoration:
                              InputDecoration(labelText: 'File extension'),
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.none,
                        )
                      : new Container(),
                ),
                new Padding(
                  padding: const EdgeInsets.only(top: 50.0, bottom: 20.0),
                  child: Column(
                    children: <Widget>[
                      new RaisedButton(
                        onPressed: () => _openFileExplorer(),
                        child: new Text("Select Assignment File"),
                      ),
                      new RaisedButton(
                        onPressed: () => _selectFolder(),
                        child: new Text("Select Folder"),
                      ),
                    ],
                  ),
                ),
                new Builder(
                  builder: (BuildContext context) => _loadingPath
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: const CircularProgressIndicator())
                      : _path != null || _paths != null
                          ? new Container(
                              padding: const EdgeInsets.only(bottom: 30.0),
                              height: MediaQuery.of(context).size.height * 0.50,
                              child: new Scrollbar(
                                  child: new ListView.separated(
                                itemCount: _paths != null && _paths.isNotEmpty
                                    ? _paths.length
                                    : 1,
                                itemBuilder: (BuildContext context, int index) {
                                  final bool isMultiPath =
                                      _paths != null && _paths.isNotEmpty;
                                  final String name = 'File $index: ' +
                                      (isMultiPath
                                          ? _paths.keys.toList()[index]
                                          : _fileName ?? '...');
                                  final path = isMultiPath
                                      ? _paths.values.toList()[index].toString()
                                      : _path;
                                 //TODO UPLOAD TO FIREBASE
                                  pdfFile = new File(path);
                                  
                                  //changePDF();

                                  return new ListTile(
                                    title: new Text(
                                      name,
                                    ),
                                    subtitle: Column(
                                      children: <Widget>[
                                        new Text(path),
                                        new RaisedButton(onPressed: ()=>{print(pdfFile)}),
                                        //new Image.file(pdfFile)
                                        
                                       
                                      ],
                                    ),
                                  );
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) =>
                                        new Divider(),
                              )),
                            )
                          : new Container(),
                ),
              ],
            ),
          ),
        )),
      ),
    );
  }
  
}