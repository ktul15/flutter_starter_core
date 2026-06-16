import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Normalised file selected by [MediaPicker].
///
/// Bridges platform file pickers to [ApiClient.postFormData] via
/// [toMultipartFile], so upload code is provider-agnostic.
class MediaFile {
  const MediaFile({
    required this.path,
    required this.name,
    required this.mimeType,
    this.bytes,
    this.size,
  });

  /// Absolute path on the device filesystem.
  final String path;

  /// Original filename including extension.
  final String name;

  /// MIME type (e.g. `image/jpeg`, `application/pdf`).
  final String mimeType;

  /// File bytes, if loaded into memory. Prefer [path] for large files.
  final Uint8List? bytes;

  /// File size in bytes, when available.
  final int? size;

  /// Builds a Dio [MultipartFile] ready for [ApiClient.postFormData].
  ///
  /// Uses [bytes] if available, otherwise reads from [path].
  ///
  /// ```dart
  /// final file = await MediaPicker().pickImage();
  /// if (file != null) {
  ///   final form = FormData.fromMap({
  ///     'avatar': file.toMultipartFile(),
  ///   });
  ///   await client.postFormData('/profile/avatar', data: form);
  /// }
  /// ```
  MultipartFile toMultipartFile({String? filename}) {
    final fn = filename ?? name;
    final bytes = this.bytes;
    if (bytes != null) {
      return MultipartFile.fromBytes(bytes, filename: fn, contentType: _mediaType);
    }
    return MultipartFile.fromFileSync(path, filename: fn, contentType: _mediaType);
  }

  // Parses type/subtype from mimeType for DioMediaType.
  DioMediaType get _mediaType {
    final parts = mimeType.split('/');
    return parts.length == 2
        ? DioMediaType(parts[0], parts[1])
        : DioMediaType('application', 'octet-stream');
  }
}
