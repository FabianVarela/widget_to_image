import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'bloc/test_bloc.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
  final _controller1 = TextEditingController();
  final _controller2 = TextEditingController();

  final GlobalKey _globalKey = GlobalKey();
  final _testBloc = TestBloc();

  Uint8List _photo;

  @override
  void dispose() {
    _testBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Widget to image"),
      ),
      body: Stack(
        children: <Widget>[
          StreamBuilder<List<String>>(
            stream: _testBloc.dataStream,
            builder: (context, snapShot) {
              if (snapShot.hasData) return _getETA(snapShot.data);

              return Container();
            },
          ),
          Container(
            color: Colors.white,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(left: 24, right: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text('Convert widget to image'),
                SizedBox(height: 16),
                TextField(
                  controller: _controller1,
                  onChanged: (value) {
                    setState(() => _controller1.text = value);
                  },
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _controller2,
                  onChanged: (value) {
                    setState(() => _controller2.text = value);
                  },
                ),
                SizedBox(height: 50),
                if (_photo != null) Image.memory(_photo, fit: BoxFit.contain),
              ],
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (_controller1.text.isNotEmpty && _controller2.text.isNotEmpty)
            ? () => _testBloc.fetchData(_controller1.text, _controller2.text)
            : null,
        tooltip: 'Convert to image',
        child: Icon(Icons.image),
      ),
    );
  }

  Future<void> _convert(_globalKey) async {
    try {
      RenderRepaintBoundary boundary =
          _globalKey.currentContext.findRenderObject();

      ui.Image image = await boundary.toImage();
      ByteData byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      setState(() => _photo = byteData.buffer.asUint8List());
    } catch (e) {
      print(e);
    }
  }

  Widget _getETA(List<String> data) {
    Future.delayed(Duration(milliseconds: 500), () => _convert(_globalKey));

    return RepaintBoundary(
      key: _globalKey,
      child: Container(
        width: 70,
        height: 50,
        decoration: BoxDecoration(
          color: Color.fromRGBO(90, 199, 216, 1),
          shape: BoxShape.rectangle,
        ),
        padding: EdgeInsets.all(8),
        child: Column(
          children: <Widget>[
            Text(
              data[0],
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
            SizedBox(height: 1),
            Text(
              data[1],
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
