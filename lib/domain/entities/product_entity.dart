import 'category_entity.dart';

class ProductEntity {
  ProductEntity({
    this.category,
    this.dateCreated,
    this.dateUpdated,
    this.description,
    this.id,
    this.imageUrl,
    this.isReleased,
    this.name,
    this.price,
    this.sellerId,
    this.rating,
    this.sold,
    this.stock,
  });

  CategoryEntity? category;
  String? dateCreated;
  String? dateUpdated;
  String? description;
  String? id;
  String? imageUrl;
  bool? isReleased;
  String? name;
  int? price;
  String? sellerId;
  num? rating;
  int? sold;
  int? stock;

  factory ProductEntity.fromJson(Map<String, dynamic> json) => ProductEntity(
        category: CategoryEntity.fromJson(json["category"]),
        dateCreated: json["date_created"],
        dateUpdated: json["date_updated"],
        description: json["description"],
        id: json["id"],
        imageUrl: json["image_url"],
        isReleased: json["is_released"],
        name: json["name"],
        price: json["price"],
        sellerId: json["seller_id"],
        rating: json["rating"],
        sold: json["sold"],
        stock: json["stock"],
      );

  Map<String, dynamic> toJson() => {
        "category": category?.toJson(),
        "date_created": dateCreated,
        "date_updated": dateUpdated,
        "description": description,
        "id": id,
        "image_urls": imageUrl,
        "is_released": isReleased,
        "name": name,
        "price": price,
        "seller_id": sellerId,
        "rating": rating,
        "sold": sold,
        "stock": stock,
      };
}
