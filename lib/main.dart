import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'models/item.dart';
import 'services/firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inventory App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  String searchQuery = '';

  @override
  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    priceController.dispose();
    searchController.dispose();
    super.dispose();
  }

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Item name is required';
    }
    return null;
  }

  String? validateQuantity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Quantity is required';
    }

    final quantity = double.tryParse(value.trim());
    if (quantity == null) {
      return 'Enter a valid number';
    }

    if (quantity < 0) {
      return 'Quantity cannot be negative';
    }

    return null;
  }

  String? validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Price is required';
    }

    final price = double.tryParse(value.trim());
    if (price == null) {
      return 'Enter a valid number';
    }

    if (price < 0) {
      return 'Price cannot be negative';
    }

    return null;
  }

  Future<void> addItem() async {
    if (!_formKey.currentState!.validate()) return;

    final item = Item(
      name: nameController.text.trim(),
      quantity: double.parse(quantityController.text.trim()),
      price: double.parse(priceController.text.trim()),
    );

    await firestoreService.addItem(item);

    nameController.clear();
    quantityController.clear();
    priceController.clear();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item added successfully')),
      );
    }
  }

  Future<void> deleteItem(String id) async {
    await firestoreService.deleteItem(id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item deleted successfully')),
      );
    }
  }

  Future<void> showEditDialog(Item item) async {
    final editFormKey = GlobalKey<FormState>();

    final TextEditingController editNameController =
        TextEditingController(text: item.name);
    final TextEditingController editQuantityController =
        TextEditingController(text: item.quantity.toString());
    final TextEditingController editPriceController =
        TextEditingController(text: item.price.toString());

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Item'),
          content: SingleChildScrollView(
            child: Form(
              key: editFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: editNameController,
                    decoration: const InputDecoration(
                      labelText: 'Item Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: validateName,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: editQuantityController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                    ),
                    validator: validateQuantity,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: editPriceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      border: OutlineInputBorder(),
                    ),
                    validator: validatePrice,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!editFormKey.currentState!.validate()) return;

                final updatedItem = Item(
                  id: item.id,
                  name: editNameController.text.trim(),
                  quantity: double.parse(editQuantityController.text.trim()),
                  price: double.parse(editPriceController.text.trim()),
                );

                await firestoreService.updateItem(updatedItem);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Item updated successfully')),
                  );
                }

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );

    editNameController.dispose();
    editQuantityController.dispose();
    editPriceController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory App'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Item Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: validateName,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: quantityController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                    ),
                    validator: validateQuantity,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: priceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      border: OutlineInputBorder(),
                    ),
                    validator: validatePrice,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: addItem,
                      child: const Text('Add Item'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search Items',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase().trim();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Item>>(
              stream: firestoreService.getItems(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Something went wrong.'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final items = snapshot.data ?? [];

                final filteredItems = items.where((item) {
                  return item.name.toLowerCase().contains(searchQuery);
                }).toList();

                final totalValue = filteredItems.fold<double>(
                  0,
                  (sum, item) => sum + (item.quantity * item.price),
                );

                if (items.isEmpty) {
                  return const Center(
                    child: Text('No items available.'),
                  );
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Total Inventory Value: \$${totalValue.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: filteredItems.isEmpty
                          ? const Center(
                              child: Text('No matching items found.'),
                            )
                          : ListView.builder(
                              itemCount: filteredItems.length,
                              itemBuilder: (context, index) {
                                final item = filteredItems[index];

                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  child: ListTile(
                                    title: Text(item.name),
                                    subtitle: Text(
                                      'Quantity: ${item.quantity} | Price: \$${item.price.toStringAsFixed(2)}',
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () => showEditDialog(item),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: item.id == null
                                              ? null
                                              : () => deleteItem(item.id!),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}