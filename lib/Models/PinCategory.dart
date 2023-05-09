class PinCategory {
  late String name;
  late String iconPath;
  late String categoryCode;
  String? desc;

  Map<dynamic, dynamic> toJson() => 
  {
    'name': name,
    'icon_path': iconPath
  };

  PinCategory.fromMap(Map<dynamic, dynamic> input) {
    name = input['name'];
    iconPath = input['icon_path'];
    categoryCode = input['category_code'];
    desc = input['desc'].isEmpty ? null : input['desc'];
  }
}