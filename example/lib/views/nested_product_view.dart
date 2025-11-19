import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mosaique/mosaique.dart' hide Icons;

/// Product view demonstrating nested shell layouts
///
/// This view contains a nested MosaiqueShellBuilder that uses a different
/// shell layout for the product detail page, demonstrating how layouts
/// can be composed hierarchically.
class NestedProductView extends StatelessWidget {
  final String productId;

  const NestedProductView({required this.productId, super.key});

  @override
  Widget build(BuildContext context) {
    // Get the parent route context
    final parentContext = context.routeContext;

    // Create a nested shell builder with its own shell layouts and routes
    return MosaiqueShellBuilder(
      context: parentContext,
      shellLayouts: _nestedShellLayouts,
      routes: _nestedRouteDefinitions,
      debugConfig: const MosaiqueDebugConfig(enabled: true, logRouteMatching: true, logViewResolution: true),
    );
  }

  // Nested shell layouts
  static final _nestedShellLayouts = <String, ShellLayout>{
    'nested-detail': ShellLayout(
      id: 'nested-detail',
      builder: (regions) {
        return Column(
          children: [
            // Header region
            if (regions['header'] != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                ),
                child: regions['header'],
              ),
            // Content region
            Expanded(child: regions['content'] ?? const SizedBox.shrink()),
          ],
        );
      },
    ),
  };

  // Nested route definitions
  static final _nestedRouteDefinitions = <RouteDefinition>[
    RouteDefinition(
      pattern: '/products/:productId',
      shellSelector: (context) => 'nested-detail',
      viewRules: [
        ViewInjectionRule(
          regionKey: 'header',
          condition: (context) => true,
          builder: (context) {
            final productId = context.pathParameters['productId'] ?? '';
            return ProductHeaderView(productId: productId);
          },
        ),
        ViewInjectionRule(
          regionKey: 'content',
          condition: (context) => true,
          builder: (context) {
            final productId = context.pathParameters['productId'] ?? '';
            return ProductContentView(productId: productId);
          },
        ),
      ],
    ),
  ];
}

/// Product header view (nested region)
class ProductHeaderView extends StatelessWidget {
  final String productId;

  const ProductHeaderView({required this.productId, super.key});

  @override
  Widget build(BuildContext context) {
    final product = _getProductData(productId);

    return Row(
      children: [
        IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/')),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product['name']!, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Product ID: $productId', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        Chip(label: Text(product['status']!), backgroundColor: product['status'] == 'In Stock' ? Colors.green.shade100 : Colors.orange.shade100),
      ],
    );
  }

  Map<String, String> _getProductData(String id) {
    final products = {
      '1': {'name': 'Laptop Pro', 'status': 'In Stock'},
      '2': {'name': 'Wireless Mouse', 'status': 'In Stock'},
      '3': {'name': 'Mechanical Keyboard', 'status': 'Low Stock'},
    };
    return products[id] ?? {'name': 'Unknown Product', 'status': 'N/A'};
  }
}

/// Product content view (nested region)
class ProductContentView extends StatelessWidget {
  final String productId;

  const ProductContentView({required this.productId, super.key});

  @override
  Widget build(BuildContext context) {
    final product = _getProductData(productId);
    final routeContext = context.routeContext;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nested Shell Layout Demo',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'This product view demonstrates nested shell layouts. '
                    'The header and content are separate regions within a '
                    'nested shell layout, showing how Mosaique supports '
                    'hierarchical composition.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Route Context (propagated to nested layout):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 8),
                        Text('Path: ${routeContext.path}', style: const TextStyle(fontSize: 12)),
                        Text('Product ID: ${routeContext.pathParameters['productId']}', style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Product Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildDetailRow('Name', product['name']!),
          _buildDetailRow('SKU', product['sku']!),
          _buildDetailRow('Price', product['price']!),
          _buildDetailRow('Category', product['category']!),
          _buildDetailRow('Stock', product['stock']!),
          const SizedBox(height: 24),
          const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(product['description']!, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.shopping_cart),
              label: const Text('Add to Cart'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Map<String, String> _getProductData(String id) {
    final products = {
      '1': {
        'name': 'Laptop Pro',
        'sku': 'LAP-001',
        'price': '\$1,299.99',
        'category': 'Electronics',
        'stock': '15 units',
        'description':
            'High-performance laptop with 16GB RAM, 512GB SSD, and Intel Core i7 processor. '
            'Perfect for professional work and creative tasks.',
      },
      '2': {
        'name': 'Wireless Mouse',
        'sku': 'MOU-002',
        'price': '\$29.99',
        'category': 'Accessories',
        'stock': '50 units',
        'description':
            'Ergonomic wireless mouse with precision tracking and long battery life. '
            'Compatible with all major operating systems.',
      },
      '3': {
        'name': 'Mechanical Keyboard',
        'sku': 'KEY-003',
        'price': '\$149.99',
        'category': 'Accessories',
        'stock': '8 units',
        'description':
            'Premium mechanical keyboard with RGB backlighting and customizable keys. '
            'Cherry MX switches for the best typing experience.',
      },
    };

    return products[id] ?? {'name': 'Unknown Product', 'sku': 'N/A', 'price': 'N/A', 'category': 'N/A', 'stock': 'N/A', 'description': 'Product not found.'};
  }
}
