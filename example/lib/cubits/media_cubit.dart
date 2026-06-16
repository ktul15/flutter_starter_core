import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';

// ── State ──────────────────────────────────────────────────────────────────────

class MediaState extends Equatable {
  const MediaState({this.files = const [], this.loading = false});

  final List<MediaFile> files;
  final bool loading;

  @override
  List<Object?> get props => [files, loading];
}

// ── Cubit ──────────────────────────────────────────────────────────────────────

/// Demonstrates [MediaPicker] — pick image, images, video, and file.
class MediaCubit extends Cubit<MediaState> {
  MediaCubit() : super(const MediaState());

  final _picker = MediaPicker();

  Future<void> pickImage() async {
    emit(const MediaState(loading: true));
    final file = await _picker.pickImage();
    emit(MediaState(files: file != null ? [file] : []));
  }

  Future<void> pickImages() async {
    emit(const MediaState(loading: true));
    final files = await _picker.pickImages(limit: 5);
    emit(MediaState(files: files));
  }

  Future<void> pickVideo() async {
    emit(const MediaState(loading: true));
    final file = await _picker.pickVideo();
    emit(MediaState(files: file != null ? [file] : []));
  }

  Future<void> pickFile() async {
    emit(const MediaState(loading: true));
    final file = await _picker.pickFile();
    emit(MediaState(files: file != null ? [file] : []));
  }
}
