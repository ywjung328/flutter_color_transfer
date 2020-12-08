import 'dart:io';
import 'dart:typed_data';

import 'package:bitmap/bitmap.dart';
import 'package:bitmap/transformations/resize.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stats/stats.dart';

class ProcessImage extends ChangeNotifier {
  var input;
  var style;
  var result;

  bool isLoading = false;

  setLoading(bool status) {
    isLoading = status;
    print("triggered");
    notifyListeners();
  }

  loadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile == null) return null;

    var image = await Bitmap.fromProvider(FileImage(File(pickedFile.path)));

    return image;
  }

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
    var mean = stat.average;
    var std = stat.standardDeviation;

    return [mean, std];
  }

  // TODO: implement histogram matching in OPTIMIZED WAY
  histMatch(input, style) {
    return input;
  }

  colorTransfer(input, style) async {
    // var inputDs = img.copyResize(input, width: 480);
    // var styleDs = img.copyResize(style, width: 480);
    Bitmap inputDs = await resizeWidth(input, 480);
    Bitmap styleDs = await resizeWidth(style, 480);

    var inputColor = splitChannel(input);
    var inputDsColor = splitChannel(inputDs);
    var styleDsColor = splitChannel(styleDs);

    var inputR = inputColor[0];
    var inputG = inputColor[1];
    var inputB = inputColor[2];

    List<num> inputDsR = inputDsColor[0].cast<num>().toList();
    List<num> inputDsG = inputDsColor[1].cast<num>().toList();
    List<num> inputDsB = inputDsColor[2].cast<num>().toList();

    List<num> styleDsR = styleDsColor[0].cast<num>().toList();
    List<num> styleDsG = styleDsColor[1].cast<num>().toList();
    List<num> styleDsB = styleDsColor[2].cast<num>().toList();

    var inputStatR = calcMeanStd(inputDsR);
    var inputStatG = calcMeanStd(inputDsG);
    var inputStatB = calcMeanStd(inputDsB);

    var styleStatR = calcMeanStd(styleDsR);
    var styleStatG = calcMeanStd(styleDsG);
    var styleStatB = calcMeanStd(styleDsB);

    var result = [];

    for (int i = 0; i < inputR.length; i++) {
      var red = inputR[i];
      var green = inputG[i];
      var blue = inputB[i];

      red = (red - inputStatR[0]) * (styleStatR[1] / inputStatR[1]) +
          styleStatR[0];
      red = red.round();
      red = red.clamp(0, 255);
      result.add(red);

      green = (green - inputStatG[0]) * (styleStatG[1] / inputStatG[1]) +
          styleStatG[0];
      green = green.round();
      green = green.clamp(0, 255);
      result.add(green);

      blue = (blue - inputStatB[0]) * (styleStatB[1] / inputStatB[1]) +
          styleStatB[0];
      blue = blue.round();
      blue = blue.clamp(0, 255);
      result.add(blue);

      // fill alpha channel as FF
      result.add(255);
    }

    return Uint8List.fromList(result.cast<int>().toList());
  }
}
