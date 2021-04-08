/// The FileStorageController class provides methods to store and retrieve files locally
class FileStorageController {
  static getURLForFile(String uuid) {
    // Little hack to make our demo data work
    var split = uuid.split(".");
    var fileExt = split.length > 1 ? split.last : "jpg";
    var fileName = split[0];
    var url = "assets/demoAssets/$fileName.$fileExt";
    return url;
    // End hack
  }
}
