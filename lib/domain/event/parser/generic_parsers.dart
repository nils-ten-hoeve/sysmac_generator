import 'package:petitparser/parser.dart';

final whiteSpaceParser = whitespace().star().flatten();

final intParser = digit().plus().flatten().map(int.parse);
