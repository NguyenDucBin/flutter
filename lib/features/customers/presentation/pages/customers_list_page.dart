import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doanflutter/features/auth/presentation/provider/auth_service.dart'; // Import AuthService
import 'package:doanflutter/features/customers/domain/entities/customer_entity.dart';
import 'package:doanflutter/features/customers/presentation/provider/customer_provider.dart';

class CustomersListPage extends StatefulWidget {
  const CustomersListPage({super.key});

  @override
  State<CustomersListPage> createState() => _CustomersListPageState();
}

class _CustomersListPageState extends State<CustomersListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerProvider>().fetchCustomers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CustomerProvider>();
    final filteredCustomers = provider.filteredCustomers;

    return Scaffold(
      // Màu nền sáng hơn
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text('Quản Lý Khách Hàng', style: TextStyle(fontWeight: FontWeight.bold)),
        // Màu Indigo nhất quán
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 1,
        actions: [
          // Nút Đăng xuất
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () {
              context.read<AuthService>().signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Ô tìm kiếm
            TextField(
              decoration: InputDecoration(
                hintText: 'Tìm theo tên hoặc email...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0), // Bo tròn hơn
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder( // Viền khi focus
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(color: Colors.indigo, width: 1.5),
                ),
              ),
              onChanged: (value) => provider.setSearchQuery(value),
            ),
            const SizedBox(height: 16),

            // Danh sách
            Expanded(
              child: _buildBody(context, provider, filteredCustomers),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    CustomerProvider provider,
    List<CustomerEntity> filteredCustomers,
  ) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null) {
      return Center(child: Text('Đã xảy ra lỗi: ${provider.error}'));
    }
    if (filteredCustomers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Icon(Icons.people_outline, size: 60, color: Colors.grey[400]),
             const SizedBox(height: 16),
             Text(
              'Không tìm thấy khách hàng.',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        )
      );
    }

    // Danh sách khách hàng
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<CustomerProvider>().fetchCustomers();
      },
      child: ListView.separated(
        itemCount: filteredCustomers.length,
        itemBuilder: (context, index) {
          final customer = filteredCustomers[index];
          return Card(
            // Card đơn giản hơn
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 1,
            margin: EdgeInsets.zero, // Margin đã có ở Separated
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.indigo.shade100,
                foregroundColor: Colors.indigo.shade800,
                child: Text(
                  customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(customer.email, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                  if (customer.phone.isNotEmpty) // Chỉ hiện nếu có số phone
                    Text('SĐT: ${customer.phone}', style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                ],
              ),
              trailing: PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                onSelected: (value) {
                  if (value == 'edit') {
                    // TODO: Logic sửa
                  } else if (value == 'delete') {
                    // TODO: Gọi provider.deleteCustomer(customer.id)
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(leading: Icon(Icons.edit_outlined), title: Text('Sửa')),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(leading: Icon(Icons.delete_outline, color: Colors.red), title: Text('Xóa')),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: 10),
      ),
    );
  }
}