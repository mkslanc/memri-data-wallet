import 'package:flutter/material.dart';
import 'package:memri/utils/factory_reset.dart';
import 'package:memri/widgets/space.dart';

import '../constants/app_styles.dart';

/// The view displayed when the user needs to authenticate in order to use the app
/// Once implemented this will offer PIN input or Face/TouchID, and feedback / retry option if failed.
class AuthenticationScreen extends StatefulWidget {
  final Exception? authError;
  final VoidCallback callback;

  AuthenticationScreen({this.authError, required this.callback});

  @override
  _AuthenticationScreenState createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: space(10, [
            Wrap(
              direction: Axis.vertical,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: -10,
              children: [
                Text("Welcome to",
                    style:
                        TextStyle(fontFamily: "system", fontSize: 20, fontWeight: FontWeight.w100)),
                Text("memri",
                    style:
                        TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.purple))
              ],
            ),
            Text("A place where your data belongs to you.", textAlign: TextAlign.center),
            SizedBox(height: 30),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextButton(
                          onPressed: widget.callback,
                          style: primaryButtonStyle,
                          child: Text(
                            "Authorise",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          )),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                if (widget.authError != null)
                  Text(
                    "Error: ${widget.authError.toString()}",
                    style: TextStyle(color: Colors.red),
                  ),
                TextButton(
                  onPressed: () => factoryReset(context),
                  child: Text("Wipe all data"),
                  style: primaryButtonStyle,
                )
              ],
            )
          ])),
    );
  }
}
