import 'dart:io';

import 'package:bitmap/transformations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stats/stats.dart';
import 'package:style_transfer_port/functions/loading_overlay.dart';
import 'package:style_transfer_port/ui/page_home.dart';
import 'package:style_transfer_port/result_page.dart';
import 'package:bitmap/bitmap.dart';

import 'models/theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.light,
          // systemNavigationBarColor: Colors.transparent,
          systemNavigationBarColor: lightAppColors["background"],
          systemNavigationBarIconBrightness: Brightness.dark),
    );
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: TextTheme(
          bodyText1: TextStyle(
            color: lightAppColors["text1"],
          ),
          bodyText2: TextStyle(
            color: lightAppColors["text1"],
          ),
        ),
      ),
      home: PageHome(),
      // home: MyHomePage(title: "UGRP 2020"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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

  @override
  Widget build(BuildContext context) {
    final overlay = LoadingOverlay.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Builder(builder: (BuildContext context) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton(
                child: Text("Input Image"),
                onPressed: () async {
                  overlay.show();
                  input = null;
                  inputPath = null;
                  var _input = await getImage();

                  if (_input == null)
                    overlay.hide();
                  else {
                    inputPath = _input[0];
                    input = _input[1];
                    overlay.hide();
                  }
                },
              ),
              FlatButton(
                child: Text("Style Image"),
                onPressed: () async {
                  overlay.show();
                  style = null;
                  stylePath = null;
                  var _style = await getImage();

                  if (_style == null)
                    overlay.hide();
                  else {
                    stylePath = _style[0];
                    style = _style[1];
                    overlay.hide();
                  }
                },
              ),
              FlatButton(
                child: Text("Transfer"),
                onPressed: () async {
                  if (inputPath != null && stylePath != null) {
                    // overlay.show();
                    // result = null;

                    // Map map = Map();

                    // var inputStat = await compute(getStyleVariables, input);
                    // var styleStat = await compute(getStyleVariables, style);

                    // map['input'] = input;
                    // map['inputStatR'] = inputStat[0];
                    // map['inputStatG'] = inputStat[1];
                    // map['inputStatB'] = inputStat[2];
                    // map['styleStatR'] = styleStat[0];
                    // map['styleStatG'] = styleStat[1];
                    // map['styleStatB'] = styleStat[2];

                    // result = await compute(colorTransfer, map);

                    // overlay.hide();

                    Navigator.push(
                      context,
                      // MaterialPageRoute(
                      //   builder: (context) => ResultPage(
                      //     input: inputPath,
                      //     // input: input.getBytes(),
                      //     style: stylePath,
                      //     // style: style.getBytes(),
                      //     result: Bitmap.fromHeadless(
                      //             input.width, input.height, result)
                      //         .buildHeaded(),
                      //   ),
                      // ),
                      PageRouteBuilder(
                          pageBuilder: (context, animation, anotherAnimation) =>
                              ResultPage(
                                input: inputPath,
                                style: stylePath,
                                result: Bitmap.fromHeadless(
                                        input.width, input.height, result)
                                    .buildHeaded(),
                              ),
                          transitionDuration: Duration(seconds: 1),
                          transitionsBuilder:
                              (context, animation, anotherAnimation, child) {
                            animation = CurvedAnimation(
                                curve: Curves.easeInOut, parent: animation);
                            return SlideTransition(
                              position: Tween(
                                begin: Offset(1.0, 0.0),
                                end: Offset(0.0, 0.0),
                              ).animate(animation),
                              child: child,
                            );
                          }),
                    );
                  } else {
                    print(input == null);
                    print(style == null);
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text("Sending Message"),
                      action: SnackBarAction(
                        label: 'Close',
                        onPressed: () => {},
                      ),
                    ));
                  }
                },
              ),
            ],
          ),
        );
      }),
    );
  }
}
