import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:widget_to_image/bloc/test_bloc.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controllerValue1 = TextEditingController();
  final _controllerValue2 = TextEditingController();

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Convert widget to image'),
      ),
      body: Stack(
        children: <Widget>[
          StreamBuilder<List<String>>(
            stream: _testBloc.dataStream,
            builder: (context, snapShot) {
              if (snapShot.hasData) return _getImageFromWidget(snapShot.data);
              return Container();
            },
          ),
          Container(
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
                  controller: _controllerValue1,
                  onChanged: (value) {
                    setState(() => _controllerValue1.text = value);
                  },
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _controllerValue2,
                  onChanged: (value) {
                    setState(() => _controllerValue2.text = value);
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
        onPressed: (_controllerValue1.text.isNotEmpty &&
                _controllerValue2.text.isNotEmpty)
            ? () => _testBloc.fetchData(
                _controllerValue1.text, _controllerValue2.text)
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

  Widget _getImageFromWidget(List<String> data) {
    Future.delayed(Duration(milliseconds: 300), () => _convert(_globalKey));

    return RepaintBoundary(
      key: _globalKey,
      child: Container(
        padding: EdgeInsets.all(8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
          maxHeight: MediaQuery.of(context).size.height * 0.06,
        ),
        decoration: BoxDecoration(
          color: Color.fromRGBO(90, 199, 216, 1),
          shape: BoxShape.rectangle,
        ),
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
