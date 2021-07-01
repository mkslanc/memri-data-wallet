# Memri

Memri Flutter application


# Bulding

To build the app locally, you need to either install the Flutter environment locally, or use the docker build.

You'll also need a working MapBox key (the `SDK_REGISTRY_TOKEN` environment variable below). Please ask for one from the team if you're an active contributor, or generate a personal one from mapbox (TODO: improve this? ideas welcome, e.g. if there's a script to generate key if not present).

To build using docker:
```
docker run --rm -e UID="$UID" -e GID="$GROUPS" -e SDK_REGISTRY_TOKEN="....." --workdir /project -v "$PWD":/project matspfeiffer/flutter build apk
```

To build locally:
```
# after having Flutter installed on your system
SDK_REGISTRY_TOKEN="...." flutter build apk
```

The above commands will generate a "fat" (all ABIs included) apk. There are other build artifacts possible as well, e.g. per-abi ones and others. Please refer to the general Flutter documentation for that.
