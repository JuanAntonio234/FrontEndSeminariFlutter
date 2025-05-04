import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../provider/users_provider.dart';

class LayoutWrapper extends StatelessWidget {
  final Widget child;
  final String title;

  const LayoutWrapper({
    super.key,
    required this.child,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 2,
      ),
      drawer: NavigationDrawer(
        backgroundColor: Theme.of(context).colorScheme.surface,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.people_alt_rounded,
                    size: 60,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Flutter Demo App',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildNavItem(
            context, 
            'Home', 
            Icons.home, 
            '/'),
          _buildNavItem(
            context, 
            'Usuaris', 
            Icons.info_outline, 
            '/details'),
          _buildNavItem(
            context, 
            'Crear usuari', 
            Icons.person_add, 
            '/editar'),
          _buildNavItem(
            context, 
            'Esborrar usuari', 
            Icons.delete_outline, 
            '/borrar'),
          _buildNavItem(
            context, 
            'Perfil', 
            Icons.account_circle, 
            '/profile'),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: () {
                // Load users from the API
                Provider.of<UserProvider>(context, listen: false).loadUsers();
                // Close the drawer
                Navigator.pop(context);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Carregar usuaris'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(45),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.1),
        child: child,
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String title, IconData icon, String route) {
    final bool isSelected = GoRouterState.of(context).uri.toString() == route;
    
    return ListTile(
      leading: Icon(
        icon, 
        color: isSelected 
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected 
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      onTap: () {
        Navigator.pop(context);
        context.go(route);
      },
    );
  }
}