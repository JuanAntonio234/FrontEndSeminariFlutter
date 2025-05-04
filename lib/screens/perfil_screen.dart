import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/Layout.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import '../services/UserService.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

@override
State<PerfilScreen>createState()=>_PerfilScreenState();
}
class _PerfilScreenState extends State<PerfilScreen>{
  bool _isLoading=true;
  User? _user;
  String? _errorMessage;
  @override
  void initState(){
    super.initState();
    _fetchUserData();
  }

  Future<void>_fetchUserData()async{
    try{
      if(AuthService.idCurrentUser!=null){
       final user=await UserService.getUserById(AuthService.idCurrentUser!);
       setState((){
        _user=user;
        _isLoading=false;
       });
      }else{
        setState((){
          _errorMessage='No s\'ha loguejat l\'usuari';
          _isLoading=false;
        });
       }
    }catch(error){
      setState(() {
        _errorMessage='Error al carregar les dades de l\'usuari: $error';
        _isLoading=false;
      });
    }
  }
  
  void _changePassword() async {
    if(_user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No s\'ha pogut carregar l\'usuari')),
      );
      return;
    }
    final password0 = TextEditingController();
    final updatedPassword = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Canviar contrasenya'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: password0,
                decoration: const InputDecoration(labelText: 'Contrasenya actual'),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: updatedPassword,
                decoration: const InputDecoration(labelText: 'Nova contrasenya'),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () =>
                Navigator.of(context).pop(),
                child: const Text('Cancel·lar'),
            ),
            ElevatedButton(
              onPressed: () async {
                try{
                  final updatedUser = User(
                    id: _user!.id,
                    name: _user!.name,
                    email: _user!.email,
                    age:_user!.age,
                    password: updatedPassword.text, // Actualitza la contrasenya
                  );
                  if (updatedPassword.text != password0.text) {
                    await UserService.updateUser(_user!.id!,updatedUser);
                    _fetchUserData();
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Contrasenya canviada amb èxit')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Contrasenyas no coincideixen')),
                    );
                  }
                }catch(e){
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al canviar la contrasenya: $e'))
                  );
                }
              },
              child: const Text('Canviar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if(_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if(_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }
    return LayoutWrapper(
      title: 'Perfil',
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.deepPurple,
                    child: Icon(Icons.person, size: 70, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _user?.name ?? 'Nom no disponible',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _user?.email ?? 'Email no disponible',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          _buildProfileItem(
                            context,
                            Icons.badge,'ID',
                            _user?.id ?? 'No disponible',
                            ),
                          const Divider(),
                          _buildProfileItem( context,Icons.cake, 'Edat',
                          _user?.age.toString() ?? 'No disponible'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Configuració del compte',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          _buildSettingItem(
                            context,
                            Icons.edit,
                            'Editar Perfil',
                            'Actualitza la teva informació personal',
                            _editProfile
                          ),
                          _buildSettingItem(
                            context,
                            Icons.lock,
                            'Canviar contrasenya',
                            'Actualitzar la contrasenya',
                            _changePassword,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        final authService = AuthService();
                        authService.logout();
                        context.go('/login');
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error al tancar sessió: $e')),
                        );
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('TANCAR SESSIÓ'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

 void _editProfile() async {
    if(_user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No s\'ha pogut carregar l\'usuari')),
      );
      return;
    }
    final nameC = TextEditingController();
    final emailC=TextEditingController();
    final ageC=TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar usuari'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameC,
                decoration: const InputDecoration(labelText: 'Nom'),
                obscureText: false,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailC,
                decoration: const InputDecoration(labelText: 'Correu electrònic'),
                obscureText: false,
              ),
              TextField(
                controller: ageC,
                decoration: const InputDecoration(labelText: 'Edat'),
                obscureText: false,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () =>
                Navigator.of(context).pop(),
                child: const Text('Cancel·lar'),
            ),
            ElevatedButton(
              onPressed: () async {
                try{
                  if (nameC.text.isEmpty || emailC.text.isEmpty || ageC.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tots els camps són obligatoris')),
                    );
                    return;
                  }
                  final updatedUser = User(
                    id: _user!.id,
                    name: nameC.text,
                    email: emailC.text,
                    age:int.tryParse(ageC.text) ?? _user!.age,
                    password: _user!.password, // Actualitza la contrasenya
                  );
                    await UserService.updateUser(_user!.id!,updatedUser);
                    _fetchUserData();
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Usuari actualizat amb èxit')),
                    );
                  
                }catch(e){
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error a l\'actualitzar l\'usuari: $e'))
                  );
                }
              },
              child: const Text('Actualitzar'),
            ),
          ],
        );
      },
    );
  }


  Widget _buildProfileItem(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback? onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}