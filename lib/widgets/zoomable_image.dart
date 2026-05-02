import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'image_zoom_viewer.dart';

/// Zoomable Image Wrapper - gunakan widget ini untuk membuat image yang bisa di-zoom
/// Mendukung file, network, dan memory images
class ZoomableImage extends StatelessWidget {
  final ImageSource imageSource;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Widget? loadingBuilder;
  final VoidCallback? onTap;

  const ZoomableImage({
    Key? key,
    required this.imageSource,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.loadingBuilder,
    this.onTap,
  }) : super(key: key);

  /// Factory untuk Image.file
  factory ZoomableImage.file(
    File file, {
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
    BorderRadius? borderRadius,
    Widget? loadingBuilder,
    VoidCallback? onTap,
  }) {
    return ZoomableImage(
      imageSource: ImageSource.fromFile(file),
      fit: fit,
      width: width,
      height: height,
      borderRadius: borderRadius,
      loadingBuilder: loadingBuilder,
      onTap: onTap,
    );
  }

  /// Factory untuk Image.network
  factory ZoomableImage.network(
    String url, {
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
    BorderRadius? borderRadius,
    Widget? loadingBuilder,
    VoidCallback? onTap,
  }) {
    return ZoomableImage(
      imageSource: ImageSource.fromNetwork(url),
      fit: fit,
      width: width,
      height: height,
      borderRadius: borderRadius,
      loadingBuilder: loadingBuilder,
      onTap: onTap,
    );
  }

  /// Factory untuk Image.memory
  factory ZoomableImage.memory(
    Uint8List bytes, {
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
    BorderRadius? borderRadius,
    Widget? loadingBuilder,
    VoidCallback? onTap,
  }) {
    return ZoomableImage(
      imageSource: ImageSource.fromMemory(bytes),
      fit: fit,
      width: width,
      height: height,
      borderRadius: borderRadius,
      loadingBuilder: loadingBuilder,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    switch (imageSource.type) {
      case ImageSourceType.file:
        imageWidget = Image.file(
          imageSource.file!,
          fit: fit,
          width: width,
          height: height,
        );
        break;

      case ImageSourceType.network:
        imageWidget = Image.network(
          imageSource.url!,
          fit: fit,
          width: width,
          height: height,
          headers: const {'ngrok-skip-browser-warning': 'true'},
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return loadingBuilder ??
                Container(
                  width: width,
                  height: height,
                  color: Colors.grey[300],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      strokeWidth: 2,
                    ),
                  ),
                );
          },
        );
        break;

      case ImageSourceType.memory:
        imageWidget = Image.memory(
          imageSource.bytes!,
          fit: fit,
          width: width,
          height: height,
        );
        break;
    }

    // Wrap dengan BorderRadius jika ada
    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    // Wrap dengan GestureDetector untuk zoom
    return GestureDetector(
      onTap: onTap ??
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ImageZoomViewer(
                  images: [imageSource],
                  initialIndex: 0,
                ),
              ),
            );
          },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
        ),
        child: Stack(
          children: [
            imageWidget,
            // Zoom indicator overlay
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.6),
                ),
                padding: const EdgeInsets.all(6),
                child: const Icon(
                  Icons.zoom_in,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gallery Image Widget - untuk menampilkan multiple images dengan zoom
class ZoomableImageGallery extends StatelessWidget {
  final List<ImageSource> images;
  final int? maxVisibleImages;
  final double? itemWidth;
  final double? itemHeight;
  final BorderRadius? borderRadius;

  const ZoomableImageGallery({
    Key? key,
    required this.images,
    this.maxVisibleImages,
    this.itemWidth,
    this.itemHeight,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imagesToShow = maxVisibleImages != null
        ? images.take(maxVisibleImages!).toList()
        : images;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (int i = 0; i < imagesToShow.length; i++)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImageZoomViewer(
                    images: images,
                    initialIndex: i,
                  ),
                ),
              );
            },
            child: Stack(
              children: [
                _buildImageWidget(imagesToShow[i]),
                // Zoom indicator
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.6),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.zoom_in,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Build image widget untuk gallery item
  Widget _buildImageWidget(ImageSource imageSource) {
    Widget imageWidget;

    switch (imageSource.type) {
      case ImageSourceType.file:
        imageWidget = Image.file(
          imageSource.file!,
          fit: BoxFit.cover,
          width: itemWidth ?? 100,
          height: itemHeight ?? 100,
        );
        break;

      case ImageSourceType.network:
        imageWidget = Image.network(
          imageSource.url!,
          fit: BoxFit.cover,
          width: itemWidth ?? 100,
          height: itemHeight ?? 100,
          headers: const {'ngrok-skip-browser-warning': 'true'},
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: itemWidth ?? 100,
              height: itemHeight ?? 100,
              color: Colors.grey[300],
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 1.5),
              ),
            );
          },
        );
        break;

      case ImageSourceType.memory:
        imageWidget = Image.memory(
          imageSource.bytes!,
          fit: BoxFit.cover,
          width: itemWidth ?? 100,
          height: itemHeight ?? 100,
        );
        break;
    }

    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}
