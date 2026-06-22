import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import 'media_file.dart';

/// Source for image/video picks.
enum MediaSource {
  /// Device camera.
  camera,

  /// Photo library / gallery.
  gallery,
}

/// Wraps `image_picker` and `file_picker` with a normalised [MediaFile] return
/// type.
///
/// Construct once and inject; the underlying [ImagePicker] can be swapped for
/// testing.
///
/// ```dart
/// final picker = MediaPicker();
///
/// // Image upload — use toMultipartFile() extension from the network module
/// final image = await picker.pickImage();
/// if (image != null) {
///   final form = FormData.fromMap({'avatar': image.toMultipartFile()});
///   await client.postFormData('/profile/avatar', data: form);
/// }
///
/// // Document upload
/// final doc = await picker.pickFile(allowedExtensions: ['pdf', 'docx']);
/// if (doc != null) {
///   final form = FormData.fromMap({'file': doc.toMultipartFile()});
///   await client.postFormData('/documents', data: form);
/// }
/// ```
class MediaPicker {
  MediaPicker({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  /// Picks a single image from [source].
  ///
  /// Returns `null` if the user cancels. [imageQuality] is 0–100.
  Future<MediaFile?> pickImage({
    MediaSource source = MediaSource.gallery,
    int? imageQuality,
  }) async {
    final xFile = await _picker.pickImage(
      source: _mapSource(source),
      imageQuality: imageQuality,
    );
    return xFile == null ? null : await _fromXFile(xFile, 'image/jpeg');
  }

  /// Picks multiple images from the gallery.
  ///
  /// Returns an empty list if the user cancels. [limit] caps the selection.
  Future<List<MediaFile>> pickImages({
    int? limit,
    int? imageQuality,
  }) async {
    final files = await _picker.pickMultiImage(
      limit: limit,
      imageQuality: imageQuality,
    );
    return Future.wait(files.map((f) => _fromXFile(f, 'image/jpeg')));
  }

  /// Picks a video from [source].
  Future<MediaFile?> pickVideo({
    MediaSource source = MediaSource.gallery,
  }) async {
    final xFile = await _picker.pickVideo(source: _mapSource(source));
    return xFile == null ? null : await _fromXFile(xFile, 'video/mp4');
  }

  /// Picks a single file of any type.
  ///
  /// Pass [allowedExtensions] to restrict the picker (e.g. `['pdf', 'docx']`).
  /// When `null`, all file types are shown.
  /// Returns `null` if the user cancels.
  Future<MediaFile?> pickFile({List<String>? allowedExtensions}) async {
    final result = await FilePicker.platform.pickFiles(
      type: allowedExtensions != null ? FileType.custom : FileType.any,
      allowedExtensions: allowedExtensions,
      withData: false,
    );
    if (result == null || result.files.isEmpty) return null;
    final pf = result.files.single;
    final path = pf.path;
    if (path == null) return null;
    return MediaFile(
      path: path,
      name: pf.name,
      mimeType: _mimeFromExtension(pf.extension ?? ''),
      size: pf.size,
    );
  }

  ImageSource _mapSource(MediaSource s) => switch (s) {
        MediaSource.camera => ImageSource.camera,
        MediaSource.gallery => ImageSource.gallery,
      };

  Future<MediaFile> _fromXFile(XFile file, String fallbackMime) async {
    return MediaFile(
      path: file.path,
      name: file.name,
      mimeType: file.mimeType ?? fallbackMime,
    );
  }

  static String _mimeFromExtension(String ext) => switch (ext.toLowerCase()) {
        'pdf' => 'application/pdf',
        'doc' => 'application/msword',
        'docx' =>
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'xls' => 'application/vnd.ms-excel',
        'xlsx' =>
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        'csv' => 'text/csv',
        'txt' => 'text/plain',
        'jpg' || 'jpeg' => 'image/jpeg',
        'png' => 'image/png',
        'gif' => 'image/gif',
        'webp' => 'image/webp',
        'heic' => 'image/heic', // iPhone default photo format (iOS 11+)
        'heif' => 'image/heif',
        'avif' => 'image/avif',
        'mp4' => 'video/mp4',
        'mov' => 'video/quicktime',
        'mp3' => 'audio/mpeg',
        'zip' => 'application/zip',
        _ => 'application/octet-stream',
      };
}
