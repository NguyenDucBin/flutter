import 'package:equatable/equatable.dart';

class BookingEntity extends Equatable {
  final String? bookingId;
  final String userId;       
  final String ownerId;      
  final String hotelId;
  final String hotelName;    
  final String roomId;
  final String roomType;    
  final DateTime checkIn;
  final DateTime checkOut;
  final double totalPrice;
  final String status;

  const BookingEntity({
    this.bookingId,
    required this.userId,
    required this.ownerId,     
    required this.hotelId,
    required this.hotelName,   
    required this.roomId,
    required this.roomType,   
    required this.checkIn,
    required this.checkOut,
    required this.totalPrice,
    required this.status,
  });

  @override
  List<Object?> get props {
    return [
      bookingId,
      userId,
      ownerId,    
      hotelId,
      hotelName,  
      roomId,
      roomType,   
      checkIn,
      checkOut,
      totalPrice,
      status,
    ];
  }
}