import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// SVG or raster (PNG/JPG/WebP), from an asset or HTTPS URL.
class AppImage extends StatelessWidget {
  const AppImage(
    this.source, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.semanticLabel,
    this.color,
    this.placeholder,
  });
  final String source;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String? semanticLabel;
  final Color? color;
  final Widget? placeholder;

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(source);
    final network = uri?.scheme == 'https' || uri?.scheme == 'http';
    final svg = (uri?.path ?? source).toLowerCase().endsWith('.svg');
    final fallback = placeholder ?? const Icon(Icons.broken_image_outlined);
    if (svg) {
      final filter = color == null
          ? null
          : ColorFilter.mode(color!, BlendMode.srcIn);
      if (network) {
        return SvgPicture.network(
          source,
          width: width,
          height: height,
          fit: fit,
          semanticsLabel: semanticLabel,
          colorFilter: filter,
          placeholderBuilder: (_) => placeholder ?? const SizedBox.shrink(),
          errorBuilder: (_, _, _) => fallback,
        );
      }
      return SvgPicture.asset(
        source,
        width: width,
        height: height,
        fit: fit,
        semanticsLabel: semanticLabel,
        colorFilter: filter,
        errorBuilder: (_, _, _) => fallback,
      );
    }
    if (network) {
      return Image.network(
        source,
        width: width,
        height: height,
        fit: fit,
        semanticLabel: semanticLabel,
        color: color,
        errorBuilder: (_, _, _) => fallback,
      );
    }
    return Image.asset(
      source,
      width: width,
      height: height,
      fit: fit,
      semanticLabel: semanticLabel,
      color: color,
      errorBuilder: (_, _, _) => fallback,
    );
  }
}
