import 'package:uuid/uuid.dart';

class IdGenerator {
  static const _uuid = Uuid();

  static String uuid() => _uuid.v4();
}
