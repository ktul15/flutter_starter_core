import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';

void main() {
  group('MediaFileUpload.toMultipartFile', () {
    test('uses bytes when provided', () async {
      final bytes = Uint8List.fromList([0, 1, 2, 3]);
      final file = MediaFile(
        path: '/tmp/test.jpg',
        name: 'test.jpg',
        mimeType: 'image/jpeg',
        bytes: bytes,
      );

      final mf = await file.toMultipartFile();
      expect(mf.filename, 'test.jpg');
      expect(mf.contentType.toString(), contains('image/jpeg'));
    });

    test('filename override respected', () async {
      final file = MediaFile(
        path: '/tmp/img.png',
        name: 'img.png',
        mimeType: 'image/png',
        bytes: Uint8List(0),
      );

      final mf = await file.toMultipartFile(filename: 'avatar.png');
      expect(mf.filename, 'avatar.png');
    });

    test('unknown mimeType falls back to application/octet-stream', () async {
      final file = MediaFile(
        path: '/tmp/data.bin',
        name: 'data.bin',
        mimeType: 'notvalidmime',
        bytes: Uint8List(0),
      );

      final mf = await file.toMultipartFile();
      expect(mf.contentType.toString(), contains('application/octet-stream'));
    });
  });
}
