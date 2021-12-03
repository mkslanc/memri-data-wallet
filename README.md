# Memri frontend
The flutter application is the front-end for the Memri [pod](https://gitlab.memri.io/memri/pod). [Flutter](https://flutter.dev/) is a framework to build natively compiled, multi-platform (web/desktop/ios/android) applications from a single codebase. The current flutter application codebase is focussed on publishing in flutter-web.

## Build & Run (Flutter-web)

To build the Memri flutter-app locally, you need to either install the Flutter environment locally, or use the docker build. Currently the app is tested and built for flutter web.

### Build:
Install Flutter SDK [mac](https://flutter.dev/docs/get-started/install/macos), [windows](https://flutter.dev/docs/get-started/install/windows), [linux](https://flutter.dev/docs/get-started/install/linux)

### Run:
Execute 
```
flutter run -d chrome --profile
``` 
to run in [profile mode](https://docs.flutter.dev/testing/build-modes#profile) (recommended). For [debug mode](https://docs.flutter.dev/testing/build-modes#debug), run:
```
flutter run -d chrome --debug
```
## CVU
The Memri flutter application uses an inhouse language, [CVU](./docs/cvu-intro), that allows you to define your UI by creating elements in the POD. As the UI definition lives in the database, the Memri UI is dynamic, which allows users to dynamically redefine their UI without recompiling the app or downloading a new release. Additionally, it allows for a microservices architecture, in which community built plugins can easily define their own UI. [Read more here](./docs/cvu-intro).

