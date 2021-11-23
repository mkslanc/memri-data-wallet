# Memri

Memri Flutter application


# Bulding

To build the app locally, you need to either install the Flutter environment locally, or use the docker build. Currently the app is tested and built for flutter web.

## To build using docker:
```
docker run --rm -e UID="$UID" -e GID="$GROUPS" -e SDK_REGISTRY_TOKEN="....." --workdir /project -v "$PWD":/project matspfeiffer/flutter build apk
```

## To build locally (flutter web):
Install Flutter SDK [mac](https://flutter.dev/docs/get-started/install/macos), [windows](https://flutter.dev/docs/get-started/install/windows), [linux](https://flutter.dev/docs/get-started/install/linux)

## Run:
Run command 
   - `flutter run -d chrome --profile` from console to run in profile mode (recommended)

For debug mode
   - `flutter run -d chrome --debug` from console to run in debug mode

