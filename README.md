# Memri frontend
The flutter application is the frontend for the Memri [pod](https://gitlab.memri.io/memri/pod). [Flutter](https://flutter.dev/) is a framework to build natively compiled, multi-platform (web/desktop/ios/android) applications from a single codebase. The current flutter application codebase is focussed on publishing in flutter-web.

# Try it out
The pre-alpha version of the Memri frontend is freely available at [memri.docs.memri.io/flutter-app](https://memri.docs.memri.io/flutter-app/#/), and can be used by connecting to your local pod or the public memri hosted pod (alpha) at [dev.pod.memri.io](https://dev.pod.memri.io/). Regardless of your setup: only you have access to the data in your pod. After first login, your credentials will be stored locally for re-use when you revisit the app. To create a new account after first login, [delete your browser database](https://stackoverflow.com/questions/9384128/how-to-delete-indexeddb#answer-9389289) or connect from an incognito tab (in this case your data will be lost after closing the tab). Note that this is a very early release, for help or questions reach out on [Discord]("https://discord.com/invite/BcRfajJk4k").

# How to generate models?

```
flutter pub run build_runner watch --delete-conflicting-outputs
```

## Build & Run (Flutter-web)

To build the Memri flutter-app locally, you need to either install the Flutter environment locally, or use the docker build. Currently the app is tested and built for flutter web.

## Build:
Install Flutter SDK [mac](https://flutter.dev/docs/get-started/install/macos), [windows](https://flutter.dev/docs/get-started/install/windows), [linux](https://flutter.dev/docs/get-started/install/linux)

## Run:
Execute 
```
flutter run -d chrome --profile
``` 
to run in [profile mode](https://docs.flutter.dev/testing/build-modes#profile) (recommended). For [debug mode](https://docs.flutter.dev/testing/build-modes#debug), run:
```
flutter run -d chrome --debug
```
# CVU
The Memri flutter application uses an inhouse language, [CVU](./docs/cvu-intro), that allows you to define your UI by creating elements in the POD. As the UI definition lives in the database, the Memri UI is dynamic, which allows users to dynamically redefine their UI without recompiling the app or downloading a new release. Additionally, it allows for a microservices architecture, in which community built plugins can easily define their own UI. [Read more here](./docs/cvu-intro).

