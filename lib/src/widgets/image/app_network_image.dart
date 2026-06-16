import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../loaders/skeleton_box.dart';

/// A cached network image with sensible defaults for placeholder and error states.
///
/// - Placeholder: [SkeletonBox] (already in package) — same size as the image.
/// - Error: `Icon(Icons.broken_image_outlined)` styled with `colorScheme.error`.
/// - Optional [borderRadius] wraps the image in a [ClipRRect].
/// - Backed by `cached_network_image` — disk + memory cache with HTTP headers support.
///
/// ```dart
/// AppNetworkImage(
///   url: user.avatarUrl,
///   width: 48,
///   height: 48,
///   borderRadius: BorderRadius.circular(24),
/// )
/// ```
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.headers,
  });

  /// Full URL of the remote image.
  final String url;

  /// Explicit width; if null the image fills available horizontal space.
  final double? width;

  /// Explicit height; if null the image fills available vertical space.
  final double? height;

  /// How the image should be inscribed into the box. Defaults to [BoxFit.cover].
  final BoxFit fit;

  /// Clips the image to rounded corners when set.
  final BorderRadius? borderRadius;

  /// Custom placeholder shown while the image loads.
  ///
  /// Defaults to a [SkeletonBox] matching [width] and [height].
  final Widget Function(BuildContext, String)? placeholder;

  /// Custom widget shown when the image fails to load.
  ///
  /// Defaults to a centred [Icons.broken_image_outlined] icon.
  final Widget Function(BuildContext, String, Object)? errorWidget;

  /// Additional HTTP headers forwarded to the image request (e.g. auth tokens).
  final Map<String, String>? headers;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget image = CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      httpHeaders: headers,
      placeholder: placeholder ??
          (_, url) => SkeletonBox(
                width: width ?? double.infinity,
                height: height ?? double.infinity,
              ),
      errorWidget: errorWidget ??
          (_, url, err) => SizedBox(
                width: width,
                height: height,
                child: Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: cs.error,
                    size: (width != null && height != null)
                        ? (width! < height! ? width! : height!) * 0.5
                        : 32,
                  ),
                ),
              ),
    );

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }

    return image;
  }
}
