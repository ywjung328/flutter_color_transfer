import 'dart:io';
// import 'dart:typed_data';

import 'package:bitmap/bitmap.dart';
import 'package:bitmap/transformations/resize.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stats/stats.dart';

class ProcessImage extends ChangeNotifier {
  var inputPath;
  var input;
  var stylePath;
  var style;
  var result;

  final picker = ImagePicker();

  getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile == null) return null;

    // var image = img.decodeImage(File(pickedFile.path).readAsBytesSync());
    var image = await Bitmap.fromProvider(FileImage(File(pickedFile.path)));

    return [pickedFile.path, image];
  }

  static getStyleVariables(img) async {
    splitChannel(image) {
      var bytes = image.content;

      var red = [];
      var green = [];
      var blue = [];

      var channel = bytes.length ~/ (image.width * image.height);

      for (int i = 0; i < bytes.length; i += channel) {
        red.add(bytes[i]);
        green.add(bytes[i + 1]);
        blue.add(bytes[i + 2]);
      }

      return [red, green, blue];
    }

    calcMeanStd(x) {
      final stat = Stats.fromData(x);

      return [stat.min, stat.max, stat.average, stat.standardDeviation];
    }

    Bitmap imgDs = await resizeWidth(img, 480);
    var imgColor = splitChannel(imgDs);

    List<num> imgR = imgColor[0].cast<num>().toList();
    List<num> imgG = imgColor[1].cast<num>().toList();
    List<num> imgB = imgColor[2].cast<num>().toList();

    var imgStatR = calcMeanStd(imgR);
    var imgStatG = calcMeanStd(imgG);
    var imgStatB = calcMeanStd(imgB);

    return [imgStatR, imgStatG, imgStatB];
  }

  static colorTransfer(map) async {
    var input = map['input'];

    var inputStatR = map['inputStatR'];
    var inputStatG = map['inputStatG'];
    var inputStatB = map['inputStatB'];
    var styleStatR = map['styleStatR'];
    var styleStatG = map['styleStatG'];
    var styleStatB = map['styleStatB'];

    var inputMinR = inputStatR[0];
    var inputMaxR = inputStatR[1];
    var inputAvgR = inputStatR[2];
    var inputStdR = inputStatR[3];

    var inputMinG = inputStatG[0];
    var inputMaxG = inputStatG[1];
    var inputAvgG = inputStatG[2];
    var inputStdG = inputStatG[3];

    var inputMinB = inputStatB[0];
    var inputMaxB = inputStatB[1];
    var inputAvgB = inputStatB[2];
    var inputStdB = inputStatB[3];

    var styleMinR = styleStatR[0];
    var styleMaxR = styleStatR[1];
    var styleAvgR = styleStatR[2];
    var styleStdR = styleStatR[3];

    var styleMinG = styleStatG[0];
    var styleMaxG = styleStatG[1];
    var styleAvgG = styleStatG[2];
    var styleStdG = styleStatG[3];

    var styleMinB = styleStatB[0];
    var styleMaxB = styleStatB[1];
    var styleAvgB = styleStatB[2];
    var styleStdB = styleStatB[3];

    var coefR1 = styleStdR / inputStdR;
    var coefR2 = (styleMaxR - styleMinR) / (inputMaxR - inputMinR);

    var coefG1 = styleStdG / inputStdG;
    var coefG2 = (styleMaxG - styleMinG) / (inputMaxG - inputMinG);

    var coefB1 = styleStdB / inputStdB;
    var coefB2 = (styleMaxB - styleMinB) / (inputMaxB - inputMinB);

    var channel = input.content.length ~/ (input.width * input.height);

    for (int i = 0; i < input.content.length; i += channel) {
      var red = input.content[i];
      var green = input.content[i + 1];
      var blue = input.content[i + 2];

      red = (red - inputAvgR) * coefR1 + styleAvgR;
      red = red.round().clamp(styleMinR, styleMaxR);
      // input.content[i] = ((red - inputMinR) * coefR2 + styleMinR).round();
      input.content[i] = red;

      green = (green - inputAvgG) * coefG1 + styleAvgG;
      green = green.round().clamp(styleMinG, styleMaxG);
      // input.content[i + 1] = ((green - inputMinG) * coefG2 + styleMinG).round();
      input.content[i + 1] = green;

      blue = (blue - inputAvgB) * coefB1 + styleAvgB;
      blue = blue.round().clamp(styleMinB, styleMaxB);
      // input.content[i + 2] = ((blue - inputMinB) * coefB2 + styleMinB).round();
      input.content[i + 2] = blue;
    }

    return input.content;
  }
}
