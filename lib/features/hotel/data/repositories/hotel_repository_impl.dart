import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doanflutter/features/hotel/data/models/hotel_model.dart';
import 'package:doanflutter/features/hotel/domain/entities/hotel_entity.dart';
import 'package:doanflutter/features/hotel/domain/repositories/hotel_repository.dart';

class HotelRepositoryImpl implements HotelRepository {
  final FirebaseFirestore _db;
  HotelRepositoryImpl(this._db);

  CollectionReference get _hotelsCol => _db.collection('hotels');

  @override
  Future<List<HotelEntity>> fetchAllHotels() async {
    final snapshot = await _hotelsCol.get();
    return snapshot.docs.map((doc) => HotelModel.fromSnapshot(doc)).toList();
  }

  @override
  Future<List<HotelEntity>> fetchHotelsForOwner(String ownerId) async {
    final snapshot =
        await _hotelsCol.where('ownerId', isEqualTo: ownerId).get();
    return snapshot.docs.map((doc) => HotelModel.fromSnapshot(doc)).toList();
  }

  @override
  Future<void> createHotel(HotelEntity hotel) async {
    final model = HotelModel(
      id: '', // ID sẽ được tự động tạo bởi Firestore
      ownerId: hotel.ownerId,
      name: hotel.name,
      address: hotel.address,
      description: hotel.description,
      imageUrls: hotel.imageUrls,
      amenities: hotel.amenities,
    );
    // Thêm trường 'createdAt' khi tạo mới
    final data = model.toMap()..['createdAt'] = FieldValue.serverTimestamp();
    await _hotelsCol.add(data);
  }

  @override
  Future<void> updateHotel(HotelEntity hotel) async {
    final dataToUpdate = {
      'ownerId': hotel.ownerId,
      'name': hotel.name,
      'address': hotel.address,
      'description': hotel.description,
      'imageUrls': hotel.imageUrls,
      'amenities': hotel.amenities,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await _hotelsCol.doc(hotel.id).update(dataToUpdate);
  }

  @override
  Future<void> deleteHotel(String hotelId) async {
    final batch = _db.batch();

    // 1. Get reference to 'rooms' subcollection
    final roomsSnapshot = await _hotelsCol.doc(hotelId).collection('rooms').get();

    // 2. Add delete commands for each room to batch
    for (final doc in roomsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // 3. Add delete command for the hotel itself
    batch.delete(_hotelsCol.doc(hotelId));

    // 4. Execute all deletes in one atomic operation
    await batch.commit();
  }

  @override
  Future<void> updateHotelMinPrice(String hotelId, double minPrice) async {
    await _hotelsCol.doc(hotelId).update({'minPrice': minPrice});
  }
}