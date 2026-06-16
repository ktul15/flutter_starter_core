import 'package:image_picker/image_picker.dart';

import 'media_file.dart';

/// Source for image/video picks.
enum MediaSource {
  /// Device camera.
  camera,

  /// Photo library / gallery.
  gallery,
}

/// Wraps `image_picker` with a normalised [MediaFile] return type.
///
/// Construct once and inject; the underlying [ImagePicker] can be swapped for
/// testing.
///
/// ```dart
/// final picker = MediaPicker();
/// final file = await picker.pickImage();
/// if (file != null) {
///   final form = FormData.fromMap({'avatar': file.toMultipartFile()});
///   await client.postFormData('/profile/avatar', data: form);
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

  ImageSource _mapSource(MediaSource s) => switch (s) {
        MediaSource.camera => ImageSource.camera,
        MediaSource.gallery => ImageSource.gallery,
      };

  Future<MediaFile> _fromXFile(XFile file, String fallbackMime) async {
    final mimeType = file.mimeType ?? fallbackMime;
    return MediaFile(
      path: file.path,
      name: file.name,
      mimeType: mimeType,
    );
  }
}
