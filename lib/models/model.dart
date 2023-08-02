import 'dart:typed_data';

import 'package:bitmap/bitmap.dart';

enum DIRECTION {
  HEAD,
  BODY,
  TAIL,
}

class SourceImage {
  final Bitmap srcImg;
  final String srcPath;
  // final bool portrait;
  // final Map<String, String> exif;

  // SourceImage({this.srcImg, this.srcPath, this.portrait, this.exif});
  SourceImage({required this.srcImg, required this.srcPath});
}

class ResultImage {
  final Uint8List data;
  // IDK if channel width and height will be needed but...
  final int width, height, size;
  final String fileName;
  // IDK if channel info will be needed but...
  final int channel;

  ResultImage(
      {required this.data,
      required this.width,
      required this.height,
      required this.size,
      required this.fileName,
      required this.channel});
}
