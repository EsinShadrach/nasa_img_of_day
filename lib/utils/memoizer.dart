import "dart:async";

class AsyncMemoizer<T> {
  Future<T>? _future;
  var _completer = Completer<T>();

  bool get hasRun => _completer.isCompleted;

  Future<T> runOnce(FutureOr<T> Function() computation) {
    if (!hasRun) {
      _future = _completer.future;
      _completer.complete(Future.sync(computation));
    }
    return _future!;
  }

  void reset() {
    if (hasRun) {
      _future = null;
      _completer = Completer<T>(); // Create a new completer to reset the future
    }
  }
}
