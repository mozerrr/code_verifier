import 'package:code_verifier/code_verifier.dart';

void main() async {
  var verifier = CodeVerifier();
  final watch = Stopwatch()..start();
  final hash = await verifier.codeHash();
  print('${watch.elapsed.inMilliseconds} Milliseconds elapsed');
  watch.stop();
  print('hash: $hash');
}
