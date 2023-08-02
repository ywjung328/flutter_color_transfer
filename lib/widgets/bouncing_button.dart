import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BouncingButton extends StatefulWidget {
  @override
  _BouncingButtonState createState() => _BouncingButtonState();

  BouncingButton(
      {this.vibration = true,
      this.active = true,
      this.scale = 0.9,
      required this.radius,
      required this.width,
      required this.height,
      this.elevation = 8,
      this.color = Colors.white,
      this.inactiveColor = Colors.grey,
      this.duration = 100,
      required this.child,
      required this.onPressed});

  final bool vibration, active;
  final double scale, radius, width, height, elevation;
  final Color color, inactiveColor;
  final int duration;
  final Widget child;
  final Function onPressed;
}

class _BouncingButtonState extends State<BouncingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late double _scale;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.duration),
      // lowerBound: 0.0,
      // upperBound: 1 - widget.scale,
    )..addListener(() {
        setState(() {});
      });
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _animation.value * (1 - widget.scale);
    // _scale = 1 - _animation.value * (1 - widget.scale);
    return widget.active
        ? GestureDetector(
            // onPointerDown: _onPointerDown,
            // onPointerUp: _onPointerUp,
            // onPointerCancel: _onPointerCancel,
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: Transform.scale(
              scale: _scale,
              child: Container(
                width: widget.width,
                height: widget.height,
                child: widget.child,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.radius),
                  color: widget.color,
                  boxShadow: [
                    BoxShadow(
                      blurRadius:
                          widget.elevation * 1.5 * (1 - _animation.value),
                      offset: Offset(
                          0.0, widget.elevation * 0.5 * (1 - _animation.value)),
                      color: Colors.black.withOpacity(0.3),
                    )
                  ],
                ),
              ),
            ),
          )
        : Container(
            width: widget.width,
            height: widget.height,
            child: widget.child,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.radius),
              border: Border.all(width: 3.0, color: widget.inactiveColor),
              // color: Colors.grey,
            ),
          );
  }

  // void _onTapDown(TapDownDetails details) {
  //   _controller.forward();
  // }

  // void _onTapUp(TapUpDetails details) {
  //   _controller.reverse();
  //   // ignore: unnecessary_statements
  //   if (widget.vibration) HapticFeedback.mediumImpact();
  //   widget.onPressed();
  // }

  void _onPointerDown(PointerDownEvent details) {
    _controller.forward();
  }

  void _onPointerUp(PointerUpEvent details) {
    _controller.reverse();
    // ignore: unnecessary_statements
    if (widget.vibration) HapticFeedback.mediumImpact();
    widget.onPressed();
  }

  void _onPointerCancel(PointerCancelEvent details) {
    if (widget.vibration) HapticFeedback.mediumImpact();
    _controller.reverse();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    // ignore: unnecessary_statements
    if (widget.vibration) HapticFeedback.mediumImpact();
    widget.onPressed();
  }

  void _onTapCancel() {
    if (widget.vibration) HapticFeedback.mediumImpact();
    _controller.reverse();
  }
}
