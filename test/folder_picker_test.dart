import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/src/widgets/folder_picker_modal.dart';

void main() {
  testWidgets(
    'folder picker builds before initialization and can close early',
    (tester) async {
      final directory = Directory.systemTemp.createTempSync('sendme-picker-');
      addTearDown(() => directory.deleteSync(recursive: true));

      await tester.pumpWidget(
        MaterialApp(home: FolderPickerModal(initialPath: directory.path)),
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    },
  );
}
