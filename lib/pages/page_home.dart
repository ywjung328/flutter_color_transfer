import 'package:flutter/material.dart';

class PageHome extends StatefulWidget {
  @override
  _PageHomeState createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> with TickerProviderStateMixin {
  final pageController = PageController(
    initialPage: 0,
  );

  AnimationController _controller;
  Animation<Offset> _animation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: const Offset(0.0, -1.5),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color(0xff9799ba),
      backgroundColor: Colors.blueGrey,
      body: Stack(
        children: [
          Center(
            child: ScaleTransition(
              scale: Tween(begin: 1.0, end: 1.6).animate(CurvedAnimation(
                  parent: _controller, curve: Curves.easeInOut)),
              child: SlideTransition(
                position: _animation,
                child: FlutterLogo(size: 100),
              ),
            ),
          ),
          PageView(
            controller: pageController,
            physics: NeverScrollableScrollPhysics(),
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("This is page 1"),
                    RaisedButton(
                      // onPressed: () => pageController.animateTo(
                      //   MediaQuery.of(context).size.width,
                      //   duration: Duration(seconds: 2),
                      //   curve: Curves.easeInOut,
                      // ),
                      onPressed: () {
                        _controller.forward();
                        pageController.animateToPage(
                          1,
                          duration: Duration(milliseconds: 600),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ],
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("This is page 2"),
                    RaisedButton(
                      onPressed: () {
                        _controller.reverse();
                        pageController.animateToPage(
                          2,
                          duration: Duration(milliseconds: 600),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ],
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("This is page 3"),
                    RaisedButton(
                      // onPressed: () => pageController.jumpTo(0.0),
                      onPressed: () => pageController.animateToPage(
                        0,
                        duration: Duration(milliseconds: 750),
                        curve: Curves.easeInOut,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
