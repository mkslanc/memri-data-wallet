import 'dart:async';

import 'package:flutter/material.dart';
import 'package:memri/cvu/constants/cvu_font.dart';
import 'package:memri/localization/generated/l10n.dart';
import 'package:memri/providers/app_provider.dart';
import 'package:memri/utilities/helpers/app_helper.dart';
import 'package:memri/utilities/helpers/responsive_helper.dart';
import 'package:memri/widgets/dots_indicator.dart';
import 'package:memri/widgets/empty.dart';
import 'package:memri/widgets/scaffold/base_scaffold.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AccountScaffold extends StatefulWidget {
  const AccountScaffold({Key? key, required this.child, this.showSlider = false})
      : super(key: key);

  final Widget child;
  final bool showSlider;

  @override
  State<AccountScaffold> createState() => _AccountScaffoldState();
}

class _AccountScaffoldState extends State<AccountScaffold>
    with SingleTickerProviderStateMixin {
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
    Provider.of<AppProvider>(context, listen: false).initAccountsAuthState();
    if (widget.showSlider) {
      _animationController = AnimationController(
          duration: const Duration(milliseconds: 600), vsync: this);
      animation = colors.animate(_animationController)
        ..addListener(() {
          setState(() {});
        });

      _slides.addAll([_slide1, _slide2, _slide3]);
      _periodicTimer = Timer.periodic(const Duration(seconds: 3), (_) {
        if (_controller.page == null) return;
        if (_controller.page! > 0 &&
            _controller.page!.toInt() == _slides.length - 1) {
          _controller.animateToPage(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease,
          );
        } else {
          _controller.nextPage(
              duration: const Duration(milliseconds: 300), curve: Curves.ease);
        }
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    if (_periodicTimer != null) _periodicTimer!.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
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
                  child: Text(S.current.memri.toLowerCase(),
                      style: CVUFont.headline2.copyWith(color: Colors.white)),
                ),
              ],
            ),
          ),
          Positioned(
            right: 57,
            bottom: ResponsiveHelper(context).isLargeScreen ? 34 : 12,
            child: InkWell(
              onTap: () => launchUrlString(
                  'https://www.memri.io/memri-privacy-preserving-license'),
              child: Text(S.current.license,
                  style: CVUFont.headline4
                      .copyWith(color: Colors.white, fontSize: 17)),
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: ResponsiveHelper(context).isLargeScreen
                ? _buildDesktopBody()
                : _buildMobileBody(),
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
              height: MediaQuery.of(context).size.height,
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 120),
              child: widget.showSlider
                  ? widget.child
                  : Row(children: [
                      Expanded(
                        flex: 2,
                        child: widget.child,
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(color: Colors.white),
                      ),
                    ]),
            ),
          ),
          if (widget.showSlider)
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
                height: MediaQuery.of(context).size.height - 150,
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
            S.current.account_slider_1_title,
            style: CVUFont.headline1.copyWith(color: Colors.white),
          ),
          SizedBox(height: 30),
          Text(
            S.current.account_slider_1_message,
            style: CVUFont.bodyText1.copyWith(color: Colors.white),
          ),
        ],
      );

  Widget get _slide2 => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            S.current.account_slider_2_title,
            style: CVUFont.headline1.copyWith(color: Colors.white),
          ),
          SizedBox(height: 30),
          Text(
            S.current.account_slider_2_message,
            style: CVUFont.bodyText1.copyWith(color: Colors.white),
          ),
        ],
      );

  Widget get _slide3 => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            S.current.account_slider_3_title,
            style: CVUFont.headline1.copyWith(color: Colors.white),
          ),
          SizedBox(height: 30),
          Text(
            S.current.account_slider_3_message,
            style: CVUFont.bodyText1.copyWith(color: Colors.white),
          ),
        ],
      );
}
