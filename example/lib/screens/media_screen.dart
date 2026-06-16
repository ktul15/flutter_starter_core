import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';

import '../cubits/media_cubit.dart';

/// Demonstrates [MediaPicker] — pick image, multiple images, video, and file.
class MediaScreen extends StatelessWidget {
  const MediaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MediaCubit(),
      child: const _MediaBody(),
    );
  }
}

class _MediaBody extends StatelessWidget {
  const _MediaBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MediaCubit, MediaState>(
      builder: (ctx, state) => Scaffold(
        appBar: AppBar(title: const Text('Media')),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Camera and gallery access require a real device. '
                'MediaFile.toMultipartFile() converts the result for Dio multipart uploads.',
                style: TextStyle(fontSize: 12),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: state.loading
                              ? null
                              : () =>
                                  ctx.read<MediaCubit>().pickImage(),
                          icon: const Icon(Icons.photo_outlined),
                          label: const Text('Image'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: state.loading
                              ? null
                              : () =>
                                  ctx.read<MediaCubit>().pickImages(),
                          icon: const Icon(
                            Icons.photo_library_outlined,
                          ),
                          label: const Text('Images'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: state.loading
                              ? null
                              : () =>
                                  ctx.read<MediaCubit>().pickVideo(),
                          icon: const Icon(Icons.videocam_outlined),
                          label: const Text('Video'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: state.loading
                              ? null
                              : () =>
                                  ctx.read<MediaCubit>().pickFile(),
                          icon:
                              const Icon(Icons.attach_file_outlined),
                          label: const Text('File'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (state.loading)
              const Padding(
                padding: EdgeInsets.all(32),
                child: AppLoader(message: 'Picking…'),
              ),
            if (state.files.isNotEmpty) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${state.files.length} file(s) selected',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.files.length,
                  itemBuilder: (_, i) {
                    final f = state.files[i];
                    final sizeLabel = f.size != null
                        ? '${(f.size! / 1024).toStringAsFixed(1)} KB'
                        : 'unknown size';
                    return Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.insert_drive_file_outlined,
                        ),
                        title: Text(f.name),
                        subtitle:
                            Text('${f.mimeType} · $sizeLabel'),
                      ),
                    );
                  },
                ),
              ),
            ] else if (!state.loading) ...[
              Expanded(
                child: EmptyState(
                  title: 'No file selected',
                  message: 'Tap a button above to pick a file.',
                  icon: Icons.folder_open_outlined,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
