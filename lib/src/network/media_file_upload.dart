import 'package:dio/dio.dart';

import '../media/media_file.dart';

/// Dio upload helpers for [MediaFile].
///
/// Kept separate from [MediaFile] so the data class has no HTTP client
/// dependency — consumers on non-Dio stacks can ignore this file.
extension MediaFileUpload on MediaFile {
  /// Builds a Dio [MultipartFile] ready for [ApiClient.postFormData].
  ///
  /// Uses [bytes] if available, otherwise reads from [path].
  ///
  /// ```dart
  /// final file = await picker.pickImage();
  /// if (file != null) {
  ///   final form = FormData.fromMap({'avatar': file.toMultipartFile()});
  ///   await client.postFormData('/profile/avatar', data: form);
  /// }
  /// ```
  /// Builds a Dio [MultipartFile] ready for [ApiClient.postFormData].
  ///
  /// Uses in-memory [bytes] when available (synchronous path); otherwise reads
  /// from [path] asynchronously via [MultipartFile.fromFile] — avoids blocking
  /// the isolate on large files when only a path is available.
  Future<MultipartFile> toMultipartFile({String? filename}) async {
    final fn = filename ?? name;
    final b = bytes;
    if (b != null) {
      return MultipartFile.fromBytes(b, filename: fn, contentType: _mediaType);
    }
    return MultipartFile.fromFile(path, filename: fn, contentType: _mediaType);
  }

  DioMediaType get _mediaType {
    final parts = mimeType.split('/');
    return parts.length == 2
        ? DioMediaType(parts[0], parts[1])
        : DioMediaType('application', 'octet-stream');
  }
}
