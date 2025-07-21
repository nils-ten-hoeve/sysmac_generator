import 'dart:io';

import 'package:sysmac_generator/domain/event/event.dart';
import 'package:sysmac_generator/domain/sysmac_project.dart';

void writeSysmacEventArrayCodeFile(
    SysmacProject sysmacProject, List<Event> events) {
  var code = StringBuffer();

  code.writeln(
      '// The EventGlobal is copied to EventGlobalArray for more efficient communication.');
  code.writeln(
      '// This code was generated on 2025-07-17 with sysmac_generator.');
  code.writeln(
      '// For more information see: https://github.com/nils-ten-hoeve/sysmac_generator');
  for (var event in events) {
    code.writeln('EventGlobalArray[${event.number}]:=${event.namePath};');
  }
  var outputFile = createOutputFile(sysmacProject, '-SysmacEventArray.txt');
  outputFile.createSync();
  outputFile.writeAsStringSync(code.toString());
  print('Created: ${outputFile.path} (${events.length} events)');
}

File createOutputFile(SysmacProject sysmacProject, String suffix) {
  var sysmacFile = sysmacProject.archive.file;
  var directory = sysmacFile.parent.path;
  var filename = sysmacFile.uri.pathSegments.last;
  var nameWithoutExtension = filename.split('.').first;
  var outputPath =
      '$directory${Platform.pathSeparator}$nameWithoutExtension$suffix';
  var outputFile = File(outputPath);
  return outputFile;
}
