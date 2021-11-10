# Memri

Memri Flutter application


# Bulding

To build the app locally, you need to either install the Flutter environment locally, or use the docker build.

You'll also need a working MapBox key (the `SDK_REGISTRY_TOKEN` environment variable below). Please ask for one from the team if you're an active contributor, or generate a personal one from mapbox (TODO: improve this? ideas welcome, e.g. if there's a script to generate key if not present).

## To build using docker:
```
docker run --rm -e UID="$UID" -e GID="$GROUPS" -e SDK_REGISTRY_TOKEN="....." --workdir /project -v "$PWD":/project matspfeiffer/flutter build apk
```

## To build locally:
**On MacOS:** 
1. Follow official Flutter guide - https://flutter.dev/docs/get-started/install/macos to install Flutter SDK

**On Windows:**
1. Follow official Flutter guide - https://flutter.dev/docs/get-started/install/windows to install Flutter SDK

**On Linux:**
1. Follow official Flutter guide - https://flutter.dev/docs/get-started/install/linux to install Flutter SDK

**For all platforms:**
2. Setup environment variable `SDK_REGISTRY_TOKEN`
3. Run command 
   - `flutter build ios` from console to build iOS app (**available only at MacOS**)
   - `flutter build apk` from console to build Android app. This command will generate a "fat" (all ABIs included) apk. There are other build artifacts possible as well, e.g. per-abi ones and others. Please refer to the general Flutter documentation for that.

## To run locally:
Run command 
   - `flutter run -d chrome --debug` from console to run in debug mode
   - `flutter run -d chrome --profile` from console to run in profile mode (main mode for now)
