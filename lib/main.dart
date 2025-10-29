
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// --- Core ---
import 'firebase_options.dart';
import 'core/router/app_router.dart';
import 'core/services/storage_service.dart';

// --- Auth Feature ---
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/data/datasources/auth_firebase_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/provider/auth_service.dart';

// --- Hotel Feature ---
import 'features/hotel/domain/repositories/hotel_repository.dart';
import 'features/hotel/data/repositories/hotel_repository_impl.dart';
import 'features/hotel/presentation/provider/hotel_provider.dart';

// --- Room Feature ---
import 'features/rooms/domain/repositories/room_repository.dart';
import 'features/rooms/data/repositories/room_repository_impl.dart';
import 'features/rooms/presentation/provider/room_provider.dart';

// --- Booking Feature ---
import 'features/booking/domain/repositories/booking_repository.dart';
import 'features/booking/data/repositories/booking_repository_impl.dart';
import 'features/booking/presentation/provider/booking_provider.dart';

// --- Customer Feature ---
import 'features/customers/domain/repositories/customer_repository.dart';
import 'features/customers/data/repositories/customer_repository_impl.dart';
import 'features/customers/presentation/provider/customer_provider.dart';

// --- Report Feature ---
import 'features/reports/domain/repositories/report_repository.dart';
import 'features/reports/data/repositories/report_repository_impl.dart';
import 'features/reports/presentation/provider/report_provider.dart';

// --- Thêm import cho Review ---
import 'features/reviews/domain/repositories/review_repository.dart';
import 'features/reviews/data/repositories/review_repository_impl.dart';
import 'features/reviews/presentation/provider/review_provider.dart';

import 'package:firebase_messaging/firebase_messaging.dart'; 
import 'package:doanflutter/core/services/messaging_service.dart';

import 'features/favorites/domain/repositories/favorites_repository.dart';
import 'features/favorites/data/repositories/favorites_repository_impl.dart';
import 'features/favorites/presentation/provider/favorites_provider.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const AppEntry());
}

class AppEntry extends StatelessWidget {
  const AppEntry({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider là nơi "tiêm" (inject) tất cả các dịch vụ,
    // repository, và provider vào cây widget.
    return MultiProvider(
      providers: [
        // === 1. EXTERNAL SERVICES ===
        // Cung cấp các instance Firebase cho toàn bộ app
        Provider<FirebaseAuth>(create: (_) => FirebaseAuth.instance),
        Provider<FirebaseFirestore>(create: (_) => FirebaseFirestore.instance),
        Provider<StorageService>(create: (_) => StorageService()),
        Provider<MessagingService>(create: (_) => MessagingService()),

        Provider<FavoritesRepository>(
          create: (context) => FavoritesRepositoryImpl(
            context.read<FirebaseFirestore>(),
          ),
        ),

        // === 2. DATASOURCES ===
        // (Chỉ Auth feature dùng DataSource riêng, các feature khác
        // RepositoryImpl gọi thẳng Firestore nên không cần)
        Provider<AuthFirebaseDataSource>(
          create: (context) => AuthFirebaseDataSource(
            context.read<FirebaseAuth>(),
            context.read<FirebaseFirestore>(),
          ),
        ),

        // === 3. REPOSITORIES (Interface -> Implementation) ===
        // Đăng ký các Repository Implementation,
        // để các Provider ở dưới có thể "read" Interface (Hợp đồng)
        Provider<AuthRepository>(
          create: (context) => AuthRepositoryImpl(
            context.read<AuthFirebaseDataSource>(),
          ),
        ),
        Provider<HotelRepository>(
          create: (context) => HotelRepositoryImpl(
            context.read<FirebaseFirestore>(),
          ),
        ),
        Provider<RoomRepository>(
          create: (context) => RoomRepositoryImpl(
            context.read<FirebaseFirestore>(),
          ),
        ),
        Provider<BookingRepository>(
          create: (context) => BookingRepositoryImpl(
            context.read<FirebaseFirestore>(),
          ),
        ),
        Provider<CustomerRepository>(
          create: (context) => CustomerRepositoryImpl(
            context.read<FirebaseFirestore>(),
          ),
        ),
        Provider<ReportRepository>(
          create: (context) => ReportRepositoryImpl(
            context.read<FirebaseFirestore>(),
          ),
        ),

        Provider<ReviewRepository>(
          create: (context) => ReviewRepositoryImpl(
            context.read<FirebaseFirestore>(),
          ),
        ),

        // === 4. PROVIDERS (ChangeNotifiers cho UI) ===
        // Các Provider này sẽ lấy Repository ở trên để hoạt động
        ChangeNotifierProvider<AuthService>(
          create: (context) => AuthService(
            context.read<AuthRepository>(),
            context.read<MessagingService>(),
          ),
        ),
        ChangeNotifierProvider<HotelProvider>(
          create: (context) => HotelProvider(
            context.read<HotelRepository>(),
          ),
        ),
        ChangeNotifierProvider<RoomProvider>(
          create: (context) => RoomProvider(
            context.read<RoomRepository>(),
            context.read<HotelRepository>(),
          ),
        ),
        ChangeNotifierProvider<BookingProvider>(
          create: (context) => BookingProvider(
            context.read<BookingRepository>(),
          ),
        ),
        ChangeNotifierProvider<CustomerProvider>(
          create: (context) => CustomerProvider(
            context.read<CustomerRepository>(),
          ),
        ),
        ChangeNotifierProvider<ReportProvider>(
          create: (context) => ReportProvider(
            context.read<ReportRepository>(),
          ),
        ),
        ChangeNotifierProvider<ReviewProvider>(
          create: (context) => ReviewProvider(
            context.read<ReviewRepository>(),
          ),
        ),
        ChangeNotifierProvider<FavoritesProvider>(
          create: (context) => FavoritesProvider(
            context.read<FavoritesRepository>(),
          ),
        ),
      ],

      // MaterialApp sẽ là con của MultiProvider
      child: MaterialApp(
        title: 'Hotel Booking (Clean Architecture)',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // Đổi màu chủ đạo cho nhất quán
          primarySwatch: Colors.indigo,
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF9FAFB),
        ),
        onGenerateRoute: AppRouter.onGenerateRoute,
        // Điểm bắt đầu là '/', AppRouter sẽ điều hướng đến AuthGate
        initialRoute: '/',
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''), // English, no country code
          Locale('vi', ''), // Vietnamese, no country code
          // Thêm các ngôn ngữ khác nếu cần
        ],
        locale: const Locale('vi', ''),
      ),
    );
  }
}