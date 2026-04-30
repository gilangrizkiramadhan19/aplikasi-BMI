import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';

/// Universal Image Zoom Viewer - Support Network, File, dan Memory images
/// dengan pinch-zoom, pan, swipe antar images, dan loading indicator
class ImageZoomViewer extends StatefulWidget {
  final List<ImageSource> images;
  final int initialIndex;

  const ImageZoomViewer({
    Key? key,
    required this.images,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<ImageZoomViewer> createState() => _ImageZoomViewerState();
}

class _ImageZoomViewerState extends State<ImageZoomViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Foto ${_currentIndex + 1} dari ${widget.images.length}',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          return ImageZoomPage(imageSource: widget.images[index]);
        },
      ),
    );
  }
}

/// Single image zoom page dengan gesture support
class ImageZoomPage extends StatefulWidget {
  final ImageSource imageSource;

  const ImageZoomPage({
    Key? key,
    required this.imageSource,
  }) : super(key: key);

  @override
  State<ImageZoomPage> createState() => _ImageZoomPageState();
}

class _ImageZoomPageState extends State<ImageZoomPage>
    with SingleTickerProviderStateMixin {
  late TransformationController _transformationController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    if (_transformationController.value != Matrix4.identity()) {
      _animationController.forward(from: 0.0);
      _transformationController.value = Matrix4.identity();
    } else {
      _animationController.forward(from: 0.0);
      final double scale = 3;
      final double x = MediaQuery.of(context).size.width / 2;
      final double y = MediaQuery.of(context).size.height / 2;
      _transformationController.value = Matrix4.identity()
        ..translate(-x, -y)
        ..scale(scale)
        ..translate(x / scale, y / scale);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: _handleDoubleTap,
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 1.0,
        maxScale: 4.0,
        child: Center(
          child: _buildImage(),
        ),
      ),
    );
  }

  /// Build image widget berdasarkan tipe sumber gambar
  Widget _buildImage() {
    try {
      switch (widget.imageSource.type) {
        case ImageSourceType.file:
          return Image.file(
            widget.imageSource.file!,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorWidget('Error loading file image');
            },
          );

        case ImageSourceType.network:
          return Image.network(
            widget.imageSource.url!,
            fit: BoxFit.contain,
            headers: const {'ngrok-skip-browser-warning': 'true'},
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildLoadingWidget(loadingProgress);
            },
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorWidget('Error loading network image');
            },
          );

        case ImageSourceType.memory:
          return Image.memory(
            widget.imageSource.bytes!,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorWidget('Error loading memory image');
            },
          );
      }
    } catch (e) {
      return _buildErrorWidget('Unexpected error: $e');
    }
  }

  /// Loading indicator dengan progress bar
  Widget _buildLoadingWidget(ImageChunkEvent loadingProgress) {
    final progress = loadingProgress.expectedTotalBytes != null
        ? loadingProgress.cumulativeBytesLoaded /
            loadingProgress.expectedTotalBytes!
        : null;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            backgroundColor: Colors.white30,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            progress != null
                ? '${(progress * 100).toStringAsFixed(0)}%'
                : 'Loading...',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Error widget dengan pesan yang jelas
  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            color: Colors.white.withOpacity(0.5),
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Model untuk menyimpan berbagai tipe sumber gambar
enum ImageSourceType { file, network, memory }

class ImageSource {
  final ImageSourceType type;
  final File? file;
  final String? url;
  final Uint8List? bytes;

  ImageSource.fromFile(File file)
      : type = ImageSourceType.file,
        file = file,
        url = null,
        bytes = null;

  ImageSource.fromNetwork(String url)
      : type = ImageSourceType.network,
        file = null,
        url = url,
        bytes = null;

  ImageSource.fromMemory(Uint8List bytes)
      : type = ImageSourceType.memory,
        file = null,
        url = null,
        bytes = bytes;
}
