import 'package:will_i_make_it/app/app.dart';
import 'package:will_i_make_it/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() => const App());
}
