class PluginConfigJson {
  String name;
  String display;
  String type;
  String dataType;
  dynamic defaultData;

  PluginConfigJson(
      this.name, this.display, this.type, this.dataType, this.defaultData);

  factory PluginConfigJson.fromJson(Map<String, dynamic> json) =>
      PluginConfigJson(json["name"], json["display"], json["type"],
          json["data_type"], json["default"] ?? "");
}
