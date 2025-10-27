import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doanflutter/features/hotel/domain/entities/hotel_entity.dart';

class HotelModel extends HotelEntity {
  const HotelModel({
    required super.id,
    required super.ownerId,
    required super.name,
    required super.address,
    super.description,
    super.imageUrls,
    super.amenities,
  });

  // Chuyển đổi từ Firestore Document về Model
  factory HotelModel.fromSnapshot(DocumentSnapshot snap) {
    var data = snap.data() as Map<String, dynamic>;
    return HotelModel(
      id: snap.id,
      ownerId: data['ownerId'] ?? '',
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      description: data['description'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      amenities: List<String>.from(data['amenities'] ?? []),
    );
  }

  // Chuyển đổi từ Model về Map để lưu lên Firestore
  // (Không bao gồm 'id' vì nó là tên của Document)
  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'name': name,
      'address': address,
      'description': description,
      'imageUrls': imageUrls,
      'amenities': amenities,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}