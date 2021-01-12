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
  SourceImage({this.srcImg, this.srcPath});
}

class ResultImage {
  final Uint8List data;
  // IDK if channel width and height will be needed but...
  final int width, height, size;
  final String fileName;
  // IDK if channel info will be needed but...
  final int channel;

  ResultImage(
      {this.data,
      this.width,
      this.height,
      this.size,
      this.fileName,
      this.channel});
}
