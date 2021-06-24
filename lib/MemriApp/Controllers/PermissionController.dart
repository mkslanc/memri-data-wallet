import 'package:permission_handler/permission_handler.dart';

class PermissionsController {
  static PermissionsController shared = PermissionsController();

  Future<bool> get cameraPermission async {
    return await Permission.camera.isGranted;
  }

  Future<bool> get storagePermission async {
    return await Permission.storage.isGranted;
  }

  Future<bool> get microphonePermission async {
    return await Permission.microphone.isGranted;
  }

  Future<bool> get contactsPermission async {
    return await Permission.contacts.isGranted;
  }

  Future<bool> get locationPermission async {
    return await Permission.location.isGranted;
  }

  requestCamera() async {
    if (await cameraPermission == false) {
      await Permission.camera.request();
    }
  }

  requestStorage() async {
    if (await storagePermission == false) {
      await Permission.storage.request();
    }
  }

  requestMicrophone() async {
    if (await microphonePermission == false) {
      await Permission.microphone.request();
    }
  }

  requestContacts() async {
    if (await contactsPermission == false) {
      await Permission.contacts.request();
    }
  }

  requestLocation() async {
    if (await locationPermission == false) {
      await Permission.location.request();
    }
  }
}
