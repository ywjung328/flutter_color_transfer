import 'dart:ui';

import 'package:flutter/material.dart';

class ShadowedAssetImage extends StatelessWidget {
  final path;
  final width;
  final elevation;

  ShadowedAssetImage(this.path, {this.width = .0, this.elevation = 8.0});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: elevation),
      child: Container(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(top: elevation / 2),
              child: Opacity(
                  child: Image.asset(path,
                      color: Colors.black.withOpacity(0.6),
                      width: width == 0 ? null : width),
                  opacity: 0.5),
            ),
            ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                    sigmaX: elevation * 0.5, sigmaY: elevation * 0.5),
                child: Image.asset(path, width: width == 0 ? null : width),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
