import 'package:flutter/material.dart';
import 'package:memri/configs/routes/route_navigator.dart';
import 'package:memri/localization/generated/l10n.dart';
import 'package:memri/providers/app_provider.dart';
import 'package:memri/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';

class BaseScaffold extends StatelessWidget {
  const BaseScaffold({
    Key? key,
    required this.body,
    this.appBar,
  }) : super(key: key);

  /// The primary content of the scaffold.
  final Widget body;

  /// An app bar to display at the top of the scaffold.
  final PreferredSizeWidget? appBar;

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
          case AppState.authenticating:
          case AppState.success:
            child = Scaffold(appBar: appBar, body: body);
            break;
          case AppState.error:
            WidgetsBinding.instance.addPostFrameCallback((_) =>
                RouteNavigator.navigateTo(
                    context: context, route: Routes.error));
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
        LoadingIndicator(message: provider.welcomeMessage),
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Text('POD: V.${provider.podVersion ?? S.current.initializing}'),
              Text('APP: V.${provider.appVersion ?? 'x.x.x.x'}'),
            ],
          ),
        ),
      ],
    );
  }
}
