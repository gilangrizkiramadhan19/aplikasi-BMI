import 'package:flutter/material.dart';
import 'dart:io';

class PhotoZoomViewer extends StatefulWidget {
  final List<File> images;
  final int initialIndex;

  const PhotoZoomViewer({
    Key? key,
    required this.images,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<PhotoZoomViewer> createState() => _PhotoZoomViewerState();
}

class _PhotoZoomViewerState extends State<PhotoZoomViewer> {
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
          style: const TextStyle(color: Colors.white),
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
          return PhotoZoomPage(image: widget.images[index]);
        },
      ),
    );
  }
}

class PhotoZoomPage extends StatefulWidget {
  final File image;

  const PhotoZoomPage({
    Key? key,
    required this.image,
  }) : super(key: key);

  @override
  State<PhotoZoomPage> createState() => _PhotoZoomPageState();
}

class _PhotoZoomPageState extends State<PhotoZoomPage>
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
          child: Image.file(
            widget.image,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
