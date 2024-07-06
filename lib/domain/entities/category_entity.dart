class CategoryEntity {
  CategoryEntity({
    this.id,
    this.name,
    this.image,
  });

  String? id;
  String? name;
  String? image;

  factory CategoryEntity.fromJson(Map<String, dynamic> json) => CategoryEntity(
        id: json["id"],
        name: json["name"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image": image,
      };
}
