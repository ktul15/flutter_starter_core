import 'dart:typed_data';

/// Normalised file selected by [MediaPicker].
///
/// A pure data class — no HTTP client dependency. To build a Dio [MultipartFile]
/// for upload, use the `toMultipartFile()` extension from the network module:
///
/// ```dart
/// import 'package:flutter_starter_core/flutter_starter_core.dart';
///
/// final file = await picker.pickImage();
/// if (file != null) {
///   final form = FormData.fromMap({'avatar': await file.toMultipartFile()});
///   await client.postFormData('/profile/avatar', data: form);
/// }
/// ```
class MediaFile {
  const MediaFile({
    required this.path,
    required this.name,
    required this.mimeType,
    this.bytes,
    this.size,
  });

  /// Absolute path on the device filesystem.
  ///
  /// Empty string (`''`) on Flutter Web — the browser provides no filesystem
  /// path. Use [bytes] for file content on web.
  final String path;

  /// Original filename including extension.
  final String name;

  /// MIME type (e.g. `image/jpeg`, `application/pdf`).
  final String mimeType;

  /// File bytes, if loaded into memory. Prefer [path] for large files.
  final Uint8List? bytes;

  /// File size in bytes, when available.
  final int? size;
}
