import 'dart:io';
import 'dart:typed_data';

import 'package:bitmap/bitmap.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:image_save/image_save.dart';
import 'package:style_transfer_port/functions/loading_overlay.dart';
import 'package:style_transfer_port/functions/process_image.dart';
import 'package:style_transfer_port/models/model.dart';
import 'package:style_transfer_port/models/theme.dart';
import 'package:style_transfer_port/widgets/bouncing_button.dart';

class PageHome extends StatefulWidget {
  @override
  _PageHomeState createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> with TickerProviderStateMixin {
  PageController pageController;
  ColorTween colorTween;
  AnimationController animationControllerFromLeft;
  AnimationController animationControllerFromRight;
  Animation<Offset> animationFromLeft;
  Animation<Offset> animationFromRight;

  SourceImage style;
  SourceImage input;

  String stylePath;
  String inputPath;

  Uint8List resultBytesData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    colorTween =
        ColorTween(begin: lightAppColors["bg1"], end: lightAppColors["bg2"]);

    // pageController = PageController(keepPage: true, initialPage: 0)
    //   ..addListener(() {
    //     setState(() {});
    //   });
    pageController = PageController(keepPage: true, initialPage: 0);

    animationControllerFromLeft = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    animationControllerFromRight = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    animationFromLeft = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: const Offset(0.0, 0.0),
    ).animate(
      CurvedAnimation(
          parent: animationControllerFromLeft, curve: Curves.easeInOut),
    );

    animationFromRight = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: const Offset(0.0, 0.0),
    ).animate(
      CurvedAnimation(
          parent: animationControllerFromRight, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    pageController.dispose();
    animationControllerFromLeft.dispose();
    animationControllerFromRight.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    // print("stylePath : $stylePath");
    // print("inputPath : $inputPath");

    List<Widget> pageChildren = [
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: height * 0.1),
          Container(
            height: height * 0.5,
            // color: Colors.black,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Choose your style image.",
                    style: TextStyle(fontSize: 20)),
                Text(""),
                Text("Style image is the image you want to imitate."),
                Text("Tap the button or image below to choose / change image."),
                Expanded(
                  child: Center(
                    child: style == null
                        ? BouncingButton(
                            radius: 100,
                            width: 75,
                            height: 75,
                            color: lightAppColors["background"],
                            inactiveColor: lightAppColors["background"],
                            duration: 100,
                            child: Center(
                              child: Icon(Icons.add_a_photo_outlined,
                                  color: lightAppColors["bg1"]),
                            ),
                            onPressed: () async {
                              LoadingOverlay.of(context).show();
                              String oldStylePath = stylePath;

                              stylePath = await getPath();
                              // print(stylePath);

                              if (stylePath == null && oldStylePath != null)
                                stylePath = oldStylePath;

                              if (stylePath != null &&
                                  oldStylePath != stylePath) {
                                style = await getImage(stylePath);
                                setState(() {
                                  // print(style == null);
                                });
                              }
                              LoadingOverlay.of(context).hide();
                            },
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(vertical: 30.0),
                            child: BouncingButton(
                                radius: 0,
                                // color: lightAppColors["background"],
                                // color: Colors.transparent,
                                child: Image.file(File(stylePath)),
                                onPressed: () async {
                                  LoadingOverlay.of(context).show();
                                  String oldStylePath = stylePath;

                                  stylePath = await getPath();
                                  // print(stylePath);

                                  if (stylePath == null && oldStylePath != null)
                                    stylePath = oldStylePath;

                                  if (stylePath != null &&
                                      oldStylePath != stylePath) {
                                    style = await getImage(stylePath);
                                    setState(() {
                                      // print(style == null);
                                    });
                                  }
                                  LoadingOverlay.of(context).hide();
                                }),
                          ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            child: BouncingButton(
              active: style != null,
              radius: 100,
              width: width * 0.6,
              height: height * 0.075,
              color: lightAppColors["background"],
              inactiveColor: lightAppColors["background"].withOpacity(0.5),
              duration: 100,
              child: Center(
                child: style == null
                    ? Text(
                        "Choose image first",
                        style: TextStyle(
                          // color: lightAppColors["background"],
                          color: lightAppColors["background"].withOpacity(0.5),
                          fontSize: 20,
                        ),
                      )
                    : Text(
                        "Next",
                        style: TextStyle(
                          color: lightAppColors["bg1"],
                          fontSize: 20,
                        ),
                      ),
              ),
              onPressed: () {
                pageController.nextPage(
                    duration: Duration(milliseconds: 600),
                    curve: Curves.easeInOut);
                animationControllerFromLeft.forward();
              },
            ),
          )
        ],
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: height * 0.1),
          Container(
            height: height * 0.5,
            // color: Colors.black,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Choose your input image.",
                    style: TextStyle(fontSize: 20)),
                Text(""),
                Text("Input image is the image you want to modify."),
                Text("Tap the button or image below to choose / change image."),
                Expanded(
                  child: Center(
                    child: input == null
                        ? BouncingButton(
                            radius: 100,
                            width: 75,
                            height: 75,
                            color: lightAppColors["background"],
                            inactiveColor: lightAppColors["background"],
                            duration: 100,
                            child: Center(
                              child: Icon(Icons.add_a_photo_outlined,
                                  color: lightAppColors["bg1"]),
                            ),
                            onPressed: () async {
                              LoadingOverlay.of(context).show();
                              String oldInputPath = inputPath;

                              inputPath = await getPath();
                              // print(stylePath);

                              if (inputPath == null && oldInputPath != null)
                                inputPath = oldInputPath;

                              if (inputPath != null &&
                                  oldInputPath != inputPath) {
                                input = await getImage(inputPath);
                                setState(() {
                                  // print(style == null);
                                });
                              }
                              LoadingOverlay.of(context).hide();
                            },
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(vertical: 30.0),
                            child: BouncingButton(
                                radius: 0,
                                // color: lightAppColors["background"],
                                // color: Colors.transparent,
                                child: Image.file(File(inputPath)),
                                onPressed: () async {
                                  LoadingOverlay.of(context).show();
                                  String oldinputPath = inputPath;

                                  inputPath = await getPath();
                                  // print(stylePath);

                                  if (inputPath == null && oldinputPath != null)
                                    inputPath = oldinputPath;

                                  if (inputPath != null &&
                                      oldinputPath != inputPath) {
                                    input = await getImage(inputPath);
                                    setState(() {
                                      // print(style == null);
                                    });
                                  }
                                  LoadingOverlay.of(context).hide();
                                }),
                          ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            child: BouncingButton(
              active: input != null,
              radius: 100,
              width: width * 0.6,
              height: height * 0.075,
              color: lightAppColors["background"],
              inactiveColor: lightAppColors["background"].withOpacity(0.5),
              duration: 100,
              child: Center(
                child: input == null
                    ? Text(
                        "Choose image first",
                        style: TextStyle(
                          // color: lightAppColors["background"],
                          color: lightAppColors["background"].withOpacity(0.5),
                          fontSize: 20,
                        ),
                      )
                    : Text(
                        "Next",
                        style: TextStyle(
                          // color: lightAppColors["bg1"],
                          color:
                              colorTween.evaluate(AlwaysStoppedAnimation(0.5)),
                          fontSize: 20,
                        ),
                      ),
              ),
              onPressed: () async {
                LoadingOverlay.of(context).show();

                Map map = Map();

                map["input"] = input.srcImg;
                map["style"] = style.srcImg;

                resultBytesData = await compute(colorTransfer, map);

                setState(() {
                  resultBytesData = Bitmap.fromHeadless(input.srcImg.width,
                          input.srcImg.height, resultBytesData)
                      .buildHeaded();
                });

                LoadingOverlay.of(context).hide();

                pageController.nextPage(
                    duration: Duration(milliseconds: 600),
                    curve: Curves.easeInOut);
                // animationControllerFromLeft.reverse();
                animationControllerFromRight.forward();
              },
            ),
          ),
        ],
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: height * 0.1),
          Container(
            height: height * 0.5,
            child: resultBytesData == null
                ? Text("Image data aren't computed yet. Check the condition.")
                : Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Result is generated.",
                          style: TextStyle(fontSize: 20)),
                      Text(""),
                      Text(
                          "Your input image's style is now transfered to style image's style."),
                      Text("Tap button below to save the result"),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 30.0),
                          child: Center(
                            child: Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 12,
                                    offset: Offset(0.0, 4),
                                    color: Colors.black.withOpacity(0.3),
                                  )
                                ],
                              ),
                              child: Image.memory(resultBytesData),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          Container(
            child: BouncingButton(
              radius: 100,
              width: height * 0.075,
              height: height * 0.075,
              color: lightAppColors["background"],
              inactiveColor: lightAppColors["background"].withOpacity(0.5),
              duration: 100,
              child: Center(
                child: Icon(
                  Icons.save_alt_outlined,
                  color: lightAppColors["bg2"],
                ),
              ),
              onPressed: () async {
                LoadingOverlay.of(context).show();

                String resultName =
                    "${inputPath.split("/").last.split(".").first}_${stylePath.split("/").last.split(".").first}.png";
                // print(resultName);
                bool success = await ImageSave.saveImage(
                    resultBytesData, resultName,
                    albumName: "Flutter Style Transfer");

                LoadingOverlay.of(context).hide();
              },
            ),
          )
        ],
      ),
    ];

    var totalPages = pageChildren.length;

    return AnimatedBuilder(
      animation: pageController,
      builder: (context, child) {
        final color = pageController.hasClients
            ? pageController.page / (totalPages - 1)
            : .0;
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: SlideTransition(
              position: animationFromLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 24),
                child: IconButton(
                  iconSize: 24,
                  icon: Icon(
                    Icons.navigate_before_outlined,
                    color: lightAppColors["background"],
                  ),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    if (pageController.page <= 1.0)
                      animationControllerFromLeft.reverse();
                    animationControllerFromRight.reverse();
                    pageController.previousPage(
                        duration: Duration(milliseconds: 600),
                        curve: Curves.easeInOut);
                  },
                ),
              ),
            ),
            actions: [
              SlideTransition(
                position: animationFromRight,
                child: Padding(
                  padding: EdgeInsets.only(right: 24),
                  child: IconButton(
                    iconSize: 24,
                    icon: Icon(
                      Icons.home_outlined,
                      color: lightAppColors["background"],
                    ),
                    onPressed: () async {
                      HapticFeedback.mediumImpact();
                      await Future(() {
                        setState(() {
                          style = null;
                          input = null;
                          stylePath = null;
                          inputPath = null;
                          // resultBytesData = null;
                        });
                      });
                      animationControllerFromLeft.reverse();
                      animationControllerFromRight.reverse();
                      pageController.animateToPage(
                        0,
                        duration: Duration(milliseconds: 600),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: colorTween.evaluate(AlwaysStoppedAnimation(color)),
          body: child,
        );
      },
      child: Column(
        children: [
          Container(
            width: width,
            height: height * 0.85,
            child: PageView.builder(
              physics: NeverScrollableScrollPhysics(),
              itemCount: totalPages,
              controller: pageController,
              itemBuilder: (context, position) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.1),
                  child: pageChildren[position],
                );
              },
            ),
          ),
          SmoothPageIndicator(
            controller: pageController,
            count: totalPages,
            effect: WormEffect(
              dotColor: lightAppColors["background"].withOpacity(0.3),
              activeDotColor: lightAppColors["background"],
              dotHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
