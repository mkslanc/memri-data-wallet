import 'package:flutter/material.dart';
import 'package:memri/configs/routes/route_navigator.dart';
import 'package:memri/providers/app_provider.dart';
import 'package:memri/utilities/helpers/app_helper.dart';
import 'package:provider/provider.dart';

class BaseScaffold extends StatefulWidget {
  const BaseScaffold({
    Key? key,
    required this.body,
    this.appBar,
    this.checkAuth = true,
  }) : super(key: key);

  /// The primary content of the scaffold.
  final Widget body;

  /// An app bar to display at the top of the scaffold.
  final PreferredSizeWidget? appBar;
  final bool checkAuth;

  @override
  State<BaseScaffold> createState() => _BaseScaffoldState();
}

class _BaseScaffoldState extends State<BaseScaffold> {
  @override
  void initState() {
    _init();
    super.initState();
  }

  Future<void> _init() async {
    await Provider.of<AppProvider>(context, listen: false)
        .initialize(widget.checkAuth);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        Widget child = Container();
        switch (provider.state) {
          case AppState.init:
          case AppState.loading:
            child = Scaffold(body: _buildSplash(provider));
            break;
          case AppState.success:
            child = Scaffold(appBar: widget.appBar, body: widget.body);
            break;
          case AppState.error:
            WidgetsBinding.instance
                .addPostFrameCallback((_) => RouteNavigator.navigateTo(
                      context: context,
                      route: Routes.error,
                    ));
            break;
          case AppState.unauthenticated:
            WidgetsBinding.instance
                .addPostFrameCallback((_) => RouteNavigator.navigateTo(
                      context: context,
                      route: Routes.onboarding,
                      clearStack: true,
                    ));
            break;
        }
        return child;
      },
    );
  }

  Widget _buildSplash(AppProvider provider) {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              app.images.logo(height: 100),
              SizedBox(height: 30),
              SizedBox(
                child: LinearProgressIndicator(color: Color(0xffFE570F)),
                width: 150,
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Text('POD: V.${provider.podVersion}'),
              Text('APP: V.${provider.appVersion}'),
            ],
          ),
        ),
      ],
    );
  }
}
