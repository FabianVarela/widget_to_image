import 'dart:async';

class TestBloc implements BaseBloc {
  /// Init controllers
  final _dataStream = StreamController<List<String>>();

  /// Expose data from stream
  Stream<List<String>> get dataStream => _dataStream.stream;

  /// Functions
  void fetchData(String data, String data2) async {
    _dataStream.sink.add([data, data2]);

    Future.delayed(Duration(seconds: 1), () => _dataStream.sink.add(null));
  }

  void dispose() {
    _dataStream.close();
  }
}

abstract class BaseBloc {
  void dispose();
}
