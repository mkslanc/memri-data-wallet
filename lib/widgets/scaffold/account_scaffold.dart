import 'dart:async';

import 'package:flutter/material.dart';
import 'package:memri/constants/cvu/cvu_font.dart';
import 'package:memri/controllers/app_controller.dart';
import 'package:memri/models/pod_setup.dart';
import 'package:memri/utils/app_helper.dart';
import 'package:memri/utils/responsive_helper.dart';
import 'package:memri/widgets/dots_indicator.dart';
import 'package:memri/widgets/empty.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountScaffold extends StatefulWidget {
  const AccountScaffold({Key? key, required this.child, this.showSlider = true}) : super(key: key);

  final Widget child;
  final bool showSlider;

  @override
  State<AccountScaffold> createState() => _AccountScaffoldState();
}

class _AccountScaffoldState extends State<AccountScaffold> with SingleTickerProviderStateMixin {
  AppController appController = AppController.shared;
  final List<Widget> _slides = <Widget>[];
  PageController _controller = PageController();
  Timer? _periodicTimer;
  late AnimationController _animationController;
  late Animation<Color?> animation;

  final colors = TweenSequence([
    TweenSequenceItem(
      weight: 1.0,
      tween: ColorTween(begin: Color(0xffE9500F), end: Color(0xff4F56FE)),
    ),
    TweenSequenceItem(
      weight: 1.0,
      tween: ColorTween(begin: Color(0xff4F56FE), end: Color(0xff15B599)),
    ),
    TweenSequenceItem(
      weight: 1.0,
      tween: ColorTween(begin: Color(0xff15B599), end: Color(0xffE9500F)),
    ),
  ]);

  @override
  void initState() {
    if (widget.showSlider) {
      _animationController =
          AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
      animation = colors.animate(_animationController)
        ..addListener(() {
          setState(() {});
        });

      _slides.addAll([_slide1, _slide2, _slide3]);
      _periodicTimer = Timer.periodic(const Duration(seconds: 3), (_) {
        if (_controller.page == _slides.length - 1) {
          _controller.animateToPage(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease,
          );
        } else {
          _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
        }
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    if (_periodicTimer != null) _periodicTimer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.black,
          ),
          app.images.background(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
          Positioned(
            left: 24,
            top: 24,
            child: Row(
              children: [
                app.images.logo(
                  color: Colors.white,
                  height: ResponsiveHelper(context).isLargeScreen ? 52 : 36,
                ),
                SizedBox(width: 16),
                Container(
                  height: ResponsiveHelper(context).isLargeScreen ? 52 : 36,
                  alignment: Alignment.bottomCenter,
                  child: Text('memri', style: CVUFont.headline2.copyWith(color: Colors.white)),
                ),
              ],
            ),
          ),
          Positioned(
            right: 57,
            bottom: ResponsiveHelper(context).isLargeScreen ? 34 : 12,
            child: InkWell(
              onTap: () => launch('https://www.memri.io/memri-privacy-preserving-license'),
              child: Text('License',
                  style: CVUFont.headline4.copyWith(color: Colors.white, fontSize: 17)),
            ),
          ),
          Stack(
            children: [
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: ResponsiveHelper(context).isLargeScreen
                    ? _buildDesktopBody()
                    : _buildMobileBody(),
              ),
              if (appController.model.state == PodSetupState.loading) ...[
                Stack(
                  children: [
                    Positioned(
                        top: 0,
                        bottom: 0,
                        right: 0,
                        left: 0,
                        child: ColoredBox(color: Color.fromRGBO(0, 0, 0, 0.7))),
                    Center(
                      child: Column(
                        children: [
                          Spacer(),
                          SizedBox(
                            child: CircularProgressIndicator(),
                            width: 60,
                            height: 60,
                          ),
                          Text(
                            "Setup in progress...",
                            style: TextStyle(color: Colors.white),
                          ),
                          Spacer()
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopBody() {
    _controller = PageController();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 107),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 120),
                child: widget.child),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: widget.showSlider ? animation.value : Colors.white,
              child: Stack(
                children: [
                  Positioned(
                    left: 50,
                    bottom: 60,
                    right: 50,
                    child: _buildSlider(),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMobileBody() {
    _controller = PageController();
    return Padding(
      padding: const EdgeInsets.only(top: 80, bottom: 40),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 50),
                child: widget.child),
            Container(
              color: widget.showSlider ? animation.value : Colors.white,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              child: _buildSlider(),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSlider() {
    if (!widget.showSlider) return Empty();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: ResponsiveHelper(context).isLargeScreen ? 220 : 180,
          child: PageView(
            physics: AlwaysScrollableScrollPhysics(),
            controller: _controller,
            children: _slides,
            onPageChanged: (index) {
              _animationController.animateTo(index / _slides.length);
            },
          ),
        ),
        SizedBox(height: 40),
        DotsIndicator(
          controller: _controller,
          itemCount: _slides.length,
          dotSize: 5,
          dotSpacing: 28,
          onPageSelected: (int page) {
            _controller.animateToPage(
              page,
              duration: const Duration(milliseconds: 300),
              curve: Curves.ease,
            );
          },
        ),
      ],
    );
  }

  Widget get _slide1 => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Create data apps with your own data",
            style: CVUFont.headline1.copyWith(color: Colors.white),
          ),
          SizedBox(height: 30),
          Text(
            "Import your data from services like WhatsApp, Gmail, Instagram and Twitter into your private Memri POD. Process and use your data to build machine learning apps all in one platform.",
            style: CVUFont.bodyText1.copyWith(color: Colors.white),
          ),
        ],
      );

  Widget get _slide2 => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Easy deployment into apps you can use",
            style: CVUFont.headline1.copyWith(color: Colors.white),
          ),
          SizedBox(height: 30),
          Text(
            "Add and edit a custom interface to your app and see changes live. Select from ready building blocks such as VStacks, HStacks, Text and buttons inside the embedded Ace editor without leaving the platform.",
            style: CVUFont.bodyText1.copyWith(color: Colors.white),
          ),
        ],
      );

  Widget get _slide3 => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Share your apps in an instant",
            style: CVUFont.headline1.copyWith(color: Colors.white),
          ),
          SizedBox(height: 30),
          Text(
            "Push your code to your repo in the dev or prod branch using our importers template, and you’re done.",
            style: CVUFont.bodyText1.copyWith(color: Colors.white),
          ),
        ],
      );
}
