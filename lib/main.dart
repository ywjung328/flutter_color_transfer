import 'dart:io';

import 'package:bitmap/transformations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:stats/stats.dart';
import 'package:style_transfer_port/functions/loading_overlay.dart';
import 'package:style_transfer_port/functions/process_image.dart';
import 'package:style_transfer_port/result_page.dart';
import 'package:bitmap/bitmap.dart';

// import 'package:style_transfer_port/result_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProcessImage()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: MyHomePage(title: 'Flutter Demo Home Page'),
      ),
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
      var mean = stat.average;
      var std = stat.standardDeviation;

      return [mean, std];
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

    var channel = input.content.length ~/ (input.width * input.height);

    for (int i = 0; i < input.content.length; i += channel) {
      var red = input.content[i];
      var green = input.content[i + 1];
      var blue = input.content[i + 2];

      red = (red - inputStatR[0]) * (styleStatR[1] / inputStatR[1]) +
          styleStatR[0];
      input.content[i] = red.round().clamp(0, 255);

      green = (green - inputStatG[0]) * (styleStatG[1] / inputStatG[1]) +
          styleStatG[0];
      input.content[i + 1] = green.round().clamp(0, 255);

      blue = (blue - inputStatB[0]) * (styleStatB[1] / inputStatB[1]) +
          styleStatB[0];
      input.content[i + 2] = blue.round().clamp(0, 255);
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
                  input = null;
                  inputPath = null;
                  var _input = await getImage();
                  inputPath = _input[0];
                  input = _input[1];
                },
              ),
              FlatButton(
                child: Text("Style Image"),
                onPressed: () async {
                  style = null;
                  stylePath = null;
                  var _style = await getImage();
                  stylePath = _style[0];
                  style = _style[1];
                },
              ),
              FlatButton(
                child: Text("Transfer"),
                onPressed: () async {
                  if (inputPath != null && stylePath != null) {
                    overlay.show();
                    result = null;

                    Map map = Map();

                    var inputStat = await compute(getStyleVariables, input);
                    var styleStat = await compute(getStyleVariables, style);

                    map['input'] = input;
                    map['inputStatR'] = inputStat[0];
                    map['inputStatG'] = inputStat[1];
                    map['inputStatB'] = inputStat[2];
                    map['styleStatR'] = styleStat[0];
                    map['styleStatG'] = styleStat[1];
                    map['styleStatB'] = styleStat[2];

                    result = await compute(colorTransfer, map);
                    // var result = await colorTransfer(map);
                    // await overlay.during(colorTransfer(map));
                    overlay.hide();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResultPage(
                          input: inputPath,
                          // input: input.getBytes(),
                          style: stylePath,
                          // style: style.getBytes(),
                          result: Bitmap.fromHeadless(
                                  input.width, input.height, result)
                              .buildHeaded(),
                        ),
                      ),
                    );
                  } else {
                    print("null state");
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text("Sending Message"),
                      action: SnackBarAction(
                        label: 'Close',
                        onPressed: () => {},
                      ),
                    ));
                    print("않이 외않되");
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
