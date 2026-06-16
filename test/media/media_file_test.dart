import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';

void main() {
  group('MediaFile.toMultipartFile', () {
    test('uses bytes when provided', () {
      final bytes = Uint8List.fromList([0, 1, 2, 3]);
      final file = MediaFile(
        path: '/tmp/test.jpg',
        name: 'test.jpg',
        mimeType: 'image/jpeg',
        bytes: bytes,
      );

      final mf = file.toMultipartFile();
      expect(mf.filename, 'test.jpg');
      expect(mf.contentType.toString(), contains('image/jpeg'));
    });

    test('filename override respected', () {
      final file = MediaFile(
        path: '/tmp/img.png',
        name: 'img.png',
        mimeType: 'image/png',
        bytes: Uint8List(0),
      );

      final mf = file.toMultipartFile(filename: 'avatar.png');
      expect(mf.filename, 'avatar.png');
    });

    test('unknown mimeType falls back to application/octet-stream', () {
      final file = MediaFile(
        path: '/tmp/data.bin',
        name: 'data.bin',
        mimeType: 'notvalidmime',
        bytes: Uint8List(0),
      );

      final mf = file.toMultipartFile();
      expect(mf.contentType.toString(), contains('application/octet-stream'));
    });
  });
}
