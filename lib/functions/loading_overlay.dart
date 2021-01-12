import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingOverlay {
  BuildContext _context;

  void hide() {
    // print("hide overlay");
    Navigator.of(_context).pop();
  }

  void show() {
    // print("show overlay");
    showDialog(
        context: _context,
        barrierDismissible: false,
        builder: (context) {
          return Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.36,
              height: MediaQuery.of(context).size.width * 0.36,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Lottie.asset('assets/loader.json', fit: BoxFit.fill),
            ),
          );
        });
  }

  Future<T> during<T>(Future<T> future) {
    show();
    return future.whenComplete(() => hide());
  }

  LoadingOverlay._create(this._context);

  factory LoadingOverlay.of(BuildContext context) {
    return LoadingOverlay._create(context);
  }
}
