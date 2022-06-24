import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memri/core/controllers/permission_controller.dart';
import 'package:permission_handler/permission_handler.dart';

Set<int> askedPermissions = {};

void _setupPermissions(Map<int, int> permissions) {
  MethodChannel('flutter.baseflow.com/permissions/methods')
      .setMockMethodCallHandler((MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'requestPermissions':
        return permissions;
      case 'checkPermissionStatus':
        int askedPermission = methodCall.arguments;
        askedPermissions.add(askedPermission);
        for (MapEntry<int, int> permissionKey in permissions.entries) {
          if (permissionKey.key == methodCall.arguments) {
            return permissionKey.value;
          }
        }
    }
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PermissionsController permissionController = PermissionsController.shared;

  setUp(() {
    _setupPermissions(<int, int>{
      Permission.camera.value: PermissionStatus.denied.index,
      Permission.storage.value: PermissionStatus.denied.index,
      Permission.microphone.value: PermissionStatus.denied.index,
      Permission.contacts.value: PermissionStatus.denied.index,
      Permission.location.value: PermissionStatus.denied.index
    });
  });

  test('testCameraPermissionRequested', () async {
    expect(askedPermissions.contains(Permission.camera.value), false);
    expect(await permissionController.cameraPermission, equals(false));

    await permissionController.requestCamera();
    _setupPermissions(<int, int>{
      Permission.camera.value: PermissionStatus.granted.index,
    });
    expect(await permissionController.cameraPermission, equals(true));
    expect(askedPermissions.contains(Permission.camera.value), true);
  });

  test('testStoragePermissionRequested', () async {
    expect(askedPermissions.contains(Permission.storage.value), false);
    expect(await permissionController.storagePermission, equals(false));

    await permissionController.requestStorage();
    _setupPermissions(<int, int>{
      Permission.storage.value: PermissionStatus.granted.index,
    });
    expect(await permissionController.storagePermission, equals(true));
    expect(askedPermissions.contains(Permission.storage.value), true);
  });

  test('testMicrophonePermissionRequested', () async {
    expect(askedPermissions.contains(Permission.microphone.value), false);
    expect(await permissionController.microphonePermission, equals(false));

    await permissionController.requestMicrophone();
    _setupPermissions(<int, int>{
      Permission.microphone.value: PermissionStatus.granted.index,
    });
    expect(await permissionController.microphonePermission, equals(true));
    expect(askedPermissions.contains(Permission.microphone.value), true);
  });

  test('testContactsPermissionRequested', () async {
    expect(askedPermissions.contains(Permission.contacts.value), false);
    expect(await permissionController.contactsPermission, equals(false));

    await permissionController.requestContacts();
    _setupPermissions(<int, int>{
      Permission.contacts.value: PermissionStatus.granted.index,
    });
    expect(await permissionController.contactsPermission, equals(true));
    expect(askedPermissions.contains(Permission.contacts.value), true);
  });

  test('testLocationPermissionRequested', () async {
    expect(askedPermissions.contains(Permission.location.value), false);
    expect(await permissionController.locationPermission, equals(false));

    await permissionController.requestLocation();
    _setupPermissions(<int, int>{
      Permission.location.value: PermissionStatus.granted.index,
    });
    expect(await permissionController.locationPermission, equals(true));
    expect(askedPermissions.contains(Permission.location.value), true);
  });
}
